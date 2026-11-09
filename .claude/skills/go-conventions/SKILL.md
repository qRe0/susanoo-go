---
name: go-conventions
user-invocable: false
description: Use when writing or reviewing Go code to apply the canonical style conventions from .claude/conventions/.
metadata:
  phase: reference
  related: [coder, test-generator, code-reviewer]
---

# Go Conventions

An internal sub-skill that enforces the kit's single canonical source of Go style:
`.claude/conventions/` — `style.md` (the index of *which* rule, *when*) and `src/*.md`
(the rules). Pulled by `coder`, `test-generator`, and `code-reviewer`; it does not add a
stage or change the workflow. It is a **map and a procedure, not a second rule list**: the
rules live in `src/*.md`, and this file never restates them.

## How to apply

1. Identify the topic in the change or plan (error handling, a new struct, concurrency).
2. Open `style.md` and find the heading for that topic.
3. Load the `src/*.md` file(s) named under it, and apply them exactly as written.
4. Cite the source file in every finding (`error-wrap.md`). Load only the files the change
   touches — never paste the whole index into a review.

The checklist is `style.md`'s own section list, swept section-by-section against the diff:
Guidelines, Errors, Concurrency & goroutines, Lifecycle & exit, Types & assertions,
Performance, Style & naming, Structs & maps, Patterns, Linting. `style.md` is the
authoritative topic-to-file mapping; consult it rather than a memorized copy.

## Two halves, one finding

Conventions are enforced two ways; record both, don't merge them.

- **Machine half** — `golangci-lint` (`errcheck, goimports, revive, govet, staticcheck`).
  A clean lint run is necessary, not sufficient: it checks only what it is configured to.
- **Judgment half** — this sub-skill. Human-judgment rules (receiver ownership, table-test
  shape, `give`/`want` naming, panic policy) are not all lint-enforced.

A finding that cites neither a `src/*.md` file nor a linter rule is not a convention
finding — restate it as an observation or drop it.

## What this file does not cover

- **Structural decisions** (`context.Context` first, `%w` + `errors.Is`, injected clock,
  goroutine ownership, thin handlers) → `.claude/GOLDEN-PRINCIPLES.md`.
- **Project-specific placement and commands** → `specs/architecture.md`.
- **Verification gates** → `.claude/DOD.md`.

These are mirrored by reference from `.claude/conventions/`. Do not restate them here, and
do not create a competing style list in any downstream file.

## Common Rationalizations

- "It's a style nit, not a bug." A convention finding is still binding unless a higher
  source (`.claude/client/acceptance-criteria.md` or `specs/architecture.md`) overrides it.
  Grade the severity; don't dismiss the rule.
- "The linter passed, so it's clean." The linter is the machine half only; human-judgment
  rules are not all lint-enforced.
- "The surrounding file uses the old style." `consistency.md` is itself a rule, but new code
  follows the canonical rules; record the inconsistency as a finding rather than copying it.

## Red Flags — STOP

- A finding with no `src/*.md` (or linter) citation.
- Pasting the whole `style.md` index into a review.
- Inventing a new rule instead of citing an existing `src/*.md`.
- Restating a convention in `GOLDEN-PRINCIPLES.md`, `architecture.md`, or a DoD gate
  (mirrored-by-reference violation — that drifts into a competing list).
