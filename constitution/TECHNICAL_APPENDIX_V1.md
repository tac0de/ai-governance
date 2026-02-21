# Technical Appendix v1

## Time Reference
- KST: `2026-02-21T00:00:00+09:00`
- UTC: `2026-02-20T15:00:00Z`

## Scope
This appendix is for implementation-level verification only.

## Runtime Status
- `control-plane/go`: supported adapter runtime (`frozen-adapter`)
- `audit-core/rust`: supported adapter runtime (`frozen-adapter`)
- `.legacy/hub`: archive/reference only

## Deterministic Schemas
- `schemas/jsonschema/plan.schema.json` (`v1.0` read-compatible, `v1.1` contract fields)
- `schemas/jsonschema/result.schema.json` (`v1.0` read-compatible, `v1.1` contract fields)
- `schemas/jsonschema/evidence.schema.json` (`v1.0` read-compatible, `v1.1` contract fields)
- `schemas/jsonschema/audit.schema.json` (`v1.0` read-compatible, `v1.1` reason extensions)

## Operational Contracts
- `contracts/mcp-authority-unit-table.v1.md`
- `contracts/trace-protocol.v1.md`
- `policies/OPS_TOOLCHAIN_POLICY_V1.md`
- `policies/RELEASE_GOVERNANCE_GATE_POLICY_V1.md`

## Change Control
- Use PR-linked evidence (`pr_ref`) for merge-impacting changes.
- Keep role model protocol-agnostic (`ADR-0003`) while enforcing MCP ministry binding at operations (`ADR-0006`).
