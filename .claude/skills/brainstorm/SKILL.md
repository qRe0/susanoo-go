---
name: brainstorm
description: Use when starting a feature from a rough idea — tease out intent before any code: one question at a time, play back, lay out 2–3 approaches with a recommendation, and gate all building on an approved design doc.
metadata:
  phase: understanding
  flow-next: requirements
  flow-alternatives: []
  related: [requirements, specify, architect]
---

# Brainstorm

Draws intent out of a rough request *before* anything gets built. It is a conversation,
not a spec: you ask one question at a time, play the answers back, lay out real
alternatives, and hand the developer a design doc they approve. **Nothing is built until
that approval (HARD-GATE).** Reading and exploring are always fine; writing product code,
scaffolding, or running `go mod init`/generators is not.

## Triage first

Before your first message, decide which case you are in:

- **Everything that matters is in the request** ("rename `pkg/billing` to `pkg/invoice`"):
  a quick, clear task. Do it, and say what you did. No conversation.
- **Something non-trivial is missing**: start the conversation below.

## Look before you ask

In an existing repo, dig in before your first message. `rg`/`grep` over the code the
feature touches, read `go.mod`/`go.work`, `specs/architecture.md` if present, and any
spec/plan/handoff the developer pointed at — until you can explain how the relevant parts
work today and what this change would touch. Never ask what the codebase already answers.

## The conversation

Each message ends with **one question** — a single sentence, no list of example answers
hanging off it. Plain language, matched to the developer's vocabulary; never process
jargon. Get them describing in their own words before offering options; offer a short menu
only when they're stuck. Lead with what matters.

Find out early which "how it gets made" choices they want to make and which they hand to
you. For a Go backend, that means the runtime shape (HTTP/gRPC service, worker, CLI,
library), router (`net/http`, chi, gin, echo), data access (`database/sql`, pgx, sqlc,
gorm, ent), migrations (goose, atlas), logging (slog, zap, zerolog), testing style, and
deployment. Prefer the standard library and whatever the repo already uses; any choice you
make goes into the design doc as **your call**, not something they agreed to.

Ground to cover (territory, not a script — never read these out as questions): what kind of
thing this is; why now and what success looks like; goals, non-goals, and anti-goals; prior
art; current state; the details they care about. Build each question on their last answer,
Socratically, like a sharp colleague.

## Play it back

As soon as you understand one part well enough, describe that part back in ~200–300 words,
then return to questions. Playback and questions alternate. Only what they said goes in as
theirs; anything you filled in goes in as your proposal with your reason. End each chunk by
asking what's wrong or missing.

## Lay out the approaches

Once you understand what they want, and **before** you write anything up, put the ways of
building it in a message of its own: two or three real alternatives (drop the weak ones and
any the existing work rules out), each grounded in what the project actually does and what
it trades off. Recommend one and say why, then ask which way they want to go. When there is
genuinely one sensible way, say so and explain why the others don't fit.

## Size the work and write the design doc

Say how big the work is; the developer can override. A small change gets a short design
(the points already covered, one or two lines each). A project gets the full written design
— intent and why, goals/non-goals/anti-goals, constraints, the approaches (which they
picked and why), the parts of the how they decided, and what's left to the builder.

Write it to `tasks/<task-dir>/brainstorm-design.md` (scratch — see `tasks/README.md`); if
no task context is supplied, create a descriptive task directory, don't allocate a feature
number. It feeds `requirements` and `specify`; durable decisions move to `specs/` there.

**Builder check (for a project):** dispatch a fresh general-purpose subagent with
`builder-check-prompt.md` (this directory), filling in the domain and document path. Tell
the developer a reviewer reads it first and you may come back once. Sort what the builder
asks into three piles — answered already (put the answer in the doc), minor (settle it
yourself, mark it your call), and theirs (only they can answer, and it changes what gets
built). Bring the "theirs" pile in one message, most important first, then hand over the
doc with a short list of the calls you made. That is the only round of questions the check
produces. Without a subagent tool, read the doc as that builder yourself.

## HARD-GATE

Nothing gets built until the developer approves the design doc — the short one for a small
change, the full one for a project. Building includes product code, scaffolding, installing
dependencies, creating projects, and invoking an implementation skill. Two exceptions: they
opted out of the questions, or a spike they said yes to (spikes stay labeled throwaway;
keeping what it produced is a new request back through this gate).

After approval, the next step is `requirements` (then `architect`, `specify`) — hand off
with Context Summary + Next Steps, and do not start coding.

## Common Rationalizations

- "I'll offer a menu of what they might want." Options steer. Ask them to describe it first.
- "I'll fill in sensible defaults." Good — say them out loud. A default they never heard is
  one they couldn't reject.
- "They said 'sounds good' to the idea." Approval covers what you showed them. A design doc
  you haven't written isn't approved.
- "I've answered their questions, so I'll write the doc." Lay out the approaches first, in
  a message of their own.

## Red Flags — STOP

- Writing product code, scaffolding, or running `go mod init`/generators before approval.
- Asking a question the codebase already answers (you didn't "look before you ask").
- Presenting one approach with no alternatives when several real ones exist.
- Recording a storage/transport/library choice as "they agreed" when you made it yourself.
