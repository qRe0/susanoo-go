---
name: ponytail
user-invocable: false
description: Use when choosing, planning, writing, fixing, or reviewing Go code to find the smallest solution that satisfies the confirmed requirements without weakening correctness or verification.
metadata:
  phase: reference
  related: [architect, coder, code-reviewer]
---

# Ponytail

An internal filter, pulled by `architect`, `coder`, and `code-reviewer`. The best code is
the code never written: solve the whole problem with the least new Go code. It does not add
a stage and does not replace `specs/architecture.md`, the selected API contract, or
`.claude/DOD.md` — brevity never substitutes for evidence.

## The ladder

Stop at the first step that fully satisfies the confirmed requirements:

1. Does this need to exist? Skip speculative work and name it in one line.
2. Does this codebase already solve it? Reuse the established helper, type, or pattern the
   way the surrounding code does.
3. Does the Go standard library solve it? Prefer it.
4. Does the platform already provide it? Use the native feature.
5. Does an installed dependency solve it? Reuse it before adding another; never add a
   dependency for a few lines.
6. Can one clear line solve it? Use one line when it stays correct and readable.
7. Otherwise, write the smallest complete solution.

## The smallest complete change

- **Scope is callers, not just the edit.** Before writing, list every place the change must
  reach — callers, tests, fixtures, config, exports — and what it could break for users.
  Extra features are not scope.
- **Bug: fix the shared cause once.** Grep every caller of the function you touch, then fix
  the root cause at its owning boundary; a tiny patch at the reported symptom is not simpler
  if sibling paths stay broken.
- **Deletion beats addition.** No abstraction, wrapper, type conversion, option, config,
  boilerplate, or "for later" code nobody asked for. Keep values in the form Go already
  gives you, and the layers the codebase already has.
- **The shortest working diff wins**, once you know everything it must touch. A one-liner
  that needs decoding is not short.
- **Comment only the why the code cannot show**, in one line.
- **One-test rule.** New non-trivial logic — a branch, a loop, a parser, money or security,
  or a whole new script — leaves one small test or an assert-based self-check. Trivial
  changes need none.
- **`shortcut:` ledger.** A deliberate simplification with a known limit gets a source
  comment in this form, so the limit is never a silent trap:
  `shortcut: <the limit>, <when to upgrade>`.
- Between equally small options, take the one that is correct on edge cases. Code you move
  or merge keeps its error handling and validation.

## Boundaries — never cut

Confirmed requirements, validation at trust boundaries, authorization, error handling that
prevents data loss, security, accessibility, the calibration real hardware needs, and
anything the user asked for. Preserve `specs/architecture.md` and the applicable API
contract; follow the selected TDD practice and every `.claude/DOD.md` gate.

Apply the ladder during architecture decisions, planning, and coding. At review, name
concrete code that can be removed or replaced while preserving the contract. Finish with
the active stage's Context Summary and Next Steps.

## Common Rationalizations

- "Make it configurable now — we'll need it later." Speculative flexibility is the first
  thing the ladder cuts; add the option when a requirement needs it.
- "Wrap it in an interface for testability." Add the interface at the consumer boundary when
  a test needs it; don't pre-build it next to every concrete type.
- "It's just one small abstraction." Small abstractions compose into a layer nobody asked
  for; reuse what exists or write the direct code.

## Red Flags — STOP

- A new dependency for behavior the standard library or an installed dependency already covers.
- A new file, package, interface, or config option with no real responsibility or boundary.
- Boilerplate, dead code, or a comment that only restates the code.
- Cutting any item in the "never cut" list to make the diff smaller.
