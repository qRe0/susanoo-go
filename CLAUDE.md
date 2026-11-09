# Susanoo — Spec-Driven Development Kit

## Goal

Building a new **Spec-Driven Development (SDD) kit** (working name *Susanoo*): a set of
agent rules, skills, workflows, and templates that carry a feature from a written
spec through planning, implementation, and verification — for Go projects, drawing on
the structure of existing SDD tools but acting as our own product, not a fork.

This `susanoo-go/` folder **is the kit**. Its parent workspace (`../`) holds the cloned
upstreams and convention guides — read-only research input, not part of the product.
Target repos go under `susanoo-go/projects/` (root-folder mode, below).

## Operating modes (core rule)

Susanoo supports two ways of working with target repos. **CORE RULE in both: enhance,
never overwrite** — it integrates with and augments the target repo's existing Claude
Code / Codex / Cursor / etc. infra; it never replaces or clobbers it.

1. **In-repo inject** — install Susanoo *into* a target Git repo, additively merged with
   that repo's existing AI config. Existing skills/commands/hooks/CLAUDE.md/AGENTS.md are
   preserved; Susanoo adds its SDD stages on top and can update/remove itself cleanly.

2. **Root-folder** — Susanoo lives in a standalone folder (no Git repo) and drives
   multiple repositories under `projects/`. Its own state (specs, tasks, rulings) stays
   in a `.susanoo/` area, not inside the repos. Any touch of a repo still follows the
   enhance-only rule.

## Go conventions (in scope)

Go style conventions live in a dedicated `.claude/conventions/` folder — `src/*.md`
(the full rule set) plus `style.md` (the index of which convention to invoke, and when).
It is the single canonical source for Go style. A distilled `go-conventions` sub-skill
(triggered by `code-reviewer`, also used by `coder` and `test-generator`) consumes it.
The resulting rules are **mirrored by reference — never restated** across the required
files: `GOLDEN-PRINCIPLES.md` (structural Go decisions), `specs/architecture.md`
(project-specific rules), and the DoD gates — all pointing back to `.claude/conventions/`,
so no competing authority list can drift (per the Sources-of-Truth ladder).

## Writing quality (in scope)

An anti-slop guard for generated prose, vendored under `.claude/skills/writing-quality/`:
`SKILL.md` (the `writing-quality` sub-skill) + `scripts/` (deterministic scanners) +
`references/` (pattern catalog). Hard gate on READMEs/ADRs/changelogs/runbooks/commit
messages/PR bodies; soft gate on spec artifacts. Single-source / enhance-only rules apply;
attribution deferred to the top-level README. Shipped as `git-hooks/pre-commit` +
`git-hooks/commit-msg` — a slop gate on staged prose and commit messages, wired via
`core.hooksPath` (enhance-only).

## References already available

Reference clones live at the workspace root, one level up (`../` from this folder):

- `../go-accelerator/` — *our company's own tool*. A compact skill-based accelerator for
  structured Go delivery (agents, quality hooks, Go implementation guidance). Primary
  reference for house style and our existing conventions.
- `../spec-kit/` — GitHub's SDD toolkit. Processes (Spec-Driven Development, bug fixing,
  idea assessment) + reusable templates/primitives. Core reference for SDD structure.
- `../superpowers/` — spec-driven development *methodology* built on composable skills
  ("tease a spec out of the conversation" before coding). Reference for methodology flow.
- `../ECC/` — an "agent harness OS": plugins, commands, skills, workflows, MCP configs,
  multi-editor support. Reference for harness/plugin architecture.
- `../useful-libs/` — convention & style references (Go style guide, Standard Go layout,
  ponytail, no-ai-slop, unslop).

## Rules for this workspace

1. Do not modify files inside the cloned references (`../`) — they are upstream sources.
2. When asked to design/build the kit, first state which references you are drawing on,
   then reuse the relevant patterns rather than inventing from scratch.
3. All new kit artifacts belong under this `susanoo-go/` folder — keep them separate
   from the cloned reference repos.
