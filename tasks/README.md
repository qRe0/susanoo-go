# Task Documentation

This directory contains temporary, per-task documentation produced during a delivery workflow. Inputs may be user prompts, issue trackers, documents, specifications, repository files, or other explicitly named sources. A task directory groups one workflow run; its requirements document may decompose broad input into actionable implementation work.

`tasks/` is scratch space — safe to delete after delivery. Durable decisions go to `specs/` instead.

## Structure

Each task has a descriptive directory, for example `task-2026-10-02-add-auth/` or `task-001-2026-10-02-add-auth/` when a task number was supplied.

Task directories may contain stage-prefixed scratch files:
- `requirements-notes.md` — Facts/Assumptions/Open Questions (from `requirements`)
- `brainstorm-design.md` — design direction (from `brainstorm`)
- `plan-notes.md` — planning notes (from `plan`)

## Task Directory Names

Name new directories `task-[number-if-supplied]-YYYY-MM-DD-brief/`:

1. Use the creation date in ISO format and a short, descriptive lowercase kebab-case name from the confirmed task scope.
2. Include a number only when the user or source system supplied one. Zero-pad numeric IDs to at least three digits; do not invent or allocate an ID.
3. If the path exists for a different task, choose a distinct descriptive suffix. Reuse the existing directory when continuing the same task.

## When to Delete

Task directories are temporary. Delete them after:
- Implementation is complete
- Code is merged/deployed
- Team has reviewed the work

Keep task docs if you need delivery history. Otherwise, retain the original requirements in their source system and durable technical decisions in `specs/`.

## Living Specifications

For ongoing project documentation, see `specs/`:
- `specs/README.md` — living-spec lifecycle, ownership, and structure
- `specs/MANIFEST.md` — project overview and spec index
- `specs/constitution.md` — versioned governance
- `specs/architecture.md` — architecture profile (layout, dependency rules, tooling)
- `specs/<NNN>-<short-name>/` — per-feature specs (`spec.md`, `plan.md`, `tasks.md`, …)
