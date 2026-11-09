# Stabilization Process — Error-to-Rule Cycle

When an agent makes a mistake that should never happen again, convert it into a permanent rule.

## 5-Step Cycle

```
1. ERROR occurs → 2. Identify ROOT CAUSE → 3. Create RULE → 4. Add EXAMPLE → 5. ENFORCE
```

### Step 1: Error Occurs
An agent produces incorrect output, violates a convention, or makes a mistake.

### Step 2: Identify Root Cause
Ask: "Why did the agent do this?" Common causes:
- Ambiguous instruction (soft wish instead of hard constraint)
- Missing context (agent didn't know about the convention)
- Wrong model level (task needed more reasoning than assigned model provides)

### Step 3: Create Rule
Write a MUST/MUST NOT rule in the appropriate file:
- **Global policy** → `AGENTS.md`
- **Structural Go decision** → `GOLDEN-PRINCIPLES.md`
- **Style convention** → `.claude/conventions/`
- **Skill-specific** → relevant `SKILL.md`

### Step 4: Add Example
Add a concrete correct/incorrect example near the rule:
```
MUST NOT: `tasks/task-001-2026-10-02-add-auth/requirements.md`
MUST:     `tasks/task-001-2026-10-02-add-auth/requirements-notes.md`
```

### Step 5: Enforce
Choose enforcement level:
- **Hook** (automated) — for rules that can be checked programmatically
- **Skill instruction** (semi-automated) — agent follows during execution
- **Review checklist** (manual) — verified during code review

## Template for New Rules

```markdown
### Rule: {Short Name}

**Trigger:** What error was observed?
**Root cause:** Why did it happen?
**Rule:** MUST/MUST NOT statement
**Example:**
- Incorrect: {bad example}
- Correct: {good example}
**Enforcement:** Hook / Skill instruction / Review checklist
**Added:** YYYY-MM-DD
```

## Example Stabilization Cycles

### Cycle 1: File Naming Convention

**Trigger:** Agent created `tasks/task-001-2026-10-02-add-auth/requirements.md` instead of a stage-prefixed name.
**Root cause:** Skill said "output requirements" but didn't enforce prefix naming.
**Rule:** MUST prefix scratch task files with the producing stage's name: `{stage}-{purpose}.md`
**Example:**
- Incorrect: `requirements.md`, `design.md`, `plan.md` in `tasks/`
- Correct: `requirements-notes.md`, `brainstorm-design.md`, `plan-notes.md`
**Enforcement:** `file-naming-validator.sh` hook (PreToolUse:Write|Edit)
**Added:** 2026-03-05

### Cycle 2: Task Directory Format

**Trigger:** Agent created an opaque task directory or invented a task number.
**Root cause:** The directory name did not convey the task or distinguish an externally supplied number from an allocated one.
**Rule:** Follow `AGENTS.md` and `tasks/README.md`: use `task-[number-if-supplied]-YYYY-MM-DD-brief/`; zero-pad supplied numeric IDs to at least three digits.
**Example:**
- Incorrect: `TASK-001/`, `task-1-2026-10-02-add-auth/` when ID 1 was supplied
- Correct: `task-2026-10-02-add-auth/`, `task-001-2026-10-02-add-auth/` when ID 1 was supplied
**Enforcement:** Skill instructions + tasks/README.md
**Added:** 2026-03-05

### Cycle 3: Proceeding with Failing Tests

**Trigger:** Coder agent claimed completion while tests were still failing.
**Root cause:** Skill had linear flow (test -> review) with no loop-back on failure.
**Rule:** MUST NOT proceed to completion with failing tests. Max 3 fix attempts, then escalate.
**Example:**
- Incorrect: Tests fail -> Mark complete -> Suggest `code-reviewer`
- Correct: Tests fail -> Read error -> Fix -> Re-run -> (repeat up to 3x) -> Escalate to `systematic-debugger`
**Enforcement:** Verify-fix loop in `coder` SKILL.md + `verify` stage
**Added:** 2026-03-05
