---
name: code-reviewer
description: Use to review a task's implementation — a severity-graded review with two verdicts (spec compliance and code quality) and a fix loop capped at five rounds.
metadata:
  phase: quality
  flow-next: verify
  flow-alternatives: [coder, test-generator]
  related: [coder, test-generator, ponytail, go-conventions]
---

# Code Reviewer

Reviews a task's implementation in an isolated agent with a constructed brief — never the
session's history. Report findings first, ordered by severity; do not bury bugs under a
summary. The review is read-only; do not edit files.

REQUIRED SUB-SKILLS: `../go-conventions/SKILL.md`, `../test-audit/SKILL.md`,
`../ponytail/SKILL.md`.

## Required context

- `specs/architecture.md`, `.claude/GOLDEN-PRINCIPLES.md`, `.claude/DOD.md`.
- `../ponytail/SKILL.md` (concrete simplifications that preserve the contract) and
  `../test-audit/SKILL.md` (when reviewing changed tests).
- The task's spec/plan sections, the diff, and nearby tests.
- `specs/MANIFEST.md` and the indexed contract file(s) for API changes.

Treat the implementer's report as unverified claims — verify against the diff, and judge the
code on its merits; a stated rationale never downgrades a finding.

## Two verdicts

Issue both, separately:

1. **Spec compliance** — does the code implement the task's requirements and nothing more?
   - ✅ Spec compliant | ❌ Issues found (missing / extra / misunderstood, with file:line) |
     ⚠️ Cannot verify from diff (name what the controller must check).
2. **Code quality** — is the code correct, safe, idiomatic Go per the conventions? **Approved
   | Needs fixes**.

## Severity model

| Severity | Meaning |
|---|---|
| Critical | Data loss, auth bypass, secret leak, panic in normal flow |
| High | Incorrect behavior, race/leak, SQL injection, broken public API, unsafe migration |
| Medium | Missing edge test, unclear transaction boundary, maintainability risk |
| Low | Naming/docs/minor simplification that does not change behavior |

Block completion on Critical/High unless the user explicitly accepts the risk.

## Checklist

1. **Requirements/behavior** — implements confirmed requirements, not scope creep; edge
   cases covered; errors map to documented behavior.
2. **Architecture/packages** — code in the profile's package; no import cycles; framework/DB/
   generated types do not leak into domain; interfaces small and consumer-owned.
3. **Go correctness** — `context.Context` flows to I/O, never stored; errors wrapped and
   classified; no hidden global mutable state.
4. **Concurrency** — goroutines with owner/cancellation/error handling; shared state
   protected; no `time.Sleep` masking races.
5. **HTTP/RPC/API** — handlers decode→validate→authorize→call→encode; input validated; no
   IDOR; errors do not leak internals; contracts updated when the public API changes.
6. **Data/migrations/generated code** — parameterized queries; no N+1; explicit scoped
   transactions; migrations reviewed; generated files not hand-edited; `go.mod`/`go.sum`
   diffs expected and minimal.
7. **Security** — no secrets in code/fixtures/logs; strict auth when auth changes; no
   OWASP Top 10.
8. **Tests/tooling** — changed tests pass the `test-audit` value questions; meaningful tests
   at the right level; the Standard `.claude/DOD.md` tier has evidence; TDD evidence (RED/
   GREEN/final) present when TDD applies, with an accepted exception otherwise.
9. **Complexity/cleanup** — no single-use interfaces, package explosion, dead code,
   panics-as-flow, or weakened assertions.

## Output format

```markdown
### Spec Compliance
✅ / ❌ (with file:line) / ⚠️ (what to check)

### Code Quality
Approved | Needs fixes

### Strengths
<specific>

### Issues
#### Critical (Must Fix)
#### High (Must Fix)
#### Medium (Should Fix)
#### Low (Nice to Have)
<file:line — what's wrong, why it matters, how to fix>
```

## Fix loop

A round is one fix dispatch plus one scoped re-review. Cap at **5 rounds**. Record Minor
findings as deferred (never in the loop). Everything else enters the loop: the implementer
fixes, re-runs covering tests, and the re-review verdicts each finding ADDRESSED / NOT
ADDRESSED and flags only new breakage in the fix diff.

When round 5 still leaves findings open, stop dispatching and adjudicate each open finding
as a ledgered `Ruling:` line in `tasks/<task-dir>/code-reviewer-ledger.md`:

```text
Ruling: <finding> — <what you decided and why> — <what it costs if wrong>
```

- Reviewer wrong or contestable → park it; the final review sees both sides.
- Real but nothing downstream builds on it → park it as real and deferred.
- Real and load-bearing → rule the smallest change that unblocks dependent work and carry it
  forward.

Adjudicate only at the cap; every adjudication is a ledger entry — a silent discard is
forbidden.

Then STOP with Context Summary + Next Steps (do not advance to `verify`).

## Common Rationalizations

- "The linter passed, so it's clean." Lint is the machine half; human-judgment rules are not
  all lint-enforced.
- "It's just a style nit." A convention finding is binding unless a higher source overrides
  it; grade the severity, don't dismiss the rule.
- "The report is long enough, it must be thorough." Verdicts and findings with file:line are
  the product; length without citations is noise.

## Red Flags — STOP

- A finding with no file:line (or linter/convention citation).
- Trusting the implementer's report over the diff.
- Skipping the two-verdict split (a single merged verdict loses the spec/quality distinction).
- Adjudicating an open finding before round 5, or silently discarding one at the cap.
