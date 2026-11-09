# Susanoo — shared helpers for the shell scripts.
#
# Sourced by the scripts in ../. Do not run directly. This is a shell port of the shared
# parts of spec-kit's scripts/python/common.py, reduced to Susanoo's layout (specs/<NNN>/
# under an artifact root, no .specify/ project tree). It will be replaced by a Go CLI.

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  echo "ERROR: common.sh is a library; source it, do not run it." >&2
  exit 1
fi

# The script that sourced this file, and the kit root it lives in.
_callersource="${BASH_SOURCE[1]}"
SUSANOO_SCRIPT_DIR="$(cd "$(dirname "$_callersource")" && pwd)"
SUSANOO_KIT_ROOT="$(cd "$SUSANOO_SCRIPT_DIR/.." && pwd)"

# --- output helpers ---------------------------------------------------------

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
warn() { printf '%s\n' "$*" >&2; }

# JSON-escape a string for use inside a double-quoted JSON value.
json_str() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

# --- layout resolution ------------------------------------------------------

# The artifact root holds specs/ (and tasks/). SUSANOO_ROOT overrides; otherwise the
# current directory. In in-repo mode this is the repo root; in root-folder mode it is
# .susanoo/<project>/.
artifact_root() {
  local r="${SUSANOO_ROOT:-$PWD}"
  printf '%s\n' "$(cd "$r" 2>/dev/null && pwd || printf '%s' "$r")"
}

specs_dir() { printf '%s/specs\n' "$(artifact_root)"; }

templates_dir() { printf '%s\n' "${SUSANOO_TEMPLATES_DIR:-$SUSANOO_KIT_ROOT/templates}"; }

# The current-feature pointer is a single line holding the relative feature dir
# (specs/<NNN>-<short-name>). SUSANOO_FEATURE_DIRECTORY overrides it.
feature_pointer_file() { printf '%s/.susanoo/feature\n' "$(artifact_root)"; }

no_persist_env() {
  case "${SUSANOO_NO_PERSIST:-}" in
    1|true) return 0 ;;
    *) return 1 ;;
  esac
}

persist_feature() {
  local value="$1"
  local ptr; ptr="$(feature_pointer_file)"
  mkdir -p "$(dirname "$ptr")"
  printf '%s\n' "$value" > "$ptr"
}

