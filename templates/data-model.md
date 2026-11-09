# Data Model: [FEATURE NAME]

**Input**: `specs/[NNN-feature-name]/spec.md` (Key Entities, FR) and `plan.md` (storage choice)

Records entities, their fields and relationships, validation rules, and state transitions.
Names the storage mapping (table or collection) but not the Go types or query code.

## Entities

### [Entity 1]

- **Purpose**: [what it represents]
- **Fields**:
  - [field] ([type]): [meaning and constraints]
- **Validation**: [rules derived from FR, e.g. non-empty, format, range]
- **Relationships**: [to other entities, with cardinality]

### [Entity 2]

- **Purpose**: [what it represents]
- **Fields**:
  - [field] ([type]): [meaning and constraints]
- **Validation**: [rules]
- **Relationships**: [to other entities]

## State Transitions

- [Entity] : [state A] -> [state B] on [event], [state B] -> [state C] on [event]

## Storage Mapping

| Entity | Table / Collection | Notes |
|---|---|---|
| [Entity 1] | [table name] | [indexes, uniqueness] |
| [Entity 2] | [table name] | [indexes, foreign keys] |
