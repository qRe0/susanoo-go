---
name: requirements
description: Use when turning user/client input into grounded requirements: separate facts, assumptions, open questions, and out-of-scope, with acceptance criteria and a hallucination-risk flag.
metadata:
  phase: understanding
  flow-next: architect
  flow-alternatives: []
  related: [specify, architect]
---

# Requirements

Turns rough input into source-grounded requirements. Never expands vague input into
implementation scope without labeling assumptions and open questions, and never chooses
libraries here — tech choices belong to `architect`.

## Output

Primary output: `tasks/<task-dir>/requirements-notes.md` (scratch). If no task context is
supplied, create a descriptive task directory per `tasks/README.md`; do not allocate a
number. Durable decisions later move to `specs/` via `specify`; this file stays scratch.

## Required reads

- The user prompt and any linked docs/transcripts.
- `specs/MANIFEST.md`, and `specs/architecture.md` if present.
- Relevant existing task docs and repository files the feature touches.
- `.claude/client/acceptance-criteria.md` when it holds team rules (empty/missing means no
  additional rules — do not infer them).

Ground facts in the code: grep affected packages and run `go list -m` for dependency
reality before stating anything as fact.

## Source grounding

Classify every important statement, and do not merge the categories:

| Label | Meaning |
|---|---|
| **Fact** | Directly supported by a source; cite the source or a quote pointer |
| **Assumption** | Reasonable inference; mark confidence and a validation path |
| **Open question** | Missing or contradictory; ask before planning if it changes behavior |
| **Out of scope** | Explicitly excluded or deferred |

If a requirement depends on an assumption, its acceptance criterion says so.

## Hallucination-risk controls

Flag risk when: the source states only a broad goal; AI-generated docs are the only source;
an integration is named without auth/callback/retry/idempotency/test-mode/ownership;
sources disagree; code differs from written specs; a feature was discussed but never
accepted. When risk is high, add a `## Hallucination Risk` section and route unresolved
scope to the user before `architect`.

## Output template

```markdown
# Requirements: <Feature>

**Task:** {task-name}
**Sources:** <files/prompts/transcripts>

## Confirmed Requirements
- <grounded fact>

## Acceptance Criteria
- [ ] <observable behavior>

## Technical Impact
| Area | Expected impact |
|---|---|
| API | <routes/contracts or none> |
| Packages | <likely packages, if known> |
| Data | <schema/model changes or none> |
| Config | <none> |
| Observability | <none> |
| Security | <auth/tenant rules> |

## Facts vs Assumptions
| Item | Type | Source | Confidence | Validation needed |

## Gap Analysis
- Missing / conflicting information

## Hallucination Risk
<low/medium/high and why>

## Open Questions
- <question blocking implementation>

## Out Of Scope
- <explicitly excluded behavior>
```

## Rules

- Separate facts from assumptions; source-link or source-name every major requirement.
- Put decisions needed to close gaps in Open Questions; keep floating ideas out of scope.
- For integrations, name credentials, callbacks/webhooks, retries, idempotency, failure
  handling, test mode, and operational ownership.
- Do not let inferred implementation details become requirements.
- Do not choose Go libraries here unless a requirement forces a constraint.

## Common Rationalizations

- "I'll fill in the gaps so the spec is complete." Filling a gap is an assumption; an
  unlabeled assumption becomes a phantom requirement downstream.
- "The repo name implies this behavior." Repository hints are not requirements; trace to a
  source or mark as assumption.
- "A broad goal is enough to start." A broad goal with no acceptance criteria is exactly
  the hallucination-risk case; flag it instead of inventing detail.

## Red Flags — STOP

- Merging facts and assumptions into one list.
- Writing implementation detail (packages, libraries, storage choices) into requirements.
- Treating AI-generated text as the sole authority when the original artifact is missing.
- Recording a TDD choice or architecture decision here — those live in `architect`.
