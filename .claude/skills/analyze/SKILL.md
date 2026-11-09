---
name: analyze
description: Use after tasks to run a read-only cross-artifact consistency check across spec.md, plan.md, tasks.md, and the constitution — flag drift, coverage gaps, ambiguities, and conflicts without writing any file.
metadata:
  phase: quality
  flow-next: verify
  flow-alternatives: []
  related: [tasks, plan, verify, converge]
---

# Analyze

Runs a mechanical, **read-only** consistency check across `spec.md`, `plan.md`, `tasks.md`,
and the constitution after task generation. It produces a report; it writes nothing and
modifies nothing. `converge` (after implementation) is the stage that turns gaps into tasks;
this stage only surfaces them before code.

## Resolve the feature

Run `scripts/check_prerequisites --json --require-spec --require-tasks --include-tasks` and
parse `FEATURE_DIR`. Read `spec.md`, `plan.md`, and `tasks.md` (required — if any is
missing, stop and name the prerequisite stage: `specify` for the spec, `plan` for the plan,
`tasks` for tasks). Read `specs/constitution.md` when it exists (a filled template is
binding; an unfilled template is skipped gracefully, not treated as empty rules).

## Build semantic models

Internal only — do not echo raw artifacts. Build: a requirements inventory (each `FR-###`,
`SC-###` that requires buildable work, and each user-story acceptance scenario as a stable
key); a user-story/action inventory; a task-coverage map (each task → the requirement/story
it serves, by ID reference or keyword); and the constitution's MUST/SHOULD statements.

## Detection passes

Run these, token-efficient, cap the report at 50 findings and summarize overflow:

- **Duplication** — near-duplicate requirements; flag the lower-quality phrasing.
- **Ambiguity** — vague adjectives ("fast", "scalable", "secure", "intuitive") without
  measurable criteria; unresolved placeholders (`TODO`, `TKTK`, `???`).
- **Underspecification** — requirements with a verb but no object or measurable outcome;
  user stories without acceptance-criteria alignment; tasks referencing files not defined in
  spec/plan.
- **Constitution alignment** — any requirement or plan element conflicting with a MUST
  principle (always CRITICAL); missing mandated sections or gates.
- **Coverage gaps** — requirements with zero associated tasks; tasks with no mapped
  requirement; buildable `SC-###` (performance/security/availability) not reflected in
  tasks.
- **Inconsistency** — terminology drift (same concept named differently), data entities in
  plan but absent in spec (or vice versa), task-ordering contradictions, conflicting
  requirements.

## Severity

- **CRITICAL** — violates a constitution MUST, missing a core artifact, or a requirement
  with zero coverage that blocks a P1 story.
- **HIGH** — duplicate/conflicting requirement, ambiguous security/performance attribute,
  untestable acceptance criterion.
- **MEDIUM** — terminology drift, missing non-functional task coverage, underspecified edge
  case.
- **LOW** — wording, minor redundancy not affecting execution order.

## Report

Emit a compact Markdown report (no file writes):

```markdown
## Specification Analysis Report

| ID | Category | Severity | Location(s) | Summary | Recommendation |
|----|----------|----------|-------------|---------|----------------|

## Coverage Summary
| Requirement Key | Has Task? | Task IDs | Notes |

## Constitution Alignment Issues
## Unmapped Tasks
## Metrics (requirements, tasks, coverage %, ambiguity, duplication, critical count)
## Next Actions
```

Constitution conflicts are CRITICAL and require adjusting spec/plan/tasks — never diluting
or ignoring the principle. Offer (do not apply) a remediation plan: "Would you like me to
suggest concrete edits for the top N issues?" Then STOP with Context Summary + Next Steps:
CRITICAL issues block `implement`; LOW/MEDIUM let the developer proceed with suggestions.

## Common Rationalizations

- "I'll fix the gaps inline while I'm here." This is a read-only stage; writing files is
  `specify`/`plan`/`tasks`/`converge`'s job, not this one.
- "No CRITICAL, so everything's fine." MEDIUM/HIGH findings still surface real drift; report
  them, don't bury them.
- "The constitution is an empty template, I'll skip it." Skip gracefully — do not invent
  principles from an unfilled template.

## Red Flags — STOP

- Writing to spec.md, plan.md, tasks.md, or any file during analysis.
- Inventing a requirement or section that is absent from the artifacts.
- Treating a constitution MUST violation as anything below CRITICAL.
- Running without tasks.md (this stage is defined to run after `tasks`).
