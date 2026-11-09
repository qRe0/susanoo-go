---
name: clarify
description: Use after specify to resolve the spec's open questions — a fixed taxonomy, up to five questions one at a time with a recommended option, answers recorded into specs/<NNN>/clarifications.md and folded back into spec.md.
metadata:
  phase: planning
  flow-next: plan
  flow-alternatives: []
  related: [specify, plan]
---

# Clarify

Resolves the spec's underspecified areas before planning, one question at a time. Every
answer is appended to `specs/<NNN>/clarifications.md` and folded back into `spec.md`, so
the audit trail and the tightened spec stay in lockstep. This stage tightens a spec; it does
not rewrite WHAT/WHY into HOW.

REQUIRED SUB-SKILL: `../writing-quality/SKILL.md` (soft gate — spec artifacts).

## Resolve the feature

Run `scripts/check_prerequisites --json --paths-only` and read `FEATURE_DIR`/`FEATURE_SPEC`.
If `spec.md` is missing, stop and route to `specify`. Read `specs/MANIFEST.md` and
`specs/architecture.md` (present = binding context; absent = do not invent it).

## Look before you ask

Before any question, `rg`/`grep` the code the feature touches and re-read the spec. Never
ask what the codebase or the spec already answers. Collect the spec's existing
`[NEEDS CLARIFICATION: …]` markers (max 3 from `specify`) as the seed list.

## The taxonomy

Classify each open area against this fixed taxonomy — it bounds what counts as a
clarification question:

1. **Scope** — what is in and out of this feature
2. **Data model** — entities, fields, relations, state, retention
3. **UX** — who does what, in what order, and what they see
4. **NFRs** — performance, security, availability, compliance
5. **Integrations** — external services, callbacks, auth, failure handling
6. **Edge cases** — empty, missing, duplicate, concurrent, partial-failure
7. **Constraints** — platform, deployment, regulatory, existing conventions
8. **Terminology** — overloaded or ambiguous domain words
9. **Completion signals** — what "done" and "correct" look like, measurably

## Ask up to five, one at a time

Ask **at most 5** questions, **one at a time**, each with a recommended option and a
one-line reason. Order by impact: scope > security/privacy > UX > data model > technical
detail. Do not front-load a list; wait for each answer. Skip a question entirely if the
answer is already unambiguous in the spec, and stop early when the remaining unknowns are
minor enough to assume.

## Record and fold back

After each answer:

1. **Append** to `specs/<NNN>/clarifications.md`:
   `- Q<n>: <question> → <chosen answer> (<reason>)`.
2. **Fold the decision back** into the relevant `spec.md` section (requirement, success
   criterion, edge case, or assumption) and clear the matching `[NEEDS CLARIFICATION]`
   marker.

If a question is genuinely unresolved (the developer declines to answer or says "you
decide"), record it as an Assumption with your chosen default, not as an answered question.

## Finish

Confirm no `[NEEDS CLARIFICATION]` markers remain (unresolved ones are now Assumptions).
Then STOP with Context Summary + Next Steps: route to `plan`. Note the clarifications file
path and the count of resolved questions.

## Common Rationalizations

- "I'll ask all five up front to save round-trips." A batch of questions front-loads answers
  the developer hasn't thought through; one at a time keeps each answer deliberate.
- "This is minor, I'll just fold it in without recording it." An unfolded decision has no
  audit trail; append to `clarifications.md` even for small answers.
- "The codebase answers it, but I'll confirm anyway." If the code or spec already answers,
  don't spend a question on it.

## Red Flags — STOP

- Asking more than five questions, or asking without a recommended option + reason.
- Rewriting spec.md's WHAT/WHY into implementation detail (that is `plan`'s job).
- Recording an answer in `clarifications.md` without folding it back into `spec.md`.
- Asking a question the codebase or spec already answers.
