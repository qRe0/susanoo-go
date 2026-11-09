#!/usr/bin/env bash
# Susanoo — file naming validator (Claude Code PreToolUse hook).
#
# Enforces AGENTS.md → File Naming for `.md` files only:
#   - tasks/: scratch files MUST be stage-prefixed ({stage}-{purpose}.md)
#   - specs/: only the fixed canonical names (root living specs + per-feature artifacts)
# Everything else — code, contracts (.proto/.yaml), non-md files — passes through.
#
# Hook: PreToolUse, matcher "Write|Edit". Exit 0 = allow, 2 = block.
set -uo pipefail

INPUT="$(cat)"

# Extract file_path from the hook JSON. Fail open (pass-through) if python3 is missing
# or the input can't be parsed — naming is a guardrail, not a hard safety gate.
FILE_PATH="$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try:
    d=json.load(sys.stdin)
except Exception:
    sys.exit(0)
ti=d.get("tool_input") or d
fp=ti.get("file_path","") if isinstance(ti,dict) else ""
sys.stdout.write(fp)' 2>/dev/null)"

[ -n "$FILE_PATH" ] || exit 0

case "$FILE_PATH" in
  *.md) ;;
  *) exit 0 ;;  # only prose-bearing spec/task artifacts are name-checked
esac

# Normalize to a path relative to the artifact root (repo root, or .susanoo/<project>/).
P="${FILE_PATH#./}"
P="${P#"$PWD"/}"

# Locate the specs/ or tasks/ area and keep the part under it. Paths arrive as
# specs/…, tasks/… (in-repo) or .susanoo/<project>/specs/… (root-folder).
REL=""; AREA=""
case "$P" in
  *"/specs/"*) AREA=specs; REL="${P#*/specs/}" ;;
  specs/*)     AREA=specs; REL="${P#specs/}" ;;
  *"/tasks/"*) AREA=tasks; REL="${P#*/tasks/}" ;;
  tasks/*)     AREA=tasks; REL="${P#tasks/}" ;;
  *) exit 0 ;;  # outside specs/ and tasks/ — not our concern
esac

FILENAME="$(basename "$REL")"

if [ "$AREA" = "tasks" ]; then
  # Kit-owned index at tasks root; everything else must be stage-prefixed.
  [ "$REL" = "README.md" ] && exit 0

  # The 18 stages of the flow, plus internal/reference skills that may emit scratch notes.
  for NAME in \
    init constitution brainstorm requirements architect api specify clarify plan \
    checklist tasks worktrees implement analyze verify converge docs finish \
    coder code-reviewer test-generator test-driven-development tdd systematic-debugger \
    go-api go-data go-concurrency go-observability go-security go-cli go-composition \
    go-conventions ponytail test-audit writing-quality ; do
    case "$FILENAME" in
      "$NAME"-*) exit 0 ;;
    esac
  done

  echo "File naming violation: '$FILENAME' in tasks/" >&2
  echo "   Scratch files under tasks/ must be stage-prefixed: {stage}-{purpose}.md" >&2
  echo "   See AGENTS.md → File Naming." >&2
  exit 2
fi

# specs/: fixed names only.
if [[ "$REL" != */* ]]; then
  # Root living specs.
  case "$FILENAME" in
    README.md|MANIFEST.md|architecture.md|constitution.md) exit 0 ;;
    *)
      echo "File naming violation: '$FILENAME' at specs/ root." >&2
      echo "   specs/ root holds only: README.md, MANIFEST.md, architecture.md, constitution.md." >&2
      echo "   Per-feature artifacts go under specs/<NNN>-<short-name>/." >&2
      echo "   See AGENTS.md → File Naming." >&2
      exit 2 ;;
  esac
fi

# Reviewer-owned requirement-quality checklists may use any name.
case "$REL" in
  *"/checklists/"*) exit 0 ;;
esac

# Fixed per-feature artifacts inside specs/<NNN>-<short-name>/.
case "$FILENAME" in
  spec.md|clarifications.md|plan.md|research.md|data-model.md|tasks.md|quickstart.md) exit 0 ;;
  *)
    echo "File naming violation: '$FILENAME' in specs/$REL." >&2
    echo "   Per-feature artifacts use fixed names: spec.md, plan.md, tasks.md, research.md," >&2
    echo "   data-model.md, clarifications.md, quickstart.md (plus contracts/ and checklists/)." >&2
    echo "   See AGENTS.md → File Naming." >&2
    exit 2 ;;
esac
