# ADR-0006: Hybrid MCP Governance Binding

## Status
Accepted

## Time Reference
- KST: `2026-02-20T15:43:12+09:00`
- UTC: `2026-02-20T06:43:12Z`

## Context
The governance role model must remain technology-neutral for constitutional stability.
At the same time, operations require an enforceable interface boundary with explicit jurisdiction,
allow/deny actions, and auditable evidence.

## Decision
Adopt a hybrid model:

1. Constitutional layer remains protocol-agnostic.
2. Operational execution layer is MCP ministry-scoped and mandatory.
3. MCP mandate is enforced by contracts/policies, not by redefining constitutional roles.
4. Internal government layer and external enterprise layer must stay separated in execution traces.

## Relation to ADR-0003
- ADR-0003 remains valid for constitutional role neutrality.
- This ADR supplements ADR-0003 by binding operational execution to MCP ministry contracts.
- This ADR does not replace role ownership defined in `AI_GOVERNANCE_ROLES_V1.md`.

## Consequences
- Positive: role neutrality and operational enforceability are both preserved.
- Positive: audit can validate jurisdiction, toolchain, and PR gate evidence deterministically.
- Constraint: every operational path must provide ministry metadata and PR-linked evidence.

## Enforcement Anchors
- `constitution/contracts/mcp-authority-unit-table.v1.md`
- `constitution/contracts/trace-protocol.v1.md`
- `constitution/policies/OPS_TOOLCHAIN_POLICY_V1.md`
- `constitution/policies/RELEASE_GOVERNANCE_GATE_POLICY_V1.md`
