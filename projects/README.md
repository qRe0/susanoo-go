# Projects (root-folder mode)

In **root-folder** mode, Susanoo lives in its own folder and drives the target
repositories you clone under this directory. Each subdirectory is one project:

```
projects/
  <repo>/        # a normal Git repository — cloned, not modified structurally
```

Susanoo never writes its infra into these repos. Its state for a project — the
`specs/`, `tasks/`, and rulings that the flow produces — stays under
`../.susanoo/<project>/` (see `../.susanoo/README.md`). Any touch of a repo here still
follows the core rule: **enhance, never overwrite**.

To work on a project, clone it here and set the artifact root:

```bash
git clone <your-repo> projects/<repo>
export SUSANOO_ROOT="$HOME/susanoo/.susanoo/<repo>"   # where specs/ + tasks/ live
cd projects/<repo>
```

The 18-stage flow is identical to in-repo inject; only the artifact root moves.

> This directory is intentionally empty of code — it's the workspace boundary for the
> repos Susanoo drives.
