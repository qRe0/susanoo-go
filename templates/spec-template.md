# Feature Specification: [FEATURE NAME]

**Feature Branch**: `[NNN-feature-name]`

**Created**: [DATE]

**Status**: Draft

**Input**: User description: "$ARGUMENTS"

This spec records WHAT and WHY only. It contains no implementation detail: no package
names, no types, no storage or transport choices. Those belong to `plan.md`.

## User Scenarios & Testing *(mandatory)*

<!--
  Prioritize user stories as user journeys, ordered by importance. Each story must be
  independently testable: implementing just one story still yields a viable MVP that
  delivers value.

  Assign priorities (P1, P2, P3, ...). P1 is the most critical. Think of each story as a
  standalone slice that can be developed, tested, deployed, and demonstrated on its own.
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe the user journey in plain language.]

**Why this priority**: [The value this story delivers and why it is first.]

**Independent Test**: [How to test this story alone, e.g. "Can be fully tested by
[action] and delivers [value]."]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe the user journey in plain language.]

**Why this priority**: [The value this story delivers and why it is second.]

**Independent Test**: [How to test this story alone.]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 3 - [Brief Title] (Priority: P3)

[Describe the user journey in plain language.]

**Why this priority**: [The value this story delivers and why it is third.]

**Independent Test**: [How to test this story alone.]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

[Add more user stories as needed, each with an assigned priority.]

### Edge Cases

- What happens when [boundary condition]?
- How does the system handle [error scenario]?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST [specific capability, e.g. "allow users to create accounts"]
- **FR-002**: System MUST [specific capability, e.g. "validate email addresses"]
- **FR-003**: Users MUST be able to [key interaction, e.g. "reset their password"]
- **FR-004**: System MUST [data requirement, e.g. "persist user preferences"]
- **FR-005**: System MUST [behavior, e.g. "log all security events"]

*Mark an unclear requirement with a `[NEEDS CLARIFICATION: ...]` marker (max 3 per spec):*

- **FR-006**: System MUST authenticate users via [NEEDS CLARIFICATION: auth method not
  specified - email/password, SSO, OAuth?]
- **FR-007**: System MUST retain user data for [NEEDS CLARIFICATION: retention period not
  specified]

### Key Entities *(include if the feature involves data)*

- **[Entity 1]**: [What it represents and its key attributes, without implementation detail.]
- **[Entity 2]**: [What it represents and its relationships to other entities.]

## Success Criteria *(mandatory)*

### Measurable Outcomes

Success criteria are user-facing, measurable, and technology-agnostic.

- **SC-001**: [Measurable metric, e.g. "Users can complete account creation in under 2 minutes"]
- **SC-002**: [Measurable metric, e.g. "The system handles 1000 concurrent users without degradation"]
- **SC-003**: [User outcome, e.g. "90% of users complete the primary task on the first attempt"]

## Assumptions

- [Assumption about target users, e.g. "Users have stable internet connectivity."]
- [Assumption about scope, e.g. "Mobile support is out of scope for v1."]
- [Assumption about data or environment, e.g. "The existing authentication system is reused."]
- [Dependency on an existing system, e.g. "Requires access to the existing user profile API."]
