# Living Specifications

`specs/` contains canonical contracts and durable technical decisions that future work must follow. Temporary analysis, alternatives, and implementation planning belong in `tasks/<task-dir>/`.

This README is kit-owned guidance. `MANIFEST.md` and every project specification are project-owned data: installation and update workflows must not overwrite them.

## Two kinds of artifacts

`specs/` holds two kinds of durable artifacts.

**Living specs** at the root — repo-wide decisions that persist across features:

| File | Owner | Purpose |
|---|---|---|
| `README.md` | kit | This guide |
| `MANIFEST.md` | specs-writing stages | Existing spec index and cross-task open decisions |
| `constitution.md` | `constitution` | Versioned project principles + governance |
| `architecture.md` | `architect` | Module profile, package boundaries, dependencies, tooling, TDD choice |

**Per-feature specs** under `specs/<NNN>-<short-name>/` — one folder per feature, allocated by `scripts/new_feature`:

| Artifact | Owner | Purpose |
|---|---|---|
| `spec.md` | `specify` | WHAT/WHY: user stories, acceptance, FR/SC, edge cases |
| `clarifications.md` | `clarify` | Accumulated clarify Q&A trail |
| `plan.md` | `plan` | Technical context, data model, contracts, structure |
| `research.md` | `plan` | Phase-0 dependency/storage/build research |
| `data-model.md` | `plan` | Entities, tables, relations |
| `contracts/` | `api` | Protobuf / OpenAPI / event schemas |
| `tasks.md` | `tasks` | Ordered, story-traceable task list |
| `checklists/` | `checklist` | Requirement-quality checklists (reviewer-owned) |

`specs/<NNN>/tasks.md` (the task list) is a durable spec artifact. The `tasks/` directory is scratch space — see `../tasks/README.md`.

## Lifecycle

- Treat changes to living specs on a working branch as proposals; merge is the acceptance boundary.
- Update the existing canonical section instead of keeping competing versions of the same contract.
- Record each material addition or change under `### [{task-name}] <Decision> (YYYY-MM-DD)`.
- When a later task changes an existing section, update its body in place and retitle its heading to the latest task and date; Git preserves earlier attribution.
- Keep rejected alternatives and task-local reasoning in an optional stage-prefixed notes file under the task directory.
- Keep cross-task unresolved decisions only in `specs/MANIFEST.md`.
- Update `specs/MANIFEST.md` whenever a living spec is added or materially changed.

Task directories may be deleted after delivery. The current task label identifies the latest material change; Git preserves earlier attribution and accepted history.

## Loading And Ownership

Read `specs/MANIFEST.md` first, then load only the specifications relevant to the current task. The installer seeds this index; `init` reads it without editing it. `architect` creates or updates `specs/architecture.md` and indexes that file. `constitution` writes `specs/constitution.md` and indexes it. `api` writes contract sources under `specs/<NNN>/contracts/` and indexes them. The manifest lists existing files and cross-task open decisions; it does not duplicate the architecture profile or contract bodies. Verify that an indexed file exists before treating it as a contract; a missing file or missing entry means the contract is unavailable.

## Architecture Specification

Include confirmed values for:

- Go module path and Go version;
- runtime and deployment shape;
- repository layout and package ownership;
- dependency rules and forbidden imports;
- HTTP/RPC, data access, migration, generation, config, and observability conventions;
- testing and verification commands;
- the user-chosen TDD practice (`required`, `on request`, or `not adopted`), rationale, and focused test runner.

Never invent a module path. If `go.mod` is absent, record the missing decision in `MANIFEST.md` and route to `init`.

## Per-feature Specification

`specify` writes `spec.md` (WHAT/WHY only, no HOW). `plan` writes `plan.md` plus `research.md`, `data-model.md`, `contracts/`, and `quickstart.md`. `tasks` writes `tasks.md`. Artifact content is defined by the templates in `templates/` and the stage skills; this README only fixes names, owners, and placement.

## API Specification

`api` writes contract sources under `specs/<NNN>/contracts/` — protobuf (`.proto`), OpenAPI (`.yaml`), or event schemas — and indexes them in `MANIFEST.md`. Group contracts by module or API surface; include endpoints/RPC methods, schemas, validation, authorization, error semantics, pagination, compatibility, and contract tests. If the project already owns an OpenAPI or `.proto` contract, use and index that source instead of duplicating it.
