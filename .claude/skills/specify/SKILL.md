---
name: specify
description: Use when writing the feature specification at specs/<NNN>-<short-name>/spec.md: WHAT and WHY only — prioritized user stories, acceptance scenarios, FR/SC, edge cases, and assumptions.
metadata:
  phase: planning
  flow-next: plan
  flow-alternatives: [clarify]
  related: [requirements, plan, clarify]
---

# Specify

Writes the feature spec. The spec records **WHAT and WHY only** — no package names, no
types, no storage or transport choices. Those belong to `plan.md`.

REQUIRED SUB-SKILL: `../writing-quality/SKILL.md` (soft gate — spec artifact).

## Allocate the feature

Run `scripts/new_feature --json <feature description>` from the artifact root and parse
`FEATURE_DIR` and `SPEC_FILE`. It allocates the next `NNN`, derives a short-name, and
creates `specs/<NNN>-<short-name>/`. Do not invent the directory name or number.

## Write `spec.md`

Read `templates/spec-template.md` for the required structure, `specs/MANIFEST.md` and
`specs/constitution.md` for binding context, and the `requirements` scratch notes if they
exist. Then fill every mandatory section:

1. **User scenarios** — prioritized user stories (P1, P2, P3…). Each story is an
   independently testable slice: a `Why this priority`, an `Independent Test`, and
   Given/When/Then acceptance scenarios.
2. **Requirements** — `FR-###` functional requirements (each testable) and `Key Entities`
   when the feature involves data.
3. **Success criteria** — `SC-###`, user-facing, measurable, technology-agnostic.
4. **Edge cases** and **Assumptions**.

## Clarification discipline

Make informed guesses for unspecified details and record them under Assumptions. Mark only
the genuinely blocking unknowns with `[NEEDS CLARIFICATION: …]` — **max 3 per spec** — and
only when the choice changes scope/UX, has multiple reasonable readings, or has no default.
Prioritize: scope > security/privacy > UX > technical detail. Reasonable defaults (retention,
performance targets, auth method) are assumed, not asked.

## Quality validation

After writing, check against these and fix failures (max 3 passes, then record what
remains):

- No implementation detail (languages, frameworks, storage, transport).
- All mandatory sections completed; no empty placeholders.
- Requirements are testable; success criteria are measurable and tech-agnostic.
- Edge cases and assumptions are named; scope is bounded.

Index the spec artifact in `specs/MANIFEST.md`. Then STOP with Context Summary + Next
Steps, noting any remaining `[NEEDS CLARIFICATION]` markers for `clarify`.

## Common Rationalizations

- "I'll note the storage choice here so the plan is faster." HOW belongs to `plan.md`; a
  storage/transport mention in the spec is an implementation leak, not a shortcut.
- "This unknown is minor, I'll just pick one." Minor unknowns go to Assumptions; only
  scope/security/UX-changing unknowns get a marker.
- "Four clarification markers is close enough." Max three; drop the lowest-impact one.

## Red Flags — STOP

- Naming a package, type, storage, or transport in the spec.
- More than three `[NEEDS CLARIFICATION]` markers.
- Creating the feature directory by hand instead of `scripts/new_feature`.
- A user story with no Independent Test or no acceptance scenario.
