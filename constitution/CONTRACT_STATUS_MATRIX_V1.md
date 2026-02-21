# Contract Status Matrix v1

## Purpose
Track governance artifacts with explicit lifecycle status without deleting runtime code.

## Status Definitions
- `active`: normative and currently enforced.
- `frozen`: supported for compatibility, no feature expansion.
- `archive`: retained for historical reference only.

## Matrix

| Scope | Path | Status | Notes |
|---|---|---|---|
| Human governance brief | `constitution/HUMAN_GOVERNANCE_BRIEF_V1.md` | `active` | default human-facing entry |
| Technical appendix | `constitution/TECHNICAL_APPENDIX_V1.md` | `active` | implementation-only reference |
| Governance charter | `constitution/charter/AI_GOVERNANCE_ROLES_V1.md` | `active` | constitutional role source of truth |
| MCP ministry contract | `constitution/contracts/mcp-authority-unit-table.v1.md` | `active` | jurisdiction-scoped operational contract |
| Deterministic trace contract | `constitution/contracts/trace-protocol.v1.md` | `active` | plan-result-evidence envelope |
| Ops toolchain policy | `constitution/policies/OPS_TOOLCHAIN_POLICY_V1.md` | `active` | `bash` + `git` + `gh`, PR-gated |
| Release gate policy | `constitution/policies/RELEASE_GOVERNANCE_GATE_POLICY_V1.md` | `active` | release blocking policy |
| Domain historical docs | `constitution/archive/` | `archive` | non-core product/domain reference set |
| Go adapter runtime | `control-plane/go` | `frozen` | supported adapter runtime (`frozen-adapter`) |
| Rust adapter runtime | `audit-core/rust` | `frozen` | supported adapter runtime (`frozen-adapter`) |
| Legacy runtime | `.legacy/hub` | `archive` | reference-only; non-executable |
