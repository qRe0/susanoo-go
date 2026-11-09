#!/usr/bin/env bash
# Susanoo — session-start Go context injection (Claude Code SessionStart hook).
#
# Informational only: prints the Go project shape so a fresh session starts with the
# module/workspace/tooling reality already in view. Always exits 0.
set -uo pipefail

echo "Project Context"
echo "==============="

if git rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH="$(git branch --show-current 2>/dev/null || true)"
  STATUS="$(git status --short 2>/dev/null | wc -l | tr -d ' ')"
  echo "Branch: ${BRANCH:-detached} ($STATUS uncommitted changes)"
fi

if command -v go > /dev/null 2>&1; then
  echo "Go: $(go version 2>/dev/null)"
fi

if [ -f "go.work" ]; then
  echo "Workspace: go.work"
  WORK_MODULES="$(sed -n 's/^[[:space:]]*\.\///p' go.work | head -10 | tr '\n' ' ')"
  [ -n "$WORK_MODULES" ] && echo "Workspace modules: $WORK_MODULES"
fi

if [ -f "go.mod" ]; then
  MODULE="$(sed -n 's/^module //p' go.mod | head -1)"
  GOVERSION="$(sed -n 's/^go //p' go.mod | head -1)"
  echo "Module: $MODULE"
  [ -n "$GOVERSION" ] && echo "go.mod version: $GOVERSION"
else
  FIRST_MOD="$(find . -path './.git' -prune -o -path './.worktrees' -prune -o -name go.mod -print 2>/dev/null | head -1)"
  if [ -n "$FIRST_MOD" ]; then
    MOD_COUNT="$(find . -path './.git' -prune -o -path './.worktrees' -prune -o -name go.mod -print 2>/dev/null | wc -l | tr -d ' ')"
    echo "Module: none at repo root"
    echo "Nested go.mod files: $MOD_COUNT (first: $FIRST_MOD)"
  fi
fi

[ -f "Makefile" ] && echo "Build shortcuts: Makefile"
if [ -f ".golangci.yml" ] || [ -f ".golangci.yaml" ]; then
  echo "Lint: golangci-lint configured"
fi

for TOOL_FILE in sqlc.yaml sqlc.yml buf.yaml buf.gen.yaml Taskfile.yml Taskfile.yaml; do
  [ -f "$TOOL_FILE" ] && echo "Tooling: $TOOL_FILE"
done

for MIGRATION_DIR in migrations db/migrations internal/migrations; do
  [ -d "$MIGRATION_DIR" ] && echo "Migrations: $MIGRATION_DIR"
done

echo ""
echo "Structure:"
for DIR in cmd internal pkg api rpc proto migrations db scripts tasks specs examples .claude; do
  if [ -d "$DIR" ]; then
    COUNT="$(find "$DIR" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')"
    echo "  $DIR/ ($COUNT files)"
  fi
done

[ -f "specs/architecture.md" ] && echo "  -> architecture profile: specs/architecture.md"
[ -f "specs/constitution.md" ] && echo "  -> constitution: specs/constitution.md"

if [ -d "specs" ]; then
  FEATURES="$(find specs -maxdepth 1 -type d -name '[0-9]*-*' 2>/dev/null | wc -l | tr -d ' ')"
  LIVING="$(find specs -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
  echo "  Specs: $LIVING living spec(s) at root, $FEATURES feature folder(s)"
fi

if [ -d "tasks" ]; then
  TASK_COUNT="$(find tasks -maxdepth 1 -type d -name 'task-*' 2>/dev/null | wc -l | tr -d ' ')"
  echo "  Tasks: $TASK_COUNT"
fi

if [ ! -f ".claude/client/acceptance-criteria.md" ]; then
  echo "Project rules: file missing (run init)"
elif [ ! -s ".claude/client/acceptance-criteria.md" ]; then
  echo "Project rules: file empty (no extra rules recorded)"
else
  echo "Project rules: team-maintained rules present"
fi

exit 0
