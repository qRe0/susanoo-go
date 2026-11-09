---
name: plan
description: Use when writing the implementation plan — plan.md plus research.md, data-model.md, contracts/, quickstart.md — from a finished spec, with a Constitution Check gate and a verification matrix.
metadata:
  phase: planning
  flow-next: tasks
  flow-alternatives: [checklist]
  related: [architect, specify, tasks]
---

# Plan

Produces the implementation plan an engineer can execute with no hidden context. It does
not touch production code. It conforms to `specs/architecture.md` (which already applied the
smallest-solution ladder) and never invents package layout, persistence, router, generated
code placement, migration tooling, or test commands.

## Required reads

- `scripts/setup_plan --json` — resolves `FEATURE_SPEC`, `IMPL_PLAN`, `FEATURE_DIR`.
- `specs/MANIFEST.md`, `specs/architecture.md`, `specs/constitution.md`.
- `templates/plan-template.md`, `templates/research.md`, `templates/data-model.md`,
  `templates/quickstart.md`, `templates/contracts/README.md`.
- The feature `spec.md` and `requirements` scratch notes.

If `specs/architecture.md` is missing, stop and route to `architect` — the plan inherits
its package layout and commands.

## Fill the plan

Fill `plan-template.md`:

1. **Technical Context** — every line filled; mark a genuinely unknown value
   `NEEDS CLARIFICATION` for Phase 0 research to resolve.
2. **Constitution Check** — a gate that must pass before research; list each principle from
   `specs/constitution.md` and mark it satisfied or justify the violation in Complexity
   Tracking. Re-check after Phase 1.
3. **Global Constraints** — project-wide rules every task inherits, copied verbatim from
   the spec and constitution (version floors, dependency limits, naming rules).
4. **Review Focus** — the input classes or failure modes the spec implies but no test yet
   exercises; name each input/condition, the expected behavior, and the test that pins it.
5. **Project Structure** — pick one source-layout option, delete the others, and replace
   placeholders with real paths from `specs/architecture.md`.

## Phase 0 — research

Resolve every `NEEDS CLARIFICATION` in the Technical Context into `research.md`: Decision,
Rationale, Alternatives considered. Ground dependency choices in `go list -m` / `go doc`,
not memory.

## Phase 1 — design

1. `data-model.md` — entities, fields, validation rules from the spec's FRs, state
   transitions, and the storage mapping (table/collection names, not Go types or queries).
2. `contracts/` — API/event/DTO contract sources only when the feature has an external
   interface; skip for purely internal changes. (Ownership of a changed contract passes to
   `api` when it is substantial.)
3. `quickstart.md` — runnable validation scenarios with prerequisites, commands, and
   expected outcomes; reference contracts and data model instead of duplicating them.

## Verification matrix

List only the commands that apply, each with an expected result, and point at
`.claude/DOD.md` for the tiered gate:

| Change type | Required verification |
|---|---|
| Pure/domain logic | focused test + package test |
| HTTP handler | `httptest` handler test |
| gRPC/connectrpc | RPC handler test + status mapping |
| SQL/store | integration test or repository-standard DB test |
| Migration | apply/rollback/drift where available |
| Generated code | generator command + no stale diff |
| Concurrency | focused test + applicable race check |
| Dependency change | `go mod tidy` + explained `go.mod`/`go.sum` diff |

If any open question changes data shape, auth, integration behavior, or public API
compatibility, stop and route back to the user before implementation.

Then STOP with Context Summary + Next Steps.

## Common Rationalizations

- "I'll leave the Constitution Check as a stub." It is a gate, not a form; an unjustified
  violation must surface in Complexity Tracking or the plan is incomplete.
- "The storage choice is obvious, I'll skip research." Phase 0 exists to ground the choice
  in the repo's actual deps; a guess here becomes rework in `implement`.
- "I'll write the full handler code into the plan." The plan names files, commands, and
  risks; implementation detail belongs to `tasks.md` and the implement stage.

## Red Flags — STOP

- Inventing package layout or commands when `specs/architecture.md` is missing.
- A plan that leaves Technical Context values empty.
- A Constitution Check with an unjustified violation.
- Copying entity details into `quickstart.md` instead of referencing `data-model.md`.
