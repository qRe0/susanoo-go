---
name: go-cli
user-invocable: false
description: Use when implementing or reviewing Go command-line tools — flag/cobra design, config precedence, exit codes, signals, and testable wiring.
metadata:
  phase: reference
  related: [coder, code-reviewer, go-composition]
---

# Go CLI

An internal reference pulled by `coder` and `code-reviewer` when the change touches a
command-line tool, admin command, batch job, or local developer tool. It does not add a
stage or change the workflow.

Read and follow `specs/architecture.md` before choosing command package placement,
dependency wiring, config precedence, or lifecycle behavior.

REQUIRED SUB-SKILLS: `../go-conventions/SKILL.md`, `../test-audit/SKILL.md`.

## First pass

Identify the CLI style before changing code: standard library `flag`, cobra, urfave/cli,
kingpin, or a project-specific framework; a single binary with subcommands, a service admin
command, a migration/worker command, or a one-off tool; interactive or automation-first UX.
Follow the existing framework unless the profile or task requires otherwise.

## Command design

- Keep flag parsing at the edge; business logic lives in testable packages.
- Use explicit config precedence: flags, environment, config file, defaults.
- Validate flags and config before any side effect.
- Provide stable exit codes for automation.
- Print machine-readable output only when requested or when the command targets scripts.
- Normal output to stdout; diagnostics and errors to stderr.

## Wiring and lifecycle

- Pass `context.Context` into command execution; handle cancellation and OS signals for
  long-running commands.
- Wire dependencies through explicit constructors; avoid global mutable state in command
  definitions.
- Share bootstrap code with the server/worker entrypoint where sensible.

## Safety

- Require confirmation or an explicit flag for destructive operations; support dry-run for
  high-risk admin tasks when practical.
- Never print secrets, tokens, full connection strings, or private data.
- Make environment selection obvious for production-affecting commands.

## Tests

- Test flag parsing and validation; test output and exit behavior with injected
  stdout/stderr buffers; test cancellation for long-running commands.
- Keep tests deterministic — no wall-clock dependence or reliance on local machine state.

## Common Rationalizations

- "It's just a script, no tests needed." A CLI with exit codes and side effects is exactly
  what automation depends on; test the parsing, output, and exit behavior.
- "I'll hard-code the config path." Config precedence (flags > env > file > defaults) is part
  of the contract; hard-coding it breaks operators.
- "Dry-run is overkill for now." A destructive admin command without dry-run is a footgun;
  add it before the command is used for real.

## Red Flags — STOP

- A destructive command with no confirmation, dry-run, or environment guard.
- Business logic embedded in a cobra/flag `Run` function instead of a testable package.
- Secrets or connection strings written to stdout or logs.
