# Susanoo state area (root-folder mode)

This hidden directory holds Susanoo's **per-project state** in root-folder mode — the
artifacts the flow produces, kept out of the target repositories so those repos stay
clean of Susanoo's infra.

```
.susanoo/
  <project>/          # one state dir per driven repo
    specs/            # durable decisions: constitution, architecture, per-feature specs
    tasks/            # scratch space, safe to delete
    mode              # single line: in-repo | root-folder
    tdd               # single line: required | on-request | not-adopted | unresolved
    feature           # current-feature pointer (specs/<NNN>-<short-name>)
```

The `mode`, `tdd`, and `feature` files are written by `init` and the `scripts/` helpers;
they are plain text, one value per line. `specs/` and `tasks/` follow the same layout and
rules as in-repo inject — only the root moves.

Point the scripts at a project's state area by setting `SUSANOO_ROOT`:

```bash
export SUSANOO_ROOT="$HOME/susanoo/.susanoo/<project>"
```

This directory is a state area, not source — it is not committed and should be ignored by
any VCS you put the kit folder under.
