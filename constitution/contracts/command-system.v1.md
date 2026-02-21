# Command System v1

## Purpose
Define a deterministic command system for ai-governance that binds role authority, execution gates, and audit evidence into one contract.

## Command Taxonomy

### 1) `govern/*`
- Scope: constitutional and policy changes.
- Examples:
  - `govern.policy.update`
  - `govern.roles.update`
  - `govern.adr.record`
- Default actor: `PolicyOffice`

### 2) `operate/*`
- Scope: deterministic runtime execution.
- Examples:
  - `operate.validate.plan`
  - `operate.run.plan`
- Default actor: `CTO`

### 3) `audit/*`
- Scope: evidence and integrity verification.
- Examples:
  - `audit.verify.result`
  - `audit.verify.evidence`
  - `audit.verify.checksums`
- Default actor: `AuditCore`

### 4) `release/*`
- Scope: release gating and publication control.
- Examples:
  - `release.gate.evaluate`
  - `release.tag.publish`
- Default actor: `CTO`

## Command Contract
Each command invocation must be representable with this deterministic envelope.

```json
{
  "command": "operate.run.plan",
  "request_id": "uuid",
  "actor_role": "CTO",
  "inputs": {},
  "gates": {
    "roles_charter_version": "v1",
    "opm_version": "v1",
    "secret_tier": "admin-only"
  },
  "expected_outputs": ["result.json", "evidence.json", "audit.json"]
}
```

## Authority Matrix

| Role | Allowed Command Groups | Escalation Rule |
|---|---|---|
| StrategyBoard | `govern/*` (intent approval only) | Requires PolicyOffice implementation |
| PolicyOffice | `govern/*` | Must record ADR for boundary changes |
| AuditCore | `audit/*` | No runtime mutation authority |
| CEO (Human+AI co-owned) | strategy approval scope only | Final approval is Human CEO only |
| CTO | `operate/*`, `release/*` | Release requires `audit.status == PASS` |
| HeadOfProduct | request-only (no direct execution authority) | Must route through CTO |
| HeadOfRevenue | request-only (no direct execution authority) | Must route through CTO |

## Execution Grammar
Canonical command statement:

`<actor_role> executes <command> with <gates> and emits <evidence>`

Example:

`CTO executes operate.run.plan with {roles_charter_version=v1, opm_version=v1, secret_tier=admin-only} and emits {result.json,evidence.json,audit.json}`

## Failure Mapping
- Gate mismatch -> `REJECT` with policy-aligned reason_code.
- Unknown command group -> `HUNBUP_COMMAND_ID_NOT_ALLOWED`.
- Unauthorized actor-command pair -> `HUNBUP_COMMAND_ID_NOT_ALLOWED`.
- Missing required evidence fields -> `HUNBUP_EVIDENCE_MISSING_REQUIRED_FIELD`.

## Compatibility Rule
- This contract is additive over v1 policies.
- Existing workflow gates (`ROLES_CHARTER_VERSION`, `OPM_VERSION`, `secret_tier`) remain authoritative.
- Runtime command binding table: `constitution/contracts/command-binding-table.v1.md`.
- Legacy compatibility note: runtime artifacts from schema `v1.0` may include `ControlPlaneOperator` alias.

## Change Management
Any command-system change requires:
1. update this contract
2. update relevant policy documents
3. update runtime/workflow bindings
4. record ADR in `constitution/decision-log/`
