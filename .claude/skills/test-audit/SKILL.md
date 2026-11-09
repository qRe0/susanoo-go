---
name: test-audit
user-invocable: false
description: Use when writing or reviewing Go tests, or when removing tests whose value or overlap is uncertain.
metadata:
  phase: reference
  related: [coder, test-driven-development, test-generator, code-reviewer]
---

# Test Audit

Use this reference inside the active stage. It does not add a command or change the
workflow. Apply the project API contract, selected TDD practice, and `.claude/DOD.md`
throughout.

## Before writing or changing a test

Answer these questions from the requirement, production boundary, and existing tests:

1. What observable behavior, invariant, or independently meaningful contract does this test protect?
2. What credible regression would make it fail for the intended reason?
3. Why would existing coverage miss that regression? Prefer extending a table-driven case to
   duplicating a scenario across layers; test another layer when it has a distinct risk, such
   as transport mapping or persistence.
4. Does the test require a production export, interface, flag, or hook with no production
   use? If so, test at the owning boundary where possible.

Reject assertion-free probes, self-comparisons, expected values computed by the code under
test, mocks that supply the behavior being asserted, and exact source-shape checks that break
under behavior-preserving refactors. Keep an apparent exception when it independently
protects a real contract, such as a public API, generated artifact, migration, security
boundary, or required byte/path. Do not weaken a required DoD test gate to avoid duplication.

For a bug regression, show that the test can fail for the bug when practical. When TDD is
selected, the observed behavior-driven RED/GREEN evidence is required by
`test-driven-development` and `.claude/DOD.md`. When TDD is not selected, do not claim a
historical RED or impose a TDD gate.

## Reviewing or removing existing tests

Review changed tests against the same questions. A test coupled to implementation or
overlapping another test is a candidate for improvement, not automatic deletion. Before
removing one, inspect the production owner, callers, neighboring tests, relevant history,
and CI routing. Identify the exact contract it protects, the stronger remaining proof or why
no proof is needed, and the focused check to run after the edit. Preserve tests for distinct
boundary risks and real regressions even when they are slow or use source inspection.

Report low-value tests as concrete findings: name the test, the behavior it actually detects,
the missed regression or overlap, and a safe correction. Run the applicable focused checks
and DoD tier after edits. Stop at the active skill's handoff.

## Common Rationalizations

- "It's just to keep coverage up." Coverage percentage is not value; a test that protects no
  contract is still nothing even when it turns a line green.
- "It overlaps another test but it's harmless." Overlap costs maintenance and suite time;
  report it as a finding and prefer extending one table-driven case to duplicating a scenario.
- "It's a slow integration test, so delete it." Slow tests that protect a real boundary or
  regression stay; remove only when a stronger proof remains.

## Red Flags — STOP

- An assertion-free probe, or a test that cannot fail for a real reason.
- An expected value computed by the code under test (self-comparison).
- A mock that supplies the exact behavior the test asserts.
- Adding or keeping a test purely to move a coverage number, with no named contract or regression.
