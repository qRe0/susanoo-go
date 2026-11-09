---
name: finish
description: Use when implementation is complete and verified — run the final suite, detect the worktree/branch state, and present exactly the merge / PR / keep-as-is menu for the developer to choose.
metadata:
  phase: finalization
  related: [verify, converge, docs]
---

# Finish

Hands off a verified feature: run the final suite on the tree about to integrate, detect the
environment, and present exactly the merge / PR / keep-as-is menu. The integration decision
is the developer's; this stage only presents it and executes their choice. Discard is not on
the menu — it happens only in response to an explicit request, with typed confirmation.

REQUIRED SUB-SKILL: `../writing-quality/SKILL.md` (HARD gate — commit message + PR body).

## Step 1 — Verify on the real tree

Run the full suite on the tree about to integrate — `go test -race -count=1 -shuffle=on
./...` (or the repo's documented runner). A green run earlier this session is not evidence
for this tree. If it fails, report the failures and stop; the menu comes only after a green
suite. If `verify` already recorded a fresh DoD pass on this tree, cite it instead of
re-running blindly, but re-run when anything changed since.

## Step 2 — Detect the environment

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

Capture now — cleanup later changes directory. If not in a git repository, present the menu
without worktree cleanup and mark branch/worktree fields `N/A`.

| State | Menu | Cleanup |
|---|---|---|
| `GIT_DIR == GIT_COMMON` (normal repo) | 3 options | none |
| `GIT_DIR != GIT_COMMON`, named branch | 3 options | provenance-based |
| `GIT_DIR != GIT_COMMON`, detached HEAD | 2 options (no merge) | leave in place |

## Step 3 — Determine the base branch

The base is whatever this work forked from (named in the plan, conversation, or upstream).
If uncertain, ask — "This branch split from <best guess> — is that correct?" — before
merging; merging into the wrong base is expensive to undo.

## Step 4 — Present the menu

**Named branch / normal repo — exactly these three:**

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)

Which option?
```

**Detached HEAD — exactly these two:**

```
Implementation complete. You're on a detached HEAD (externally managed workspace).

1. Push as new branch and create a Pull Request
2. Keep as-is (I'll handle it later)

Which option?
```

Wait for the answer; the integration decision is theirs.

## Step 5 — Execute the choice

**Option 1 (merge locally):** from the main repo root, `git checkout <base>`, `git pull`,
`git merge <feature-branch>`, then re-run the suite on the merged result. A failing merged
result stops everything — branch and worktree stay in place. When green: clean up the
worktree (Step 6), then `git branch -d <feature-branch>`.

**Option 2 (push + PR):** `git push -u origin <feature-branch>` (from detached HEAD,
`git push origin HEAD:refs/heads/<new-branch>`), then create the PR against `<base>` with the
forge's tooling, following the repo's PR template. **The PR body must pass the
`writing-quality` scanners before posting** — confirmed slop is fixed first. Report the URL;
keep the worktree for PR-feedback iteration. Do not add any AI co-author attribution to the
PR body.

**Option 3 (keep as-is):** report "Keeping branch <name>. Worktree preserved at <path>."

## Step 6 — Cleanup (options 1 and confirmed discards only)

If `GIT_DIR == GIT_COMMON`, no worktree to clean. If `WORKTREE_PATH` is under
`.worktrees/`/`worktrees/`, this kit owns it: `git worktree remove "$WORKTREE_PATH"` then
`git worktree prune`. If removal is refused (untracked/modified files that exist nowhere
else), never `--force` on your own initiative — show the developer
`git -C "$WORKTREE_PATH" status --porcelain -uall` and ask (commit / move / delete). Any
other worktree belongs to the host — leave it in place.

## Discard (explicit request only)

Only when the developer asks to throw the work away. Confirm with the exact list of branch,
commits, and worktree path, then require the typed word `discard` before force-deleting
(`git branch -D`) and removing the worktree. `--force` on a worktree still never happens on
your own initiative.

Then STOP with a Context Summary: the decision, the recorded verification, and any
uncommitted changes or unresolved checks, named explicitly.

## Common Rationalizations

- "Tests passed earlier, I'll skip the re-run." A green run only proves the tree it ran on;
  run it on the tree you're about to integrate.
- "They obviously want it merged." Integration is the developer's decision — present the
  menu and wait.
- "'Yeah, get rid of it' counts as confirmation." Only the typed word `discard` authorizes
  deletion.
- "The worktree is clutter now that the PR is up." PR feedback gets fixed in that worktree;
  it stays until the work lands.
- "Removal refused — `--force` is just finishing the job." The refusal means files exist
  only there; show the developer and ask.

## Red Flags — STOP

- Presenting the menu before a green suite on the tree about to integrate.
- Offering "discard" as a menu option instead of only on explicit request.
- Force-deleting a branch or `--force`-removing a worktree without the developer's typed
  confirmation.
- Posting a PR body or commit message that fails the `writing-quality` scanners.
