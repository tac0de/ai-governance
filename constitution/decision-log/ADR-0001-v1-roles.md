# ADR-0001: Adopt v1 Roles Model (AI Enterprise / AI Government)

## Status
Accepted

## Date
2026-02-20

## Context
ai-governance v0 established deterministic execution and audit flow.
A formal role model is required to scale governance without role ambiguity.

## Decision
Adopt a dual metaphor role model:
- AI Government: Strategy Board, Policy Office, Audit Core
- AI Enterprise: Control Plane Operator, Domain Unit

Store normative role definition in:
- `constitution/charter/AI_GOVERNANCE_ROLES_V1.md`
- `constitution/policies/ROLE_SEPARATION_POLICY_V1.md`

## Consequences
- Positive: clearer accountability and cleaner escalation paths.
- Positive: deterministic policy/audit ownership.
- Constraint: role boundary changes must go through ADR + policy + charter updates.
