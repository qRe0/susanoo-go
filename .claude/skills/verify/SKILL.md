---
name: verify
description: Use before finishing a branch or claiming a task complete — run the tiered Definition of Done and report PASS/FAIL/PARTIAL with concrete evidence.
metadata:
  phase: quality
  flow-next: finish
  flow-alternatives: [coder, test-generator]
  related: [code-reviewer, finish]
---

# Verify

Runs the applicable `.claude/DOD.md` tier and reports a concrete pass/fail record backed by
fresh evidence — not a claim. Missing tools and skipped checks are labeled, not hidden.

## Determine the tier

Read `.claude/DOD.md` and choose the tier by risk: Minimum for docs-only/exploration,
Standard for normal implementation, Full for releases/merges or high-risk work. When unsure,
use Standard.

## Determine the command root

Read `specs/architecture.md`; detect `go.mod`, `go.work`, nested modules, or project
commands. Run from the documented root; for multi-module repos verify the affected module and
any repository-level command.

## Run the checks

Run every applicable check in the selected tier using the repository's documented runners
and configuration. Record the exact command, root, result, and evidence. The minimum is a
bare-`go test` trap: use `go test -race -count=1 -shuffle=on ./...` (or the repo's runner) —
a cached pass proves nothing.

Include the conditional checks that apply: generated-code no-stale-diff, migration
apply/rollback/drift, race, lint, dependency-hygiene (`go mod tidy && git diff go.mod
go.sum`), and the `writing-quality` scanners over generated prose (hard findings block).

Read the profile's TDD mode. If TDD applies, check the implementation handoff for observed
RED/GREEN/final-check evidence or a user-accepted exception; mark N/A when TDD did not
apply. Do not reconstruct historical RED from a currently-passing suite.

If `.claude/client/acceptance-criteria.md` holds team rules, run or record evidence for the
ones that apply; empty/missing means N/A — do not infer obligations.

## Missing tooling

Absent or unconfigured command → `N/A - not configured`. Cannot run due to environment →
`NOT RUN - <reason>`. Do not install tools during verify unless asked.

## Report

```markdown
## Verification Report

**Tier:** Standard
**Branch:** <branch>
**Command root:** <path>
**Result:** PASS / FAIL / PARTIAL

| Check | Status | Details |
|---|---|---|
| git status | PASS | only expected files changed |
| gofmt | PASS | no files listed |
| tests | FAIL | <pkg> has 1 failing test |
| race | NOT RUN | no concurrency changes |
| lint | N/A | not configured |

### Blocking Issues
- <fix items>

### Verification Gaps
- <commands not run and why>
```

## Result rules

- **PASS** — all required checks pass; N/A checks are genuinely not configured/relevant.
- **FAIL** — at least one required check fails.
- **PARTIAL** — required checks could not run because environment/tooling is unavailable.

Do not report PASS with unrun required checks. A failed check is fixed or escalated to
`systematic-debugger`; never reported complete with a known failing gate.

Then STOP with Context Summary + Next Steps (route FAIL/PARTIAL to `coder`/`test-generator`
or `systematic-debugger`; route PASS to `finish`).

## Common Rationalizations

- "The bare `go test` passed, so it's green." A cached pass may run zero tests; `-count=1`
  (plus `-shuffle`/`-race` where they apply) is the floor.
- "The tool is missing, I'll just mark PASS." A missing tool is `N/A - not configured`, not
  a pass.
- "TDD was selected but I only have a green suite." A green suite is not RED/GREEN evidence;
  mark the TDD check unmet or record the accepted exception.

## Red Flags — STOP

- Reporting PASS with unrun required checks.
- Treating an absent tool or an environment failure as PASS.
- Reconstructing a historical RED from a passing suite.
- Installing tooling during verify without being asked.
