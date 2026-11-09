---
name: checklist
description: Use before tasks to generate requirement-quality checklists (unit tests for the spec's English) — reviewer-owned CHK### items that test completeness, clarity, consistency, measurability, and coverage.
metadata:
  phase: planning
  flow-next: tasks
  flow-alternatives: []
  related: [plan, specify, tasks]
---

# Checklist

Generates **requirement-quality** checklists — "unit tests for the requirements' English".
They validate how complete, clear, consistent, measurable, and covered the spec is; they do
**not** test whether the implementation works. They live under
`specs/<NNN>/checklists/` and are reviewer-owned.

## What a checklist item tests

- **Completeness** — are all necessary requirements present?
- **Clarity** — are terms and behaviors specific and unambiguous?
- **Consistency** — do requirements agree with each other and with the plan?
- **Measurability** — can a requirement be objectively verified?
- **Coverage** — are all scenarios and edge cases addressed?

An item asks about the *requirement*, not the behavior. Correct: "Is 'fast' quantified with
a specific threshold? [Clarity, Spec §SC-2]". Wrong: "Verify the endpoint returns 200."

## Resolve the feature

Run `scripts/check_prerequisites --json --template checklist-template` and parse
`FEATURE_DIR`, `AVAILABLE_DOCS`, and `TEMPLATE_CONTENT` (the canonical structure from
`templates/checklist-template.md`). Read `spec.md` (and `plan.md`/`data-model.md`/
`contracts/` when present) for the requirements being checked. Read `specs/constitution.md`
when it exists — a MUST principle is a checklist anchor, not a restatement.

## Derive the focus

From the feature's domain, risk indicators, and the spec's stated scope, choose one or more
focus areas — e.g. `requirements.md`, `api.md`, `security.md`, `ux.md`, `performance.md`,
`data.md`. If the developer supplied a focus, use it; otherwise infer the top one or two
from the spec. A `requirements.md` baseline (completeness/clarity/consistency/coverage) is
the safe default when no specific domain dominates.

## Generate the checklist

Write `specs/<NNN>/checklists/<domain>.md` following `TEMPLATE_CONTENT`: H1 title, purpose
and created meta, a review-ownership note, `##` category headings, and
`- [ ] CHK### <requirement-quality criterion>` items with globally incrementing IDs starting
at CHK001.

Rules:

- **Append-only**: if the file exists, append items continuing from the last `CHK###`; never
  delete, renumber, or replace existing items.
- **Leave every new item unchecked** (`[ ]`) — the checkbox state belongs to the reviewer,
  never to this skill.
- Each item references a spec section (`[Spec §FR-3]`) or a marker (`[Gap]`, `[Ambiguity]`,
  `[Conflict]`, `[Assumption]`, `[Traceability]`). Aim for ≥80% traceability.
- Group by requirement-quality dimension (Completeness, Clarity, Consistency, Acceptance
  Criteria Quality, Scenario Coverage, Edge Case Coverage, Non-Functional Requirements,
  Dependencies & Assumptions, Ambiguities & Conflicts).

Never start an item with "Verify", "Test", "Confirm", or "Check" + implementation behavior;
never reference code execution, "works properly", or click/render/execute actions.

## Report

Output the full checklist path, item count, focus area(s), and whether the run created or
appended. Then STOP with Context Summary + Next Steps: route to `tasks`. Note that
`implement` reads checklist checkbox state as a gate and must not modify markers.

## Common Rationalizations

- "I'll check the items off as I write them, they're obviously satisfied." Checkbox state is
  the reviewer's call; this skill only generates and appends unchecked items.
- "A checklist should verify the button works." That is implementation testing; a
  requirement-quality checklist tests whether the requirement is even written well.
- "I'll renumber the whole file to keep it tidy." Append-only; IDs are stable references.

## Red Flags — STOP

- An item that tests implementation behavior ("Verify the API returns 200").
- Marking any generated item `[x]`.
- Deleting or renumbering existing checklist content.
- Generating a checklist with no `spec.md` to check against.
