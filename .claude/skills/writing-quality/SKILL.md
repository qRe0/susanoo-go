---
name: writing-quality
description: Remove AI-slop from generated prose (READMEs, package docs, ADRs, changelogs, commit messages, PR bodies, runbooks, spec artifacts) while preserving facts, meaning, and an impersonal voice. Load the deterministic scanners in scripts/ and apply the exact no-op + preservation gates before returning.
---

# Writing Quality

An internal sub-skill, invoked before any prose artifact is finalized. It de-slops prose
the kit generates. It is a **gate, not a vibe**: the scanners in `scripts/` are the
objective floor; the rules below are the judgment that confirms or drops each hit.

## When to invoke

- **Hard gate** — `documentation-generator` (README / ADR / changelog / runbook) and
  `finishing-branch` (commit message + PR body).
- **Soft gate** — `specify` / `clarify` / `plan` / `checklist` / `constitution` artifacts:
  technical prose where a word can be legitimate in context; flag, don't block.

## The contract (run in this order)

1. **Scan.** Run `scripts/banned_phrase_scan.py`, `scripts/structure_scan.py`,
   `scripts/silhouette_scan.py` on the artifact. A hit is a *candidate*, not a verdict.
2. **Confirm in context.** A quoted line, code span, domain term, or non-English text is
   not slop. Only a confirmed hit counts.
3. **Exact no-op.** Zero confirmed findings → return the artifact **byte-for-byte**. Never
   "polish anyway"; stop at matters of taste.
4. **Smallest repair.** Edit only the sentences with a confirmed hit; copy everything else
   unchanged. No structural rewrites.
5. **Preserve.** Every edit passes `scripts/validate_preservation.py` and
   `scripts/diff_check.py`: numbers, units, dates, names, URLs, citations, code spans, and
   force-bearing negations ("never", "must", "all") survive byte-exact. `$47.3M` is not
   `$47.3 billion`.

## Rules (distillate)

These decide whether a scanner hit is slop, and catch what the scanners miss.

- **Portability test.** If a sentence could move unchanged to another company, product, or
  language, it is filler — delete it or make it concrete (a fact, mechanism, number, or
  consequence).
- **Never fabricate voice.** Impersonal artifacts have no "I"/"we", no anecdotes, no perks.
  The doc voice is a careful engineer, not a brochure. See
  `references/personality-guide.md`.
- **No authorship verdicts.** Name the pattern and quote the line; never score or guess
  whether something is "AI-written."
- **Concrete verbs, concrete subjects.** "decided", not "made a decision"; the team/repo
  acted, not "the decision emerged."
- **Cut the flab.** Banned words (delve, foster, leverage, utilize, robust, …), binary
  contrasts, throat-clearing, "what nobody tells you" setups, colon reveals, `-ing`
  pseudo-analysis, importance puffery, weasel attribution, synonym cycling, dramatic
  fragments, fake-profound kickers, summary-recap endings. Full list in
  `references/taboo-phrases.md`.
- **End concrete.** Finish on a fact, takeaway, or next action — not a "deep" closing line.

## The catalog

- `references/taboo-phrases.md` — full pattern catalog (hard + soft); the seed for "cut the flab."
- `references/fact-preservation.md` — what must survive byte-exact and why; strict register
  for legal/medical/security text.
- `references/core-contract.md` — the two-pass rewrite + validation battery, in full.
- `references/rubric.md` — 8×5 scoring (self-check only; pass = 32/40).
- `references/personality-guide.md` — the "impersonal artifacts have no I/we" rule, in full.
- `references/rewrite-examples.md` — worked before/after examples.
