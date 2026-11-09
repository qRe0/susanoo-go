---
name: converge
description: Use after implement/verify to close the gap between the spec and the built code — append-only: classify each gap as missing/partial/contradicts/unrequested and append a Convergence phase to tasks.md.
metadata:
  phase: quality
  flow-next: finish
  flow-alternatives: []
  related: [verify, tasks, analyze, finish]
---

# Converge

Closes the gap between what `spec.md`/`plan.md`/`tasks.md` call for and what the code now
implements. It assesses the present state of the code relative to the artifacts — no git, no
diff, no history — and turns each remaining gap into a new, traceable task so `coder` can
finish it. It is **append-only**: its only write is a `## Phase N: Convergence` section
appended to `tasks.md`.

## Resolve the feature

Run `scripts/check_prerequisites --json --require-spec --require-tasks --include-tasks` and
parse `FEATURE_DIR`. Read `spec.md`, `plan.md`, and `tasks.md` (if any is missing, stop and
name the prerequisite stage). Read `specs/constitution.md` when present.

## Build the intent inventory

Internal only. One stable key per `FR-###`, `SC-###` (buildable work only — exclude
post-launch KPIs), user-story acceptance scenario (`US1/AC2`), plan decision, and
constitution MUST principle. Derive a code-scope map from the file paths named in
`plan.md`/`tasks.md` plus a keyword search for the concepts each requirement describes; do
not infer scope beyond what the artifacts define. Include every existing task regardless of
checkbox state — a completion claim is not evidence.

## Assess and classify

Inspect the current code in scope for each intent item and emit a finding only where there
is a gap, classified by gap type:

- **`missing`** — the required work is absent entirely.
- **`partial`** — the work exists but does not fully satisfy the requirement / criterion /
  decision.
- **`contradicts`** — the code conflicts with stated intent or a constitution MUST.
- **`unrequested`** — code not called for by the artifacts (surfaced for awareness; converge
  never deletes code — it appends a task to review/justify or remove it).

Edge cases: little or no code yet → treat the whole scope as `missing`; nothing remains →
zero findings and a "Converged" report, leaving `tasks.md` byte-for-byte unchanged.

## Assign severity

- **CRITICAL** — violates a constitution MUST, or a `missing`/`contradicts` gap blocking a
  P1 story.
- **HIGH** — `missing`/`partial` on a core functional requirement or acceptance criterion.
- **MEDIUM** — `partial` on a secondary requirement, or an `unrequested` addition with
  unclear justification.
- **LOW** — minor partial gaps, polish, low-risk `unrequested` additions.

## Present, then append

First emit a severity-graded summary (no file writes yet):

```markdown
## Convergence Findings
| ID | Gap Type | Severity | Source | Evidence | Remaining Work |

## Metrics (requirements checked, plan decisions checked, constitution checked, findings by type)
```

Then, if there are findings, append **only** to `tasks.md`:

```markdown
## Phase N: Convergence

- [ ] T### [US#] <remaining work, with source ref>
```

Use the next task ID and next phase number from the existing `tasks.md`; each new task
traces to a source ref (`FR-003`, `SC-002`, `US1/AC2`, `Constitution II`). Never modify
`spec.md` or `plan.md`; never rewrite, renumber, reorder, or delete existing tasks; never
touch application code. Completing the appended tasks is `coder`'s job.

Then STOP with Context Summary + Next Steps: route to `coder` (or `finish` if converged).

## Common Rationalizations

- "I'll just fix this small gap now." Converge only appends tasks; code changes are
  `coder`'s job through the normal implement loop.
- "The task is checked off, so it's done." A checkbox is not evidence; verify current
  behavior against the spec.
- "I'll clean up that unrequested code." Converge surfaces it as a review/remove task; it
  never deletes code itself.
- "Nothing to do — I'll add an empty Convergence header anyway." A converged result leaves
  `tasks.md` byte-for-byte unchanged.

## Red Flags — STOP

- Modifying `spec.md`, `plan.md`, existing tasks, or application code.
- Appending a Convergence phase with no findings.
- Classifying a gap without a source ref (`FR-###`, `SC-###`, `US#/AC#`, constitution).
- Running before `implement` has run on the current `tasks.md`.
