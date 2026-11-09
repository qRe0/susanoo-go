---
name: constitution
description: Use when creating or amending the project constitution at specs/constitution.md: versioned principles plus a MUST/MUST-NOT list that later stages read as the single authority.
metadata:
  phase: onboarding
  flow-next: requirements
  flow-alternatives: [brainstorm]
  related: [init, architect]
---

# Constitution

Writes the project-owned, semver-versioned rulebook at `specs/constitution.md`. Later
stages read it at runtime and treat a `MUST` violation as CRITICAL. This stage writes only
the constitution; it does not write specs, plans, or code.

REQUIRED SUB-SKILL: `../writing-quality/SKILL.md` (soft gate — spec artifact).

## Required reads

- `templates/constitution-template.md` — the required structure.
- `specs/MANIFEST.md` and `specs/README.md` — index and lifecycle.
- `AGENTS.md` — the Sources-of-Truth ladder; the constitution points at it and does not
  restate it.

## Scope guard

Classify every part of the input as constitution content or a separate, non-governance
intent. Feature implementation, code generation, refactoring, and deployment requests are
deferred — list them under `Next Actions`, do not execute them. If it is unclear whether an
instruction is governance, ask before changing anything.

## Write the constitution

1. If `specs/constitution.md` exists, load it and preserve still-applicable content; use the
   template as the structure, not as a wholesale reset.
2. Replace every placeholder with concrete text. Keep heading levels exactly as in the
   template. Remove guidance comments once filled.
3. Each principle: a short name, a paragraph (or bullets) of non-negotiable rules, and a
   rationale where the rule is not obvious. Prefer `MUST`/`MUST NOT` over vague language.
4. The `MUST / MUST NOT` section carries the enforceable invariants. These point at, and
   never restate, the `.claude/conventions/` Go-style rules and `.claude/GOLDEN-PRINCIPLES.md`.
5. The Governance section lists the amendment procedure, the versioning policy, and the
   compliance-review expectation.

## Versioning

Bump `CONSTITUTION_VERSION` per semantic versioning:

- **MAJOR** — backward-incompatible removal or redefinition of a principle.
- **MINOR** — new principle/section or materially expanded guidance.
- **PATCH** — clarification, wording, typo fix.

Set `RATIFIED` to the original adoption date (ask or mark `TODO` if unknown) and
`LAST_AMENDED` to today when anything changes. If a value is genuinely missing, write
`TODO(<FIELD>): explanation` and note it in the summary.

## Finish

1. Validate: no unexplained bracket tokens, version line matches the summary, dates are
   ISO `YYYY-MM-DD`, principles are declarative and testable.
2. Run the `writing-quality` soft gate: flag confirmed slop, fix the smallest edit, never
   "polish anyway" on a clean artifact.
3. Index `specs/constitution.md` in `specs/MANIFEST.md` (create the entry; never list a
   file that does not exist).
4. Report the new version, bump rationale, any `TODO` placeholders, and a suggested commit
   message (no tool attribution). Then STOP with Context Summary + Next Steps.

## Common Rationalizations

- "The template has five principles, so I need five." The number of principles is whatever
  the project actually governs; a placeholder principle left half-filled is worse than a
  shorter list.
- "A small wording tweak doesn't need a version bump." Every material change needs a PATCH
  at minimum, or the version stops being a reliable signal.
- "I'll also fix the spec while I'm here." Constitution-only scope; defer other intents.

## Red Flags — STOP

- Restating the Sources-of-Truth ladder from `AGENTS.md` inside the constitution.
- Restating Go-style rules that live in `.claude/conventions/` or `GOLDEN-PRINCIPLES.md`.
- Writing application source, specs, plans, or tasks from this stage.
- Leaving bracket tokens or `should`/`might` in the MUST list.
