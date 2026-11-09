# Susanoo Scripts

Shell ports of spec-kit's feature scripts, reduced to Susanoo's layout. A Go CLI replaces
these later (see the deferred list).

`install.sh` is the exception: it is the **in-repo inject installer** (a port of
go-accelerator's `install.py`), not a feature script. It takes `install`/`update`, a target
repo, and `--dry-run`/`--yes` — see the top-level [`README.md`](../README.md).

## Commands

| Script | Purpose |
|---|---|
| `new_feature` | Allocate the next `specs/<NNN>-<short-name>/` and seed `spec.md` |
| `setup_plan` | Copy `plan-template.md` into the current feature as `plan.md` |
| `setup_tasks` | Validate spec/plan and emit the tasks template for the tasks stage |
| `check_prerequisites` | Validate prerequisites and emit feature paths and available docs |

All four print JSON on stdout with `--json`; status and warnings go to stderr, so stdout
stays machine-readable.

## Layout

The scripts resolve two roots independently:

- **Artifact root** (`SUSANOO_ROOT`, default `$PWD`) holds `specs/`. In in-repo mode this
  is the repo root; in root-folder mode it is `.susanoo/<project>/`.
- **Kit root** is the parent of `scripts/`; it holds `templates/`. Override the templates
  location with `SUSANOO_TEMPLATES_DIR` (the installer may need this in in-repo mode).

## Current feature

The scripts locate the current feature from, in order:

1. `SUSANOO_FEATURE_DIRECTORY` (absolute, or relative to the artifact root)
2. `.susanoo/feature` under the artifact root, one line holding `specs/<NNN>-<short-name>`

`new_feature` writes that pointer after creating a directory, unless `SUSANOO_NO_PERSIST`
is `1` or `true`.

## JSON contracts

`new_feature --json`:

```json
{"BRANCH_NAME":"001-user-auth","SPEC_FILE":"/abs/specs/001-user-auth/spec.md","FEATURE_NUM":"001","FEATURE_DIR":"/abs/specs/001-user-auth"}
```

`setup_plan --json`:

```json
{"FEATURE_SPEC":"/abs/specs/001-user-auth/spec.md","IMPL_PLAN":"/abs/specs/001-user-auth/plan.md","FEATURE_DIR":"/abs/specs/001-user-auth","BRANCH":"001-user-auth"}
```

`setup_tasks --json`:

```json
{"FEATURE_DIR":"/abs/specs/001-user-auth","AVAILABLE_DOCS":["research.md","contracts/"],"TASKS_TEMPLATE":"/abs/templates/tasks-template.md","TASKS_TEMPLATE_CONTENT":"..."}
```

`check_prerequisites --json`:

```json
{"FEATURE_DIR":"/abs/specs/001-user-auth","AVAILABLE_DOCS":["research.md"]}
```

## Deviations from spec-kit

- No `.specify/` project tree; the artifact root is the repo root or `.susanoo/<project>/`.
- No layered template override stack yet; templates resolve from `templates/` only.
- The current-feature pointer is a plain text file, not JSON.
- The 244-byte branch-name fit truncates silently (the Go CLI can add full parity).
