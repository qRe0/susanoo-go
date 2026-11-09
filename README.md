# Susanoo

A Spec-Driven Development (SDD) kit for Go backend engineers — Go, SQL/NoSQL, DevOps.
It carries a feature from a written spec through plan → tasks → isolated worktree → TDD
implementation → review → verify → converge → docs → merge, gating each step on the Go
toolchain you already use.

Susanoo is **not** a fork. It composes proven patterns from several upstream SDD and
agent-harness tools into one coherent kit, Go-localized and reduced to a single,
dependency-ordered flow. See [Attribution](#attribution).

> **Core rule — enhance, never overwrite.** Susanoo integrates with a repo's existing AI
> infra (Claude Code / Codex / Cursor / …), never replacing or clobbering existing skills,
> commands, hooks, or config.

---

## Operating modes

One flow, two ways to host it. The mode is chosen and recorded at `init`; every stage,
rule, and gate is identical in both — only the artifact root moves.

| Mode | Where the kit lives | Where artifacts live |
|---|---|---|
| **In-repo inject** | installed *into* a target Git repo | `specs/`, `tasks/` at the repo root (commit alongside code) |
| **Root-folder** | a standalone Susanoo folder | `.susanoo/<project>/specs/`, `tasks/` (repos stay clean) |

---

## Install

### In-repo inject

Install the kit into an existing Git repository. The installer is additive and
receipt-owned: it copies its own namespaces, merges `.claude/settings.json` without
clobbering your values, seeds `specs/` + `tasks/` guides once, and records a SHA-256
receipt so `update` can tell its files from yours.

```bash
susanoo-go/scripts/install.sh install /path/to/your/repo
susanoo-go/scripts/install.sh update  /path/to/your/repo   # refresh later
```

Use `--dry-run` to see the full plan without writing, `--yes` to skip the confirmation
prompt. The managed payload is added to `.git/info/exclude` (local-only, not committed);
`specs/` and `tasks/` are committed. If a managed path already exists in the target, the
installer reports a conflict and refuses rather than overwrite.

Then adopt it in the repo:

```
/init          # profile the repo, record operating mode + TDD choice
/constitution  # write the versioned project governance
```

### Root-folder

Keep Susanoo in its own folder and drive multiple repositories from it:

```bash
git clone <susanoo> ~/susanoo
mkdir -p ~/susanoo/projects
git clone <your-repo> ~/susanoo/projects/<repo>
```

Set `SUSANOO_ROOT` to the per-project state area and run the same stages from within the
repo. Susanoo's state (`specs/`, `tasks/`, rulings) stays under
`~/.susanoo/<project>/`, not inside the repos.

---

## Quickstart

Once per repository:

```
init → constitution
```

Then, per feature:

```
brainstorm → requirements → architect → (api) → specify → clarify → plan → checklist
→ tasks → worktrees → implement (TDD + review) → analyze → verify → converge
→ (docs) → finish
```

The lightweight mandatory path is `requirements → architect → specify → plan → tasks →
worktrees → implement → verify → finish`. `brainstorm`, `clarify`, `checklist`, `api`,
`analyze`, and `converge` are gates you *can* run and frequently should, but they don't
block the pipeline unless you turn the gate on. `docs` runs on request.

Every step stops when it's done with a "Context Summary + Next Steps" handoff. Nothing
auto-chains.

---

## The flow at a glance

```
[once per repo]  init ─► constitution
                                  │
[per feature]  brainstorm ─► requirements ─► architect ─► (api) ─► specify ─► clarify
                                  │
        plan ─► checklist ─► tasks ─► worktrees ─► implement (TDD + review loop) ─► analyze
                                  │
                                 verify ─► converge ─► (docs) ─► finish
```

The artifact trail a feature leaves behind (in `.susanoo/<project>/` in root-folder mode):

```
specs/
  architecture.md            # living architecture profile (package/dependency/data rules)
  constitution.md            # versioned governance (once per repo)
  MANIFEST.md                # index of canonical specs + open cross-task decisions
  <NNN>-<short-name>/
    spec.md                  # WHAT/WHY: stories, acceptance, FR/SC, edge cases
    clarifications.md        # clarify Q&A audit trail
    plan.md                  # technical context, structure, review focus
    research.md  data-model.md  contracts/  quickstart.md
    tasks.md                 # ordered, story-traceable task list
    checklists/              # requirement-quality checklists (reviewer-owned)
tasks/                       # scratch space, safe to delete
```

`specs/` = durable decisions (commit). `tasks/` = per-task analysis (deletable).

---

## Skills

Each stage is one Claude-Code-native skill at `.claude/skills/<name>/SKILL.md`. Stages
are invoked explicitly; specialist and sub-skills are internal references pulled by
`implement` and `code-reviewer`.

### Once per repository

| Skill | What it does | Why it's needed |
|---|---|---|
| `init` | Profiles `go.mod`/`go.work`/tooling, establishes a green baseline, records the operating mode + TDD choice, creates the empty project-rules file | Wires the kit in without imposing a layout, and records the two decisions every later stage reads |
| `constitution` | Writes a semver-versioned `specs/constitution.md` (principles + MUST/MUST-NOT) | Gives later stages a single authority list to gate MUST violations as CRITICAL |

### Per-feature — mandatory path

| Skill | What it does | Why it's needed |
|---|---|---|
| `requirements` | Grounds the request in Facts / Assumptions / Open Questions, flags hallucination risk | Turns a vague ask into an explicit scope before any design |
| `architect` | Detects the repo's package/dependency/data/transport stack and writes the living `architecture.md` profile (recording rejected options) | Every downstream step conforms to one architecture profile instead of drifting |
| `specify` | Writes `spec.md` — prioritized user stories with Independent Test + Given/When/Then, `FR`/`SC`, edge cases, assumptions | Captures WHAT and WHY only, so implementation has no hidden intent |
| `plan` | Writes `plan.md` (+ research/data-model/contracts) with a Constitution Check and a Verification Matrix of input classes | Produces a plan an engineer can execute with no hidden context |
| `tasks` | Emits an ordered, parallelizable, story-traceable `tasks.md` (tests listed before implementation) | Turns the plan into verifiable, dependency-ordered work units |
| `worktrees` | Creates an isolated worktree/branch and confirms a clean baseline inside it | Keeps implementation off the integration branch until verified |
| `implement` | The coding loop: `coder` → `test-driven-development` (observed RED/GREEN) → `test-generator` → `code-reviewer` | Produces code per task with TDD discipline and per-task review |
| `verify` | Runs a tiered Definition of Done report (`go build`/`vet`, `go test -race -count=1 -shuffle=on`, lint, dependency hygiene) with PASS/FAIL evidence | Replaces "looks done" with recorded evidence before merge |
| `finish` | Runs the final suite and offers exactly merge / PR / keep-as-is | A clean, deliberate handoff — discard only on explicit confirmation |

The `implement` loop pulls four internal skills:

| Skill | What it does | Why it's needed |
|---|---|---|
| `coder` | Implements per the plan: package boundaries, handler/service pattern, generated-code rule, context/error handling | Keeps transport at the edge and generated code regenerated, not hand-edited |
| `test-driven-development` | Enforces observed RED then GREEN; no retroactive RED | Makes tests demonstrate the behavior first, not confirm code after the fact |
| `test-generator` | Writes table/httptest/testcontainers/goleak tests and race checks | Closes concrete coverage gaps with the right test form per layer |
| `code-reviewer` | Severity-graded review with two verdicts (spec compliance + code quality), fix loop capped at 5 | Catches drift before it compounds, without an unbounded loop |

### Per-feature — optional gates

| Skill | What it does | Why it's needed |
|---|---|---|
| `brainstorm` | Teases intent out one question at a time, lays out 2–3 approaches, gates on approval | Draws out *what* before code, when the ask is still rough |
| `api` | Designs the REST/RPC/event contract into `contracts/` before implementation | Pins the contract surface so code and review conform to it |
| `clarify` | Resolves open questions one at a time (≤5), folding answers back into `spec.md` | Removes ambiguity before it becomes rework |
| `checklist` | Generates reviewer-owned requirement-quality checklists (`CHK###`) | Tests the spec's English the way unit tests exercise code |
| `analyze` | Read-only cross-artifact consistency check (spec ↔ plan ↔ tasks ↔ constitution) | Catches drift and coverage gaps without writing anything |
| `converge` | Appends a `## Phase N: Convergence` gap analysis to `tasks.md` | Turns spec-vs-code gaps into more tasks, never a silent skip |

### On request

| Skill | What it does | Why it's needed |
|---|---|---|
| `docs` | Generates README/ADRs/changelog/runbook from `specs/` + source, hard-gated by `writing-quality` | Produces slop-free docs that track reality, only when asked |

### Go specialist skills (internal, pulled by `implement`/`code-reviewer`)

| Skill | Covers |
|---|---|
| `go-api` | HTTP/RPC handlers, middleware, DTOs, error mapping, routing |
| `go-data` | storage, SQL, migrations, transactions, data-access tests |
| `go-concurrency` | goroutines, channels, cancellation, race-sensitive code |
| `go-observability` | logging, metrics, tracing, health checks, diagnostics |
| `go-security` | auth, secrets, crypto, input parsing, webhooks, dependency safety |
| `go-cli` | cobra/flag design, config precedence, exit codes, signals |
| `go-composition` | package wiring, interfaces, constructors, dependency configuration |
| `systematic-debugger` | root-cause-before-fix for any bug or failing test |

### Shared sub-skills (internal filters)

| Skill | What it does | Why it's needed |
|---|---|---|
| `go-conventions` | Loads the canonical Go conventions (`.claude/conventions/`) as a review-keyed checklist | One style authority, mirrored by reference, never restated |
| `ponytail` | Minimalism ladder — smallest solution that satisfies confirmed requirements | Prevents over-engineering without weakening correctness |
| `test-audit` | Test-value gate: what contract does this test protect | Keeps tests meaningful, not just present |
| `writing-quality` | Deterministic slop scanners + no-op/preservation gates on prose | Hard gate on docs/commits/PRs so generated prose stays clean |

---

## Repository layout (this folder)

```
.claude/
  skills/          # all stage + specialist + sub-skills (SKILL.md each)
  hooks/           # session-start, naming, destructive-command, loop-detection hooks
  conventions/     # Go style guide (src/*.md + style.md index)
  DOD.md           # tiered Definition of Done
  GOLDEN-PRINCIPLES.md
  STABILIZATION.md
  settings.json    # permissions + hook wiring + attribution disabled
scripts/           # new_feature, setup_plan, setup_tasks, check_prerequisites, install.sh
templates/         # constitution/spec/plan/tasks/checklist/architecture + plan phases
git-hooks/         # pre-commit + commit-msg prose-slop gate (wired via core.hooksPath)
specs/  tasks/     # seed guides (installed once, project-owned after)
projects/          # root-folder mode: target repos live here
.susanoo/          # root-folder mode: per-project state area
```

---

## Attribution

Susanoo composes ideas from these sources. The Go style rules are vendored from the
Uber Go Style Guide, split into per-rule files under `.claude/conventions/`.

| Source | What Susanoo took |
|---|---|
| [Uber Go Style Guide](https://github.com/uber-go/guide) | Go conventions (`.claude/conventions/`), mirrored by reference across the kit |
| [github/spec-kit](https://github.com/github/spec-kit) | artifact schema + templates, clarify loop, append-only converge, feature scripts |
| [obra/superpowers](https://github.com/obra/superpowers) | brainstorming/HARD-GATE, two-verdict review + fix loop, finishing-branch |
| [affaan-m/ECC](https://github.com/affaan-m/ECC) | agent-harness / plugin architecture concepts |
| [theclaymethod/unslop](https://github.com/theclaymethod/unslop) | deterministic slop scanners (writing-quality) |
| [petergyang/no-ai-slop](https://github.com/petergyang/no-ai-slop) | editorial anti-slop rules (writing-quality) |
| [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | minimalism ladder + never-cut list |
| [golang-standards/project-layout](https://github.com/golang-standards/project-layout) | Standard Go Project Layout reference |
