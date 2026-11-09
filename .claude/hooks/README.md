# Susanoo Claude Code hooks

Four load-bearing hooks that protect the flow (wired via `.claude/settings.json`). They
are **enhance-only**: installing Susanoo merges them into the target repo's hook wiring,
never replacing existing hooks.

| Hook | Event | Purpose | Returns |
| --- | --- | --- | --- |
| `local-context.sh` | `SessionStart` | Print the Go project shape (module/workspace, tooling, specs/tasks) so a session starts grounded | always `0` |
| `file-naming-validator.sh` | `PreToolUse` `Write\|Edit` | Enforce AGENTS.md naming: stage-prefixed `.md` in `tasks/`, fixed names in `specs/` | `0` allow, `2` block |
| `bash-validator.sh` | `PreToolUse` `Bash` | Block destructive commands (force-push, `DROP/TRUNCATE`, `rm -rf`, `terraform destroy`, `kubectl delete`, …) | `0` allow, `2` block |
| `loop-detection.sh` | `PostToolUse` `Edit` | Detect edit doom loops; warn at 7 edits, block at 10 | `0` allow, `1` warn, `2` block |

## Hook return codes

| Code | Meaning |
| --- | --- |
| `0` | Success, continue |
| `1` | Warning, continue (logged) |
| `2` | Block the operation (shows the error to the user) |

## Naming rules enforced

`file-naming-validator.sh` checks `.md` files only (code and contracts pass through):

- **`tasks/`** — scratch files must be stage-prefixed `{stage}-{purpose}.md`; the kit-owned
  `tasks/README.md` is the exception. The 18 stage names plus internal/reference skill names
  are accepted.
- **`specs/`** — root holds only `README.md`, `MANIFEST.md`, `architecture.md`,
  `constitution.md`; per-feature folders hold the fixed artifacts (`spec.md`, `plan.md`,
  `tasks.md`, `research.md`, `data-model.md`, `clarifications.md`, `quickstart.md`) plus
  `contracts/` and `checklists/` (any checklist filename is accepted).

Both modes are covered: `specs/…` / `tasks/…` (in-repo) and `.susanoo/<project>/specs/…`
(root-folder).

## Dependency

The validators prefer `python3` to parse the hook JSON (the kit already depends on Python
for the `writing-quality` scanners). If `python3` is unavailable they fail open — the
naming validator and loop detector pass through, and the bash validator falls back to
scanning the raw input, which still catches every destructive substring.

## Tuning

Add narrowly scoped patterns to `bash-validator.sh` rather than broad command bans. The
authoritative stage list lives in the top-level `README.md`; the naming rules live in
`AGENTS.md` → File Naming.
