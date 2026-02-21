# MCP Authority Unit Table v1

## Purpose
Define MCP as a jurisdiction-scoped authority-bearing ministry unit.

## Time Reference
- KST: `2026-02-20T15:43:12+09:00`
- UTC: `2026-02-20T06:43:12Z`

## Mandatory Unit Contract
Every MCP unit must publish one deterministic row with:
- `jurisdiction`
- `unit_role`
- `allowed_actions`
- `forbidden_actions`
- `audit_points`
- `approval_model`
- `risk_tier`
- `required_trace_fields`

## Unit Matrix

| mcp_unit_id | jurisdiction | runtime_entry | unit_role | allowed_actions | forbidden_actions | audit_points | approval_model | risk_tier | required_trace_fields |
|---|---|---|---|---|---|---|---|---|---|
| `control-plane-hub` | `internal_government` | `control-plane/go/cmd/hub` | `CTO` | `validate`, `run`, `audit` on policy-bound plan/result/evidence contracts | direct governance boundary mutation, unmanaged command execution, non-schema outputs | schema validation, role-command authorization check, checksum verification, PR reference presence check | single-step execution under role-command matrix (`ROLE_COMMAND_AUTHZ_POLICY_V1`) | `high` | `request_id`, `actor_role`, `governance_layer`, `ministry_id`, `jurisdiction`, `command_id`, `reason_code`, `checksums`, `pr_ref` |
| `webgame-reference-mcp` | `external_enterprise` | `control-plane/go/cmd/webgame-ref-mcp` | `HeadOfProduct` (research adapter) | external reference search, benchmark sheet generation for web/mobile-web game UX | deployment/infrastructure mutation, secret retrieval, release publishing, file-system mutation outside process output | source provenance capture, query trace logging, allowlist check for output surface | single-step read-only execution; promotion to `medium/high` requires PolicyOffice approval | `low` | `request_id`, `caller_role`, `governance_layer`, `ministry_id`, `jurisdiction`, `tool_name`, `query_or_urls`, `timestamp`, `pr_ref` |

## DevOps/Infra Rule
Any MCP that can deploy, mutate infrastructure, or access secrets must satisfy:
1. `risk_tier` is `high`.
2. Two-step approval is mandatory:
   - step A: `PolicyOffice` policy approval
   - step B: `CTO` execution approval

## Segmentation Rule
MCP partitioning must be authority-first:
- valid split criterion: permission boundary
- invalid split criterion: convenience-only function grouping
- cross-jurisdiction invocation is denied unless explicitly policy-approved

## Enforcement Anchors
- Command binding: `constitution/contracts/command-binding-table.v1.md`
- Role authorization: `constitution/policies/ROLE_COMMAND_AUTHZ_POLICY_V1.md`
- Operating profile gates: `constitution/policies/OPERATING_PROFILE_MATRIX_V1.md`
- Ops toolchain constraints: `constitution/policies/OPS_TOOLCHAIN_POLICY_V1.md`
- Trace contract: `constitution/contracts/trace-protocol.v1.md`

## Change Management
Any change requires:
1. update this table
2. update role-command policy if role authority changes
3. update runtime command bindings if executable surface changes
4. record ADR in `constitution/decision-log/`
