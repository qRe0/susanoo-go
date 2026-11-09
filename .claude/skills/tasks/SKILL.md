---
name: tasks
description: Use when breaking a finished plan into a dependency-ordered, parallelizable, story-traceable task list at specs/<NNN>-<short-name>/tasks.md.
metadata:
  phase: planning
  flow-next: worktrees
  flow-alternatives: []
  related: [plan, specify, worktrees]
---

# Tasks

Generates `tasks.md`: a dependency-ordered task list grouped by user story so each story
can be implemented, tested, and delivered on its own.

## Setup

Run `scripts/setup_tasks --json` and parse `FEATURE_DIR`, `AVAILABLE_DOCS`, and
`TASKS_TEMPLATE_CONTENT`. Read from the feature dir: `plan.md` and `spec.md` (required);
`data-model.md`, `contracts/`, `research.md`, `quickstart.md` (when present).

## Format

Every task follows exactly:

```text
- [ ] T### [P] [US#] Description with exact file path
```

- `T###` — sequential, zero-padded (`T001`, `T002`).
- `[P]` — only when parallelizable (different files, no dependency).
- `[US#]` — required on user-story phases; absent on Setup, Foundational, and Polish.
- The description names the exact file path from `specs/architecture.md`.

Tests are listed **before** the implementation they cover, inside the same story, so they
can fail first. Include test tasks only when the recorded TDD practice (`specs/architecture.md`)
requires them or the spec asks for them; otherwise leave test work to the implement loop.

## Phases

1. **Phase 1 — Setup**: module init, package layout, formatting/linting config.
2. **Phase 2 — Foundational (blocking)**: core infrastructure every story depends on
   (schema/migrations, router/middleware, config/logging, base types). No story work begins
   until this phase completes.
3. **Phase 3+ — one phase per user story**, in priority order (P1, P2, …): story goal,
   Independent Test, tests (if TDD), then types → services → handlers, with `[US#]` labels.
   Quote data-model field constraints verbatim in the task that enforces them.
4. **Final phase — Polish & cross-cutting**: docs, cleanup, missing tests, end-to-end
   `quickstart.md` validation.

Within a story, tests fail first, types before services, services before handlers, and the
story completes before the next priority begins.

## Dependencies & execution order

- Setup → Foundational → user stories in priority order (or parallel when staffed) → Polish.
- `[P]` tasks touch different files with no dependency.
- Every user story is independently completable and testable; no cross-story dependency
  breaks that independence.

## Validate

Confirm: all tasks use the checklist format with a file path; every user story has its
Independent Test; every data-model constraint is quoted in an owning task; no vague tasks
("implement billing"). Then STOP with Context Summary + Next Steps (task count, story
breakdown, suggested MVP scope = User Story 1).

## Common Rationalizations

- "Tests can come after implementation to save a pass." Under TDD, tests-before-fail is the
  point; listing them after breaks the observed-RED requirement.
- "One big task is simpler than several." A task that cannot be verified independently is
  not a task; split it to the smallest behavior slice.
- "The constraint is in the data model, no need to repeat it." The task that enforces a
  constraint must quote it, or it is left to implementation-time discretion.

## Red Flags — STOP

- A task without `[US#]` in a user-story phase, or with a `[US#]` in Setup/Polish.
- Tasks before the Foundational phase completes (dependency violation).
- A task with no file path, or a vague task like "implement billing".
- Reordering tasks so a user story is not independently completable.
