#!/usr/bin/env bash
# Susanoo — install or update the kit into a target Git repository (in-repo inject).
#
# Port of go-accelerator's scripts/install.py, reduced to Susanoo's layout. The same
# ownership model is kept: receipt-owned (SHA-256) managed files, an additive merge of
# shared config, seed-once project files, and a dry-run. A Go CLI replaces this later.
#
# Usage:
#   install.sh install <target> [--dry-run] [--yes]
#   install.sh update  <target> [--dry-run] [--yes]
#
# The kit source is the directory above this script (its parent of scripts/). Target
# must be an existing Git repository root.
set -euo pipefail

# --- constants ---------------------------------------------------------------

PRODUCT="susanoo"
RECEIPT_PATH=".claude/.susanoo-receipt.json"
BLOCK_BEGIN="# BEGIN SUSANOO MANAGED"
BLOCK_END="# END SUSANOO MANAGED"

# Receipt-owned namespaces: Susanoo owns these wholesale and may replace their contents
# on update. They must not pre-exist in the target on a fresh install.
MANAGED_DIRS=(
  ".claude/skills"
  ".claude/hooks"
  ".claude/conventions"
  "scripts"
  "templates"
  "git-hooks"
)

# Receipt-owned single files.
MANAGED_FILES=(
  ".claude/DOD.md"
  ".claude/GOLDEN-PRINCIPLES.md"
  ".claude/STABILIZATION.md"
  "AGENTS.md"
)

# Shared config: merged additively with the target's own file, never clobbered.
SHARED_CONFIG=(
  ".claude/settings.json"
)

# Seeded once; project-owned afterwards and never overwritten.
SEED_ONCE=(
  "specs/README.md"
  "specs/MANIFEST.md"
  "tasks/README.md"
)

HOOK_PATHS=(
  ".claude/hooks/local-context.sh"
  ".claude/hooks/file-naming-validator.sh"
  ".claude/hooks/bash-validator.sh"
  ".claude/hooks/loop-detection.sh"
)

# --- helpers -----------------------------------------------------------------

# The kit root is the parent of this script's directory (i.e. parent of scripts/).
SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

die()  { printf 'error: %s\n' "$*" >&2; exit 70; }
usage_error() { printf 'error: %s\n' "$*" >&2; exit 64; }

sha256_file() { sha256sum "$1" | awk '{print $1}'; }

run_git() {
  local target="$1"; shift
  git -C "$target" "$@" 2>/dev/null
}

# Resolve a relative payload path to an absolute path under a root, refusing symlinks.
# Not a hard security boundary — the installer is a trusted, user-invoked tool — but it
# keeps a symlinked managed directory from redirecting writes outside the target.
resolve_path() {
  local root="$1" rel="$2"
  local cur="$root" part
  IFS='/' read -ra parts <<< "$rel"
  for part in "${parts[@]}"; do
    cur="$cur/$part"
    if [ -L "$cur" ]; then
      die "refusing to write through a symlinked managed path: $rel"
    fi
  done
  printf '%s\n' "$cur"
}

# --- source identity & payload ----------------------------------------------

source_identity() {
  local version revision
  if [ -f "$SOURCE/VERSION" ]; then
    version="$(tr -d '\r\n' < "$SOURCE/VERSION")"
    [ -n "$version" ] || usage_error "source VERSION is empty"
  else
    usage_error "source has no VERSION file at $SOURCE/VERSION"
  fi
  revision="$(run_git "$SOURCE" rev-parse HEAD 2>/dev/null || true)"
  revision="${revision:-}"
  printf '%s\n%s\n' "$version" "$revision"
}

# Emit the sorted list of relative payload paths (managed dirs walked + managed files).
enumerate_payload() {
  local d f rel
  for d in "${MANAGED_DIRS[@]}"; do
    [ -d "$SOURCE/$d" ] || continue
    while IFS= read -r -d '' f; do
      rel="${f#"$SOURCE"/}"
      printf '%s\n' "$rel"
    done < <(find "$SOURCE/$d" -type f ! -path '*/__pycache__/*' ! -name '*.pyc' -print0 | sort -z)
  done
  for f in "${MANAGED_FILES[@]}"; do
    [ -f "$SOURCE/$f" ] && printf '%s\n' "$f"
  done
}

