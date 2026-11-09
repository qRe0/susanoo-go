#!/usr/bin/env bash
# Susanoo — destructive-command blocklist (Claude Code PreToolUse hook).
#
# Blocks force-push, hard reset, destructive database/migration operations, package
# publishing, pre-commit bypass, and risky cloud/payment/kubernetes commands.
#
# Hook: PreToolUse, matcher "Bash". Exit 0 = allow, 2 = block.
set -uo pipefail

INPUT="$(cat)"

# Extract the command from the hook JSON. If python3 is missing or parsing fails,
# fall back to scanning the raw input — the destructive substrings are quote-free
# and still appear in the JSON, so a direct grep remains effective.
COMMAND="$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try:
    d=json.load(sys.stdin)
except Exception:
    sys.exit(0)
ti=d.get("tool_input") or d
c=ti.get("command","") if isinstance(ti,dict) else ""
sys.stdout.write(c)' 2>/dev/null)"
[ -n "$COMMAND" ] || COMMAND="$INPUT"

BLOCKED_PATTERNS=(
  "git push.*--force"
  "git push.*--force-with-lease"
  "git push[[:space:]].*-f([[:space:]]|$)"
  "git reset --hard"
  "git clean -f"
  "git clean -fd"
  "git clean -xfd"
  "git checkout .* -- "
  "git restore .*--staged"
  "git branch -D"
  "git worktree remove.*--force"
  "DROP TABLE"
  "DROP DATABASE"
  "DROP SCHEMA"
  "TRUNCATE TABLE"
  "DELETE FROM .*WHERE 1=1"
  "DELETE FROM [a-zA-Z0-9_]+;?$"
  "migrate .*drop"
  "goose .*reset"
  "goose .*down"
  "atlas schema clean"
  "atlas migrate down"
  "go env -w GOPRIVATE=.*"
  "go install .*@latest"
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \."
  "rm -rf \*"
  "rm -rf --"
  "--no-verify"
  "gh repo delete"
  "gh repo archive"
  "gh issue delete"
  "gh release delete"
  "gh api.*DELETE"
  "terraform destroy"
  "terraform apply.*-destroy"
  "terraform apply.*-auto-approve"
  "tofu destroy"
  "tofu apply.*-destroy"
  "tofu apply.*-auto-approve"
  "pulumi destroy"
  "pulumi up.*--yes"
  "kubectl delete"
  "kubectl apply.*-f .*prod"
  "helm uninstall"
  "helm upgrade.*--install.*prod"
  "aws .*delete"
  "aws .*terminate"
  "aws .*remove"
  "aws cloudformation delete-stack"
  "aws s3 rm .*--recursive"
  "gcloud .* delete"
  "gcloud .* remove"
  "az .* delete"
  "fly .* destroy"
  "heroku .*destroy"
  "stripe .*live"
  "stripe .*refund"
  "stripe .*cancel"
  "stripe .*delete"
  "stripe .*expire"
  "stripe trigger"
)

for PATTERN in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -Eqi -- "$PATTERN"; then
    echo "BLOCKED: destructive command detected: matches pattern '$PATTERN'" >&2
    echo "Command: $COMMAND" >&2
    echo "This operation is blocked. See AGENTS.md → Code Quality / Security." >&2
    exit 2
  fi
done

exit 0