read_feature_pointer() {
  local ptr; ptr="$(feature_pointer_file)"
  [ -f "$ptr" ] || { printf ''; return; }
  grep -m1 -v '^[[:space:]]*$' "$ptr" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Set SUSANOO_REPO_ROOT, SUSANOO_FEATURE_DIR, and SUSANOO_BRANCH from the environment or
# the pointer file. Pass "1" to skip persisting an env-provided path.
resolve_feature_paths() {
  local no_persist="${1:-0}"
  SUSANOO_REPO_ROOT="$(artifact_root)"
  SUSANOO_FEATURE_DIR=""
  SUSANOO_BRANCH=""

  local raw="${SUSANOO_FEATURE_DIRECTORY:-}"
  local ptr; ptr="$(feature_pointer_file)"
  local stored=""

  if [ -n "$raw" ]; then
    case "$raw" in
      /*) SUSANOO_FEATURE_DIR="$raw" ;;
      *)  SUSANOO_FEATURE_DIR="$SUSANOO_REPO_ROOT/$raw" ;;
    esac
    if [ "$no_persist" != "1" ] && ! no_persist_env; then
      persist_feature "$raw"
    fi
  elif [ -f "$ptr" ]; then
    stored="$(read_feature_pointer)"
    if [ -z "$stored" ]; then
      die "Feature directory not found. Set SUSANOO_FEATURE_DIRECTORY or ensure .susanoo/feature holds the feature path."
    fi
    case "$stored" in
      /*) SUSANOO_FEATURE_DIR="$stored" ;;
      *)  SUSANOO_FEATURE_DIR="$SUSANOO_REPO_ROOT/$stored" ;;
    esac
  else
    die "Feature directory not found. Set SUSANOO_FEATURE_DIRECTORY or run scripts/new_feature to create .susanoo/feature."
  fi

  SUSANOO_BRANCH="$(basename "$SUSANOO_FEATURE_DIR")"
}

# --- feature naming ---------------------------------------------------------

# Lowercase, map non-alphanumerics to "-", collapse runs, strip leading/trailing "-".
clean_slug() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | tr -s '-' | sed 's/^-//;s/-$//'
}

SUSANOO_STOP_WORDS="i a an the to for of in on at by with from is are was were be been being have has had do does did will would should could can may might must shall this that these those my your our their want need add get set"

is_stop_word() {
  printf '%s\n' "$SUSANOO_STOP_WORDS" | tr ' ' '\n' | grep -qx "$1"
}

# Derive a branch suffix from a description: drop stop words, keep words of 3+ characters,
# keep a short word only when it appears as an uppercase acronym in the original text.
# Cap at 3 words (4 when exactly 4 remain). Fall back to the first 3 cleaned parts.
branch_suffix_from_description() {
  local desc="$1"
  local lower w up n
  lower="$(printf '%s' "$desc" | tr '[:upper:]' '[:lower:]')"
  local words=()

  while IFS= read -r w; do
    [ -z "$w" ] && continue
    is_stop_word "$w" && continue
    n="${#w}"
    if [ "$n" -ge 3 ]; then
      words+=("$w")
    else
      up="$(printf '%s' "$w" | tr '[:lower:]' '[:upper:]')"
      if printf '%s' "$desc" | grep -qw "$up"; then
        words+=("$w")
      fi
    fi
  done <<< "$(printf '%s' "$lower" | tr -cs 'a-z0-9' '\n')"

  local count="${#words[@]}"
  if [ "$count" -gt 0 ]; then
    local max=3 i=0 out=""
    [ "$count" -eq 4 ] && max=4
    for w in "${words[@]}"; do
      [ "$i" -ge "$max" ] && break
      if [ -z "$out" ]; then out="$w"; else out="$out-$w"; fi
      i=$((i + 1))
    done
    printf '%s\n' "$out"
  else
    clean_slug "$desc" | cut -d- -f1-3
  fi
}

# Fit a feature number and suffix within GitHub's 244-byte branch-name limit.
fit_branch_name() {
  local num="$1" suffix="$2"
  local name="$num-$suffix"
  local bytelen
  bytelen="$(printf '%s' "$name" | LC_ALL=C wc -c | tr -d ' ')"
  if [ "$bytelen" -le 244 ]; then
    printf '%s\n' "$name"
    return
  fi
  local max_suffix=$((244 - ${#num} - 1))
  local trunc
  trunc="$(printf '%s' "$suffix" | head -c "$max_suffix" | sed 's/-$//')"
  printf '%s\n' "$num-$trunc"
}

# Highest existing sequential feature number (3+ digit dirs, skipping timestamp dirs).
highest_feature_number() {
  local dir="$1"
  local highest=0 name num
  [ -d "$dir" ] || { printf '0\n'; return; }
  for entry in "$dir"/*/; do
    [ -d "$entry" ] || continue
    name="$(basename "$entry")"
    printf '%s' "$name" | grep -Eq '^[0-9]{8}-[0-9]{6}-' && continue
    printf '%s' "$name" | grep -Eq '^[0-9]{3,}-' || continue
    num="${name%%-*}"
    num="$((10#$num))"
    if [ "$num" -gt "$highest" ]; then highest="$num"; fi
  done
  printf '%d\n' "$highest"
}

# True (0) when an existing spec directory already owns this numeric prefix.
spec_prefix_exists() {
  local dir="$1" num="$2"
  [ -d "$dir" ] || return 1
  local e
  for e in "$dir"/*/; do
    [ -d "$e" ] || continue
    case "$(basename "$e")" in
      "$num"-*) return 0 ;;
    esac
  done
  return 1
}
