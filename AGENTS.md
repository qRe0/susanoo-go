# AGENTS.md — Policy Rules

These are enforceable rules. Wishes are ignored, constraints are enforced.

## Sources of Truth

This is the only precedence ladder in this repository. Every other document MUST point here instead of repeating the ordered layers. MUST NOT add a second authority list: competing lists can drift and give different answers depending on which document an agent reads.

| # | Layer | Lives in |
|---|---|---|
| 1 | **Project-specific hard rules, when present** | team-maintained `.claude/client/acceptance-criteria.md` |
| 2 | **Enforcement** — automated checks | [.claude/hooks/](.claude/hooks/), [git-hooks/](git-hooks/), CI, linters |
| 3 | **Policy** — MUST/MUST NOT rules | this file |
| 4 | **Architecture & governance** — durable decisions | [specs/](specs/README.md) (`constitution.md`, `architecture.md`, `MANIFEST.md`, per-feature specs) |
| 5 | **Operations** — how stages execute | [.claude/skills/](.claude/skills/) |
| 6 | **Documentation** — human reference | top-level [`README.md`](README.md) |

Lower number wins. `init` creates the project-owned `.claude/client/acceptance-criteria.md` as an empty file. The team adds hard rules there manually; agents MUST NOT populate or revise it unless explicitly requested. An empty or missing file adds no rules. When the file contains rules, read the relevant entries for the active stage and treat only those explicit entries as binding; never infer contractual terms from a client name, repository hint, or an external document that was not supplied. If a project rule conflicts with enforcement or another layer, report the mismatch for resolution; do not bypass the check in code. Reusable kit files mention the project file only conditionally and never contain client-specific terms.

`specs/constitution.md` (written by the `constitution` stage) is project-owned governance at tier 4: principles plus a semver-versioned MUST list. It MUST point here for precedence and MUST NOT restate this ladder. Go style conventions live in `.claude/conventions/` and are consumed by the `go-conventions` sub-skill; they are mirrored by reference — never restated — in `GOLDEN-PRINCIPLES.md`, `specs/architecture.md`, and the DoD gates.

## Operating modes (core rule)

Susanoo runs in one of two modes, both under one **CORE RULE — enhance, never overwrite**: it integrates with a repo's existing agent infra, never replacing or clobbering existing skills, commands, hooks, or config.

1. **In-repo inject** — Susanoo is installed into a target Git repo. Artifacts live in the repo (`specs/`, `tasks/`) and commit alongside code.
2. **Root-folder** — Susanoo lives in its own folder and drives repos under `projects/`. State (`specs/`, `tasks/`, rulings) stays under `.susanoo/<project>/`, not inside the repos.

The mode is chosen and recorded at `init`. Only the artifact root moves; every stage, rule, and gate is identical in both modes.

## File Naming

- MUST prefix scratch task files with the producing stage's name: `{stage}-{purpose}.md` (e.g. `requirements-notes.md`, `brainstorm-design.md`). These live under `tasks/`.
- MUST name new task dirs `task-[number-if-supplied]-YYYY-MM-DD-brief/`: include a supplied number only, zero-pad numeric IDs to at least three digits, and use a short lowercase kebab-case description. Examples: `task-001-2026-10-02-add-auth/`, `task-2026-10-02-add-auth/`. Do not invent or allocate an ID.
- MUST name new spec dirs `specs/<NNN>-<short-name>/`, where `NNN` is allocated by `scripts/new_feature` (the next available number) and `<short-name>` is a short lowercase kebab-case description.
- In `specs/`, the only allowed files are the fixed living specs at the root (`README.md`, `MANIFEST.md`, `architecture.md`, `constitution.md`) and the fixed artifacts inside `specs/<NNN>-<short-name>/` (`spec.md`, `clarifications.md`, `plan.md`, `research.md`, `data-model.md`, `tasks.md`, `checklists/`, `contracts/`). These names are canonical — do not skill-prefix them.
- MUST NOT create unprefixed `.md` files in `tasks/`. Preserve existing task directory names when continuing work.

## Agent Behavior

- MUST execute only its own stage, then STOP
- MUST NOT chain to other stages automatically
- MAY load an internal reference skill (e.g. `test-driven-development`) within the active stage when its documented condition applies; this does not advance to another workflow stage
- MUST output Context Summary + Next Steps
- MUST NOT make workflow decisions for the user
- MUST follow the stage flow below unless the user explicitly chooses a different path

## Commits

- MUST NOT add `Co-Authored-By: Claude ...` or other tool attribution to commit messages or pull request descriptions. `.claude/settings.json` disables Claude Code's automatic commit and PR attribution; do not add it manually.
- MUST describe the change in commit messages, not the process that produced it.

