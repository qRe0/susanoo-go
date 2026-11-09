---
name: test-driven-development
user-invocable: false
description: Use within coder for Go behavior changes and bug fixes when specs/architecture.md requires TDD or the task explicitly opts in; guides observed RED, GREEN, refactor, and handoff evidence.
metadata:
  phase: execution
  related: [coder, test-audit, code-reviewer, verify]
---

# Test-Driven Development

An internal reference loaded by `coder`. It never imposes TDD on a project that did not
select it, and it does not start a new workflow stage — finish the active stage and STOP.

## Activation

Read `specs/architecture.md` and the task request. TDD applies when the profile says
`required` for new behavior or bug fixes, or the task explicitly opts in. `on request` /
`not adopted` with no opt-in creates no TDD obligation. If the profile has no TDD decision,
suggest `architect` record one; still follow the `.claude/DOD.md` test gates.

REQUIRED SUB-SKILL: `../test-audit/SKILL.md` — apply its value questions before selecting
a new or changed test.

## One behavior at a time

1. Read the requirement, neighboring code, tests, and the focused test command. Choose one
   observable behavior and the smallest useful test at the right boundary.
2. Write the test before changing production behavior. Run the focused command and observe
   RED. The failure must demonstrate the missing behavior — syntax, setup, dependency, and
   unrelated failures are not valid RED evidence; investigate those first.
3. Make the smallest production change that satisfies the test; observe GREEN on the same
   focused command.
4. Refactor keeping tests green; repeat for the next behavior.
5. Run the applicable broader `.claude/DOD.md` checks with the repo's runners.

For a pure refactor already protected by tests, establish a passing baseline and keep it
green — do not manufacture RED. For generated code, change the source and regenerate; never
hand-edit output to force GREEN. If a meaningful focused test cannot run, report the blocker
and seek a user-approved exception instead of inventing evidence.

## Handoff evidence

Include this block in `coder`'s Context Summary when TDD applied:

```text
TDD evidence
- Behavior:
- RED command and observed expected failure:
- GREEN command and observed pass:
- Refactor or baseline-only reason:
- Final check and result:
- User-accepted exception, if any:
```

Reviewers and `verify` check this evidence when TDD applies. Tests added by `test-generator`
after implementation improve coverage but do not retroactively prove a RED phase.

## Common Rationalizations

- "The test passed on the first run, that's still RED-ish." A test that never fails proves
  nothing; a missing-RED claim is weaker than an honest "baseline-only" record.
- "I'll run the whole package to be safe." A focused command isolates the behavior; a broad
  run muddies which change caused the pass.

## Red Flags — STOP

- Manufacturing a RED for a behavior already covered by a passing test.
- Treating a compile/setup failure as the RED.
- Imposing TDD on a project/task that did not select it.
- Claiming TDD compliance from a currently-passing suite with no recorded RED.
