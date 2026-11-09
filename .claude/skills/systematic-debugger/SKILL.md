---
name: systematic-debugger
user-invocable: false
description: Use before proposing a fix for any bug, test failure, or unexpected behavior — root cause before fix, always.
metadata:
  phase: reference
  related: [coder, test-generator, code-reviewer]
---

# Systematic Debugger

An internal reference pulled by `coder` and `test-generator` when a bug, test failure, or
unexpected behavior blocks progress. It does not add a stage or change the workflow; after
the fix is verified, hand back to the invoking stage, which owns Context Summary + Next
Steps.

**Core principle:** find root cause before attempting any fix. A symptom fix is a failure.

REQUIRED SUB-SKILL: `../test-audit/SKILL.md` — apply its value questions to the regression
test you add. TDD (observed RED/GREEN) is governed by `coder` through
`../test-driven-development/SKILL.md`; add regression coverage regardless.

## The iron law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If Phase 1 is not complete, you cannot propose a fix.

## When to use

Any technical issue: test failures, production bugs, unexpected behavior, performance
problems, build failures, integration issues.

## Generated files

Any file this reference creates is a scratch task file and must be named
`systematic-debugger-<purpose>.md` under `tasks/<task-dir>/` (e.g.
`systematic-debugger-root-cause.md`), per the `AGENTS.md` file-naming rule. Never
`DEBUG_NOTES.md` or an unprefixed file.

## Phase 1 — Root cause investigation

Before attempting any fix:

1. **Read the error carefully** — the full message, stack trace, line numbers, file paths,
   and error codes.
2. **Reproduce consistently** — the exact trigger steps; if not reproducible, gather more data.
3. **Check recent changes** — `git diff`, recent commits, new dependencies, config changes.
4. **Trace data flow** — where the bad value originates and what passed it; keep tracing up
   until you find the source.

## Phase 2 — Pattern analysis

1. Find working examples of similar code in the same codebase.
2. Read the reference implementation completely — do not skim.
3. List every difference between the working and broken code, however small.

## Phase 3 — Hypothesis and testing

1. Form a single specific hypothesis: "X is the root cause because Y."
2. Test minimally — the smallest possible change, one variable at a time.
3. Verify before continuing: worked → Phase 4; did not → form a new hypothesis. Do not stack
   more fixes on an unverified one.

## Phase 4 — Implementation

1. Write the simplest failing regression test first.
2. Implement a single fix that addresses the root cause — no "while I'm here" improvements.
3. Verify: the test passes, no other tests broke, the issue is actually resolved.
4. If 3+ fixes fail, stop and question the architecture; discuss with a human before
   continuing.

## Common Rationalizations

- "The issue is simple, no process needed." Simple issues have root causes too.
- "It's an emergency." Systematic is faster than thrashing.
- "I'll write the test after the fix works." Untested fixes do not stick.
- "Fix multiple things at once to save time." You cannot tell which change worked.

## Red Flags — STOP

- "Quick fix now, investigate later."
- "Just try changing X and see."
- "Ship several changes and run the tests."
- "Skip the test, I'll verify by hand."
- "I don't fully understand it, but this might work."

Any of these means return to Phase 1.

## Quick reference

| Phase | Key activities | Success criteria |
|---|---|---|
| 1. Root cause | Read errors, reproduce, trace | Understand what and why |
| 2. Pattern | Find working examples, compare | Identify the differences |
| 3. Hypothesis | Form a theory, test minimally | Confirmed or new hypothesis |
| 4. Implementation | Add test, fix, verify | Bug resolved, tests pass |
