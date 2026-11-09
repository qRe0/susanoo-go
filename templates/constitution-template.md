# [PROJECT_NAME] Constitution

**Version**: [MAJOR.MINOR.PATCH] | **Ratified**: [YYYY-MM-DD] | **Last Amended**: [YYYY-MM-DD]

This document is project-owned governance (Sources-of-Truth tier 4). It points to
`AGENTS.md` for precedence and does not restate that ladder. Every later stage treats a
`MUST` violation here as CRITICAL.

## Core Principles

### I. [PRINCIPLE_1_NAME]
<!-- Example: I. Standard Library First -->
[PRINCIPLE_1_DESCRIPTION]
<!-- Example: Prefer the Go standard library over a third-party dependency when it meets
the requirement. Add a dependency only when the standard library cannot do the job
without disproportionate code. -->

### II. [PRINCIPLE_2_NAME]
<!-- Example: II. Errors Are Values -->
[PRINCIPLE_2_DESCRIPTION]
<!-- Example: Functions return errors instead of panicking. Wrap errors with %w at
package boundaries; match with errors.Is and errors.As. -->

### III. [PRINCIPLE_3_NAME]
<!-- Example: III. Test-First (NON-NEGOTIABLE) -->
[PRINCIPLE_3_DESCRIPTION]
<!-- Example: TDD is mandatory for new behavior: write the failing test, watch it fail,
implement the minimum to make it pass, refactor. -->

### IV. [PRINCIPLE_4_NAME]

[PRINCIPLE_4_DESCRIPTION]

### V. [PRINCIPLE_5_NAME]

[PRINCIPLE_5_DESCRIPTION]

## [SECTION_2_NAME]
<!-- Example: Security Requirements, Performance Standards, Deployment Policy -->

[SECTION_2_CONTENT]

## [SECTION_3_NAME]
<!-- Example: Review Process, Quality Gates, Data Rules -->

[SECTION_3_CONTENT]

## MUST / MUST NOT

- **MUST** [invariant, e.g. "wrap errors with %w at package boundaries"]
- **MUST** [invariant, e.g. "inject the clock as `now func() time.Time`; never call time.Now directly in business logic"]
- **MUST NOT** [prohibition, e.g. "hand-edit generated code (sqlc, protoc, buf)"]
- **MUST NOT** [prohibition, e.g. "introduce mutable package-level state"]

## Governance

[GOVERNANCE_RULES]
<!-- Example: All plans and reviews must verify compliance. Amendments require a
documented change, an approval, and a migration plan for existing code. Complexity must
be justified. Use `.claude/conventions/` for runtime Go style guidance. -->
