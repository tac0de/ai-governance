# Role Command Authorization Policy v1

## Policy ID
RCAP-V1

## Scope
Applies to `local_exec` command authorization in `control-plane/go` runtime.

## Authorization Matrix
- `StrategyBoard`
  - Allowed: `ECHO`
- `PolicyOffice`
  - Allowed: `ECHO`
- `ControlPlaneOperator`
  - Allowed: `ECHO`, `RUN_NODE_VERSION`
- `AuditCore`
  - Allowed: `RUN_NODE_VERSION`
- `DomainUnit`
  - Allowed: `ECHO`

## Enforcement
- If `command_id` is not in global allowlist: `HUNBUP_COMMAND_ID_NOT_ALLOWED`
- If `actor_role` is not authorized for `command_id`: `HUNBUP_COMMAND_ID_NOT_ALLOWED`

## Runtime Binding
- Enforced in `run` before execution.
- Re-validated in `audit` as deterministic policy check.

## Change Management
Any matrix change requires:
1. update this policy
2. update runtime mapping in `control-plane/go/internal/cli/commands.go`
3. add ADR entry in `constitution/decision-log/`
