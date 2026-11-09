#!/usr/bin/env bash
# Susanoo — edit-loop detector (Claude Code PostToolUse hook).
#
# Tracks edits per file per session to catch "doom loops" (repeatedly editing the same
# file without progress). Warns at 7 edits, blocks at 10.
#
# Hook: PostToolUse, matcher "Edit". Exit 0 = allow, 1 = warn (continue), 2 = block.
set -uo pipefail

INPUT="$(cat)"

# Extract file_path from the hook JSON. Fail open if python3 is missing or parsing fails.
FILE_PATH="$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try:
    d=json.load(sys.stdin)
except Exception:
    sys.exit(0)
ti=d.get("tool_input") or d
fp=ti.get("file_path","") if isinstance(ti,dict) else ""
sys.stdout.write(fp)' 2>/dev/null)"

[ -n "$FILE_PATH" ] || exit 0

TRACK_DIR="/tmp/susanoo-loop-detection"
mkdir -p "$TRACK_DIR"

# Stable per-path key, portable across md5sum (Linux) / md5 (macOS) / cksum.
if command -v md5sum > /dev/null 2>&1; then
  SAFE_NAME="$(printf '%s' "$FILE_PATH" | md5sum | cut -d' ' -f1)"
elif command -v md5 > /dev/null 2>&1; then
  SAFE_NAME="$(printf '%s' "$FILE_PATH" | md5 -q)"
else
  SAFE_NAME="$(printf '%s' "$FILE_PATH" | cksum | cut -d' ' -f1)"
fi
TRACK_FILE="$TRACK_DIR/$SAFE_NAME"

if [ -f "$TRACK_FILE" ]; then
  COUNT="$(cat "$TRACK_FILE")"
  COUNT=$((COUNT + 1))
else
  COUNT=1
fi
echo "$COUNT" > "$TRACK_FILE"

if [ "$COUNT" -ge 10 ]; then
  echo "BLOCKED: File '$FILE_PATH' edited $COUNT times this session." >&2
  echo "   This looks like a doom loop. Reassess the approach and confirm the root" >&2
  echo "   cause before editing again." >&2
  exit 2
elif [ "$COUNT" -ge 7 ]; then
  echo "WARNING: File '$FILE_PATH' edited $COUNT times this session." >&2
  echo "   If you're stuck in a loop, stop and root-cause before continuing." >&2
  exit 1
fi

exit 0
