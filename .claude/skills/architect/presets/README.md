# Architecture Presets

Concise starting points for `specs/architecture.md`. A preset names a shape plus the
default placement and tool choices for that shape, so `architect` can start from it and
then overwrite every line with what the repo actually has.

Rules for using presets:

- A preset is a shortcut, not an authority. The repo's own `go.mod`, `go.work`, build
  files, CI, and existing code always win over a preset line.
- Delete or correct every preset line that does not match the repo. Never ship a preset
  placeholder into `specs/architecture.md`.
- Record rejected options (the profiles and tools you did not pick) so the debate does not
  reopen without new evidence.

Available presets are one file per shape under this directory. Add a preset only when a
shape recurs often enough to justify the maintenance.