# --- receipt -----------------------------------------------------------------

load_receipt() {
  local target="$1" path="$target/$RECEIPT_PATH"
  [ -e "$path" ] || { printf ''; return 0; }
  [ -f "$path" ] || die "invalid installation receipt: $RECEIPT_PATH is not a file"
  jq -e '
    . as $r
    | (($r | type) == "object")
      and ($r.schema == 1)
      and ($r.product == "susanoo")
      and (($r.version | type) == "string")
      and (($r.files | type) == "object")
      and (($r.files | to_entries | all(.value | type == "string" and (length == 64))))
  ' "$path" >/dev/null 2>&1 \
    || die "invalid installation receipt: $RECEIPT_PATH"
  cat "$path"
}

# --- settings merge ----------------------------------------------------------

# Merge the source settings.json over the project's own, additively. Project values win
# for attribution and env; permissions are unioned; Susanoo hook groups replace any stale
# copy of themselves so re-running is idempotent.
MERGE_JQ='def known_hook_paths: [
  ".claude/hooks/local-context.sh",
  ".claude/hooks/file-naming-validator.sh",
  ".claude/hooks/bash-validator.sh",
  ".claude/hooks/loop-detection.sh"
];

def invokes_known_hook:
  .command // "" as $c
  | [known_hook_paths[] as $p | select($c | contains($p))] | length > 0;

