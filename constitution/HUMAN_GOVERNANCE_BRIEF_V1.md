# Human Governance Brief v1

## Time Reference
- KST: `2026-02-21T00:00:00+09:00`
- UTC: `2026-02-20T15:00:00Z`

## Purpose
This brief is the human-facing default for governance decisions in this repository.

## Core Model
- Internal layer: government model (authority, policy, audit, boundary).
- External layer: enterprise model (market fit, delivery, revenue).
- The two layers must not be mixed in one authority path.

## Market Layer Roles
- `CEO (strategy)` maps to `StrategyBoard`.
- `CTO (execution integrity)` maps to `ControlPlaneOperator` with `AuditCore` integrity ownership.
- `Head of Product (market fit)` maps to `DomainUnit` under policy constraints.
- `Head of Revenue (distribution)` maps to `DomainUnit` and cannot override governance boundary.

## Required Operational Discipline
- All change delivery is PR-gated.
- All runs must be deterministic and evidence-verifiable.
- Ministry interfaces must declare explicit allowed and denied actions.

## Read Order
1. `charter/AI_GOVERNANCE_ROLES_V1.md`
2. `contracts/trace-protocol.v1.md`
3. `policies/RELEASE_GOVERNANCE_GATE_POLICY_V1.md`
4. `decision-log/ADR-0006-hybrid-mcp-governance-binding.md`

## Note
Runtime and schema implementation details are intentionally excluded from this brief.
For verification or implementation details, use `TECHNICAL_APPENDIX_V1.md`.
