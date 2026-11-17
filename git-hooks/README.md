# Susanoo git hooks

Two hooks that run the `writing-quality` deterministic scanners on what is about to be
committed. **Enhance-only**: they never overwrite your existing hooks — they're wired
alongside them.

| Hook | Scope | Behavior |
| --- | --- | --- |
| `pre-commit` | staged prose (`*.md`, `*.txt`, `*.mdx`, `*.rst`, `README*`, `CHANGELOG*`, `docs/**`) | hard gate — blocks on hard findings, warns on soft |
| `commit-msg` | the commit message | soft gate — warns, never blocks |

The scanner they call is `banned_phrase_scan.py` from the vendored
`.claude/skills/writing-quality/scripts/` set. Code files are deliberately not scanned
(only prose), to avoid false positives.

## Install — in-repo inject

Point the repo at a hooks dir that wraps these, so your own hooks keep running:

```bash
# 1. copy (or symlink) pre-commit and commit-msg into the repo, e.g. .githooks/
# 2. enable the directory for the repo
git config core.hooksPath .githooks
```

Or, to add just the scanner call without disturbing an existing hook, append the body
of `pre-commit` to the repo's own `.git/hooks/pre-commit`.

## Install — root-folder (multi-repo)

Set the scanner location once, and point each project's hooks at these scripts:

```bash
export SUSANOO_WRITING_SCRIPTS="$SUSANOO/.claude/skills/writing-quality/scripts"

git -C projects/<repo> config core.hooksPath "$SUSANOO/git-hooks"
```

`SUSANOO_WRITING_SCRIPTS` is an explicit override; when unset, the hooks fall back to
`<repo>/.claude/skills/writing-quality/scripts/` (the in-repo inject layout).

## Worktree state link (root-folder)

`post-checkout` runs on `git worktree add` and calls `scripts/link_worktree_state`, which
symlinks the gitignored `projects/*` and `.susanoo/*` entries from the primary worktree into
the new one. Without it, feature worktrees lack the cloned repos. Wire it for the kit repo:

```bash
git config core.hooksPath git-hooks
```

Or run `scripts/link_worktree_state <worktree-dir>` by hand. Existing paths are never replaced.

## Bypass

A hard-finding block is deliberately overridable so the gate is a guardrail, not a wall:

```bash
git commit --no-verify
```