## Workflow Boundaries

- Once per repository: `init` → `constitution`.
- Per feature, the mandatory path is `requirements` → `architect` → `specify` → `plan` → `tasks` → `worktrees` → `implement` → `verify` → `finish`. The full 18-stage flow is documented in [`README.md`](README.md).
- Optional gates that do not block the pipeline unless turned on: `brainstorm`, `clarify`, `checklist`, `api`, `analyze`, `converge`. Run `api` only when the feature has a contract surface (API/event/DTO) to create or change. `docs` is on-request.
- `implement` runs the coding loop internally: `coder` (tests + implementation, or implementation only) → `test-driven-development` (observed RED/GREEN when TDD applies) → `test-generator` (coverage) → `code-reviewer` (isolated fork, two verdicts, fix loop capped at 5). Coverage gaps return to `coder`.
- TDD is governed by the user-approved practice in `specs/architecture.md` (recorded at `init`) or an explicit task request. Missing practice does not make TDD mandatory; `.claude/DOD.md` test gates still apply. `implement` uses `test-driven-development` only when TDD applies; without TDD, `coder` writes code only and hands test gaps or contract-aligned outdated assertions to `test-generator` with evidence.
- Specialist skills (`go-api`, `go-data`, `go-concurrency`, `go-observability`, `go-security`, `go-cli`, `go-composition`, `systematic-debugger`) and shared sub-skills (`go-conventions`, `ponytail`, `test-audit`) are internal references pulled by `implement`/`code-reviewer`/`test-generator`; they MUST NOT be presented as user-facing stages.
- `coder`, `test-generator`, and `code-reviewer` MUST apply `.claude/skills/go-conventions/SKILL.md` and `.claude/skills/test-audit/SKILL.md` when writing or reviewing Go code or tests. `architect`, `coder`, and `code-reviewer` MUST apply `.claude/skills/ponytail/SKILL.md` within their own stages. These are internal references, not extra workflow steps.

## Code Quality

- MUST run tests before claiming completion (if test tooling exists)
- MUST run lint before claiming completion (if lint tooling exists)
- MUST run `gofmt` on touched Go files before claiming completion
- MUST NOT claim completion with failing tests. Without TDD, `coder` may hand a test failure caused solely by an explicitly changed expected behavior to `test-generator` for a contract-aligned test update; unrelated failures MUST be fixed or escalated to `systematic-debugger` before proceeding.
- An isolated, behavior-driven RED observed during user-selected TDD is an expected intermediate state; resolve it before completion. Unrelated failures remain blockers.
- MUST NOT skip pre-commit hooks (--no-verify)
- MUST NOT force-push, hard-reset, or DROP TABLE without explicit user consent
- MUST NOT run destructive cloud, Kubernetes, Terraform/OpenTofu/Pulumi, Stripe, or payment operations without explicit user consent

## Context & Documentation

- MUST read existing code before modifying it
- MUST read `specs/MANIFEST.md` before writing specs
- MUST follow `tasks/README.md` when creating task dirs; do not allocate a number when none was supplied
- MUST NOT duplicate information across spec files — reference instead
- MUST keep analysis and unresolved questions in task documents; durable technical decisions belong in `specs/`
- MUST NOT rewrite source requirements to store conclusions, decomposition, or implementation decisions
- MUST NOT invent project-specific obligations or write them into `.claude/client/acceptance-criteria.md` without an explicit user request

## Security

- MUST NOT read or commit .env files or secrets/
- MUST NOT expose private repository names, customer data, internal URLs, access tokens, API keys, or proprietary package names to external documentation/search tools without explicit user consent
- MUST NOT run rm -rf, sudo, or chmod 777
- MUST NOT introduce OWASP Top 10 vulnerabilities
- MUST validate at system boundaries (user input, external APIs)
- MUST use parameterized SQL or established safe query builders for database access

## Definition of Done

- See [.claude/DOD.md](.claude/DOD.md) for the tiered verification checklist
- MUST reference DOD.md before marking any task complete

## Style Invariants

- See [.claude/GOLDEN-PRINCIPLES.md](.claude/GOLDEN-PRINCIPLES.md); detailed Go style rules live in `.claude/conventions/` and are consumed by the `go-conventions` sub-skill

## Communication Discipline

Applies to every agent and skill, regardless of active output style:

- MUST lead with the answer/recommendation — no preamble, no restating the request
- MUST recommend one path with a brief rationale, not enumerate every option unless asked
- MUST report actions by result with evidence, not narrate intentions
- MUST NOT pad with summaries of obvious work
- SHOULD prefer bullets/tables over long prose
