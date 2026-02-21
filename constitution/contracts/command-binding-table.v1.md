# Command Binding Table v1

## Purpose
Provide a deterministic mapping between governance command identifiers (`command-system.v1`) and runtime `command_id` values enforced in `control-plane/go`.

## Source of Truth
- Runtime implementation: `control-plane/go/internal/cli/commands.go`
- Governance command taxonomy: `constitution/contracts/command-system.v1.md`
- MCP authority segmentation: `constitution/contracts/mcp-authority-unit-table.v1.md`

## Binding Matrix

| Runtime `command_id` | Governance Command | Command Group | Primary Actor Role | Runtime Entry |
|---|---|---|---|---|
| `ECHO` | `operate.validate.plan` | `operate/*` | `ControlPlaneOperator` | `run` path (`commandFor`) |
| `RUN_NODE_VERSION` | `audit.verify.result` | `audit/*` | `AuditCore` | `run` path (`commandFor`) |

## Authorization Overlay
Runtime role-command authorization follows:
- `constitution/policies/ROLE_COMMAND_AUTHZ_POLICY_V1.md`
- in-code role matrix in `control-plane/go/internal/cli/commands.go`

## Deterministic Rules
1. Any runtime `command_id` without binding row is invalid for governance execution.
2. Any governance command without runtime binding is documentation-only and non-executable.
3. Binding conflicts must resolve in favor of runtime allowlist + policy matrix intersection.

## Failure Mapping
- Unbound runtime `command_id` -> `HUNBUP_COMMAND_ID_NOT_ALLOWED`
- Unauthorized role for bound command -> `HUNBUP_COMMAND_ID_NOT_ALLOWED`

## Change Management
Any binding change requires:
1. update this table
2. update `command-system.v1` if command taxonomy changes
3. update `ROLE_COMMAND_AUTHZ_POLICY_V1` when role coverage changes
4. update runtime mapping in `control-plane/go/internal/cli/commands.go`
5. record ADR in `constitution/decision-log/`