def strip_known_hooks:
  if type == "object" and ((.hooks // []) | type) == "array" then
    . + { hooks: [.hooks[] | select(invokes_known_hook | not)] }
  else . end;

def append_unique($base; $extra):
  $base as $b
  | $b + [ $extra[] as $e | select($b | index($e) | not) | $e ];

(.[0] // {}) as $src |
(.[1] // {}) as $proj |

$proj |
. * { attribution: (($src.attribution // {}) * ($proj.attribution // {})) } |
. * { env: (($src.env // {}) * ($proj.env // {})) } |
. * { permissions: (
    ($proj.permissions // {}) as $p
    | { allow: (append_unique($p.allow // []; $src.permissions.allow // []))
      , deny:  (append_unique($p.deny  // []; $src.permissions.deny  // [])) }
    | . as $mp
    | ($p * $mp)
  ) } |
. * { hooks: (
    reduce (($src.hooks // {}) | keys[]) as $ev (($proj.hooks // {});
      .[$ev] = (([($proj.hooks[$ev] // [])[] | strip_known_hooks | select((.hooks // []) | length > 0)]) + ($src.hooks[$ev] // []))
    )
  ) }'

merged_settings() {
  local rel="$1" target="$2"
  local src_file="$SOURCE/$rel" dst_file="$target/$rel"
  [ -f "$src_file" ] || die "$rel source: file is missing"
  if [ ! -e "$dst_file" ]; then
    cat "$src_file"
    return 0
  fi
  [ -f "$dst_file" ] || die "$rel: expected a file"
  jq -s "$MERGE_JQ" "$src_file" "$dst_file"
}

# --- git local exclude -------------------------------------------------------

# Render the managed block in .git/info/exclude so the receipt + managed payload are not
# accidentally committed. Preserves everything else in the file.
render_exclude() {
  local existing="$1"; shift
  local patterns=("$@")
  local prefix="" line begin=-1 end=-1 i=0

  while IFS= read -r line || [ -n "$line" ]; do
    if [ "$line" = "$BLOCK_BEGIN" ]; then begin=$i; fi
    if [ "$line" = "$BLOCK_END" ]; then end=$i; fi
    i=$((i+1))
  done <<< "$existing"

  # Drop the existing managed block, if any.
  local out="" n=0
  if [ "$begin" -ge 0 ] && [ "$end" -ge "$begin" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
      if [ "$n" -ge "$begin" ] && [ "$n" -le "$end" ]; then
        n=$((n+1)); continue
      fi
      out="${out}${line}"$'\n'
      n=$((n+1))
    done <<< "$existing"
    prefix="$out"
  else
    prefix="$existing"
  fi

  # Ensure a blank line separates the block from existing content.
  if [ -n "$prefix" ] && [ "${prefix: -1}" != $'\n' ]; then prefix="${prefix}"$'\n'; fi
  if [ -n "$prefix" ] && [ "${prefix: -2}" != $'\n\n' ]; then prefix="${prefix}"$'\n'; fi

  printf '%s' "$prefix"
  printf '%s\n' "$BLOCK_BEGIN"
  local p
  for p in "${patterns[@]}"; do printf '/%s\n' "$p"; done
  printf '%s\n' "$BLOCK_END"
}

# --- plan --------------------------------------------------------------------

PLAN_DIR="$(mktemp -d)"
trap 'rm -rf "$PLAN_DIR"' EXIT

plan_append()  { printf '%s\n' "$2" >> "$PLAN_DIR/$1"; }

# Ensure every plan bucket exists (empty) so the read loops never fail on a missing file.
plan_init() {
  local k
  for k in managed_writes managed_removals managed_keeps shared_writes shared_keeps \
           seed_writes seed_keeps conflicts exclude_path exclude_content; do
    : > "$PLAN_DIR/$k"
  done
}

build_plan() {
  local mode="$1" target="$2"
  local receipt owned="" rel f sha content existing
  plan_init

  payload="$(enumerate_payload | sort -u)"
  [ -n "$payload" ] || die "source payload is empty"

  # Load owned-file hashes for update mode; refuse install over an existing install.
  if [ "$mode" = "install" ]; then
    if [ -n "$(load_receipt "$target")" ]; then
      usage_error "an installation receipt already exists; use update"
    fi
  else
    receipt="$(load_receipt "$target")"
    [ -n "$receipt" ] || usage_error "no valid installation receipt exists; run install first"
  fi

  # Managed files (receipt-owned).
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    dst="$(resolve_path "$target" "$rel")"
    if [ "$mode" = "install" ]; then
      if [ -e "$dst" ] || [ -L "$dst" ]; then
        plan_append conflicts "$rel (already exists and is not receipt-owned)"
      else
        plan_append managed_writes "$rel"$'\t'"CREATE"
      fi
      continue
    fi
    # update
    owned_hash="$(jq -r --arg r "$rel" '.files[$r] // empty' <<< "$receipt")"
    if [ -z "$owned_hash" ]; then
      # New payload path not previously owned.
      if [ -e "$dst" ] || [ -L "$dst" ]; then
        plan_append conflicts "$rel (new payload path already exists)"
      else
        plan_append managed_writes "$rel"$'\t'"CREATE"
      fi
      continue
    fi
    if [ ! -f "$dst" ]; then
      plan_append conflicts "$rel (removed since installation)"
      continue
    fi
    if [ "$(sha256_file "$dst")" != "$owned_hash" ]; then
      plan_append conflicts "$rel (modified since installation)"
      continue
    fi
    # Owned + verified: keep or update.
    if [ "$(sha256_file "$SOURCE/$rel")" != "$owned_hash" ]; then
      plan_append managed_writes "$rel"$'\t'"UPDATE"
    else
      plan_append managed_keeps "$rel"
    fi
  done <<< "$payload"

  # Removals: owned files no longer in the payload.
  if [ "$mode" = "update" ]; then
    while IFS= read -r rel; do
      grep -qxF "$rel" <<< "$payload" && continue
      dst="$(resolve_path "$target" "$rel")"
      if [ -f "$dst" ] && [ "$(sha256_file "$dst")" = "$(jq -r --arg r "$rel" '.files[$r] // empty' <<< "$receipt")" ]; then
        plan_append managed_removals "$rel"
      fi
    done < <(jq -r '.files | keys[]' <<< "$receipt")
  fi

  # Shared config (merged).
  for rel in "${SHARED_CONFIG[@]}"; do
    if ! content="$(merged_settings "$rel" "$target")"; then
      plan_append conflicts "$rel (merge failed)"
      continue
    fi
    dst="$(resolve_path "$target" "$rel")"
    if [ -f "$dst" ]; then
      existing="$(cat "$dst")"
    else
      existing=""
    fi
    if [ "$existing" = "$content" ]; then
      plan_append shared_keeps "$rel"
    else
      if [ -f "$dst" ]; then
        plan_append shared_writes "$rel"$'\t'"MERGE"
      else
        plan_append shared_writes "$rel"$'\t'"CREATE"
      fi
    fi
  done

  # Seed-once (project-owned).
  for rel in "${SEED_ONCE[@]}"; do
    if [ ! -f "$SOURCE/$rel" ]; then
      plan_append conflicts "source seed file is missing: $rel"
      continue
    fi
    dst="$(resolve_path "$target" "$rel")"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
      plan_append seed_keeps "$rel"
    else
      plan_append seed_writes "$rel"
    fi
  done

  # Git local exclude block.
  local exclude_path hidden patterns=()
  exclude_path="$(run_git "$target" rev-parse --git-path info/exclude)" \
    || die "cannot resolve the repository-local Git exclude file"
  case "$exclude_path" in
    /*) : ;;
    *) exclude_path="$target/$exclude_path" ;;
  esac
  hidden="$( { printf '%s\n' "$payload"; printf '%s\n' "${SHARED_CONFIG[@]}"; printf '%s\n' "$RECEIPT_PATH"; } | sort -u )"
  while IFS= read -r rel; do [ -n "$rel" ] && patterns+=("$rel"); done <<< "$hidden"
  if [ -f "$exclude_path" ]; then
    existing_exclude="$(cat "$exclude_path")"
  else
    existing_exclude=""
  fi
  printf '%s' "$exclude_path" > "$PLAN_DIR/exclude_path"
  render_exclude "$existing_exclude" "${patterns[@]}" > "$PLAN_DIR/exclude_content"
}

print_plan() {
  local dry="$1" rel line
  printf '%s\n' "$([ "$dry" = 1 ] && echo "DRY RUN — no files will be changed" || echo "Planned changes")"

  while IFS= read -r line; do
    [ -n "$line" ] || continue
    printf '  %-15s %s\n' "$(cut -f2 <<< "$line")" "$(cut -f1 <<< "$line")"
  done < "$PLAN_DIR/managed_writes"

  while IFS= read -r rel; do [ -n "$rel" ] && printf '  %-15s %s\n' "REMOVE" "$rel"; done < "$PLAN_DIR/managed_removals"
  while IFS= read -r rel; do [ -n "$rel" ] && printf '  %-15s %s\n' "KEEP" "$rel"; done < "$PLAN_DIR/managed_keeps"

  while IFS= read -r line; do
    [ -n "$line" ] || continue
    printf '  %-15s %s\n' "$(cut -f2 <<< "$line")" "$(cut -f1 <<< "$line")"
  done < "$PLAN_DIR/shared_writes"
  while IFS= read -r rel; do [ -n "$rel" ] && printf '  %-15s %s\n' "KEEP" "$rel"; done < "$PLAN_DIR/shared_keeps"

  while IFS= read -r rel; do [ -n "$rel" ] && printf '  %-15s %s\n' "SEED" "$rel"; done < "$PLAN_DIR/seed_writes"
  while IFS= read -r rel; do [ -n "$rel" ] && printf '  %-15s %s\n' "KEEP" "$rel (project-owned)"; done < "$PLAN_DIR/seed_keeps"

  local exclude_path="$(cat "$PLAN_DIR/exclude_path")"
  if [ -f "$exclude_path" ] && [ "$(cat "$exclude_path")" = "$(cat "$PLAN_DIR/exclude_content")" ]; then
    printf '  %-15s %s\n' "KEEP" "Git local exclude block"
  else
    printf '  %-15s %s\n' "REFRESH" "Git local exclude block"
  fi
}

# --- apply -------------------------------------------------------------------

apply_plan() {
  local target="$1" version="$2" revision="$3"
  local rel dst line

  # Removals first.
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    dst="$(resolve_path "$target" "$rel")"
    rm -f "$dst"
  done < "$PLAN_DIR/managed_removals"

  # Managed writes.
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    rel="$(cut -f1 <<< "$line")"
    dst="$(resolve_path "$target" "$rel")"
    mkdir -p "$(dirname "$dst")"
    cp -p "$SOURCE/$rel" "$dst"
  done < "$PLAN_DIR/managed_writes"

  # Shared config writes (merged content). Compute first, then write, so the redirect
  # never truncates the project file before it is read for the merge.
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    rel="$(cut -f1 <<< "$line")"
    dst="$(resolve_path "$target" "$rel")"
    mkdir -p "$(dirname "$dst")"
    content="$(merged_settings "$rel" "$target")"
    printf '%s' "$content" > "$dst"
  done < "$PLAN_DIR/shared_writes"

  # Seed writes.
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    dst="$(resolve_path "$target" "$rel")"
    mkdir -p "$(dirname "$dst")"
    cp -p "$SOURCE/$rel" "$dst"
  done < "$PLAN_DIR/seed_writes"

  # Git local exclude block.
  local exclude_path="$(cat "$PLAN_DIR/exclude_path")"
  mkdir -p "$(dirname "$exclude_path")"
  cat "$PLAN_DIR/exclude_content" > "$exclude_path"

  # Receipt written last.
  local files_tsv="$PLAN_DIR/receipt.tsv"
  : > "$files_tsv"
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    printf '%s\t%s\n' "$rel" "$(sha256_file "$SOURCE/$rel")" >> "$files_tsv"
  done <<< "$payload"
  local files_json
  files_json="$(jq -R -s '
    split("\n")
    | map(select(length > 0) | split("\t"))
    | map({(.[0]): .[1]})
    | add
  ' "$files_tsv")"
  jq -n \
    --arg version "$version" \
    --arg revision "$revision" \
    --argjson files "$files_json" \
    '{ schema: 1, product: "susanoo", version: $version, source_revision: $revision, files: $files }' \
    > "$target/$RECEIPT_PATH"
}

# --- main --------------------------------------------------------------------

usage() {
  cat >&2 <<'EOF'
Usage: install.sh install <target> [--dry-run] [--yes]
       install.sh update  <target> [--dry-run] [--yes]

Modes:
  install   seed the kit into a target Git repo (must not already have an install)
  update    refresh a prior install from the current kit source

Options:
  --dry-run  print the complete plan without writing
  --yes      skip the interactive confirmation prompt
EOF
}

main() {
  [ $# -ge 2 ] || { usage; exit 64; }
  local mode="$1" target_arg="$2"; shift 2
  local dry=0 yes=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run) dry=1 ;;
      --yes) yes=1 ;;
      *) usage_error "unknown option '$1'" ;;
    esac
    shift
  done
  case "$mode" in
    install|update) : ;;
    *) usage_error "mode must be 'install' or 'update'" ;;
  esac

  local target
  target="$(cd "$target_arg" 2>/dev/null && pwd)" \
    || usage_error "'$target_arg' is not a directory"

  if [ "$target" = "$SOURCE" ]; then
    usage_error "refusing to install Susanoo into itself"
  fi

  local top
  top="$(run_git "$target" rev-parse --show-toplevel)" \
    || usage_error "'$target' is not a Git repository"
  top="$(cd "$top" 2>/dev/null && pwd)"
  if [ "$top" != "$target" ]; then
    usage_error "'$target' is not a Git repository root (root is '$top')"
  fi

  local version revision
  { IFS= read -r version; IFS= read -r revision; } < <(source_identity)

  build_plan "$mode" "$target"

  printf '%s Susanoo %s\n' "$(tr '[:lower:]' '[:upper:]' <<< "$mode")" "$version"
  printf '  from: %s\n' "$SOURCE"
  printf '  into: %s\n\n' "$target"
  print_plan "$dry"

  if [ -s "$PLAN_DIR/conflicts" ]; then
    printf '\nREFUSING TO WRITE. Resolve all conflicts first:\n'
    while IFS= read -r rel; do printf '  ! %s\n' "$rel"; done < <(sort -u "$PLAN_DIR/conflicts")
    printf '\nNothing was written.\n'
    exit 70
  fi
  [ "$dry" -eq 1 ] && exit 0

  if [ "$yes" -ne 1 ]; then
    if [ ! -t 0 ]; then
      usage_error "confirmation requires a terminal; pass --yes for non-interactive use"
    fi
    printf '\nApply this plan? [y/N] '
    read -r answer || answer=""
    case "$answer" in
      y|Y|yes|YES) : ;;
      *) printf 'Aborted; nothing was written.\n'; exit 1 ;;
    esac
  fi

  apply_plan "$target" "$version" "$revision"

  printf '\n%s %s managed payload files.\n' \
    "$([ "$mode" = install ] && echo "Installed" || echo "Updated")" \
    "$(printf '%s\n' "$payload" | sed '/^$/d' | wc -l | tr -d ' ')"
  printf 'Receipt written last: %s\n' "$RECEIPT_PATH"
  printf 'Done. Run /init in the repo to adopt Susanoo.\n'
}

main "$@"
