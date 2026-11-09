---
name: worktrees
description: Use after the task list exists, to isolate implementation in a git worktree on a clean baseline before any coding starts.
metadata:
  phase: execution
  flow-next: coder
  related: [tasks, coder]
---

# Worktrees

Prepares an isolated workspace (branch + worktree) so implementation never touches the
integration branch until verified. This stage prepares the workspace; it does not implement.

## Preflight

```bash
git rev-parse --show-toplevel
git status --short
git worktree list
```

If not in a git repository, stop and report that worktrees are unavailable. Do not discard
or move unrelated user changes. If the workspace is dirty, report it — worktree creation can
still proceed, but unrelated changes must not be included.

## Create the worktree

Branch naming: `feature/<name>` (or `fix/<name>` when clearly a bugfix). Lowercase,
hyphenated, short.

```bash
git worktree add <worktree-dir>/<feature-name> -b feature/<feature-name>
```

Directory priority: existing `.worktrees/` → `worktrees/` → preference in `CLAUDE.md`/`AGENTS.md`
→ ask. Verify the directory is git-ignored before creating worktrees inside the repo; ask
before editing `.gitignore`. If the branch already exists, ask before reusing it. Do not
force-delete branches or worktrees.

## Detect the Go shape

From the worktree root, find `go.mod`, `go.work`, nested modules:

| Shape | Command root |
|---|---|
| root `go.mod` | repo root |
| root `go.work` | repo root unless docs say otherwise |
| nested `go.mod` | module directory |
| multiple modules | documented task/module root |
| no Go files | report N/A, use project docs |

For multiple modules, identify the target module from `specs/<NNN>/tasks.md` or `plan.md`,
or ask.

## Baseline

Run `go build ./...` and the repository's documented test runner (or the DoD fallback)
inside the worktree. Record the exact command root and results.

- Green baseline → report ready.
- Red baseline → report the failing command and key error; ask whether to investigate or
  proceed with a known-red baseline.
- Missing tools → report `not run` and the missing command.

`go mod tidy` is not a baseline command; do not create dependency diffs before
implementation.

## Report readiness

```text
Worktree ready.
Path: <full path>
Branch: <branch>
Go shape: <root module | workspace | nested | multi-module>
Command root: <path>
Baseline:
- <command>: PASS / FAIL / NOT RUN
Next: coder <task context>
```

Then STOP with Context Summary + Next Steps.

## Common Rationalizations

- "A branch is enough, worktrees are overhead." The isolation point is a separate
  directory, not just a branch; without it, uncommitted work leaks across checkouts.
- "The baseline failed but I'll fix it while implementing." A red baseline must be a
  conscious, accepted starting point, never silently inherited.
- "I'll just create the worktree in the repo without checking ignore rules." An unignored
  worktree directory pollutes the integration repo.

## Red Flags — STOP

- Discarding or moving unrelated user changes.
- Deleting worktrees or branches, or reusing an existing branch without confirmation.
- Running `go mod tidy` or installing tools as part of baseline.
- Proceeding from a red baseline without the user accepting that risk.
