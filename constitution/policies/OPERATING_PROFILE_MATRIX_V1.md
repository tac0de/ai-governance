# Operating Profile Matrix v1

## Policy ID
OPM-V1

## Scope
Defines a single operational profile view across role authority, workflow inputs, secret tiers, and governance gates.

## Profile Version Tag
- `OPM_VERSION=v1`
- This tag is the authoritative runtime gate value for operating profile compatibility.

## Profiles

| Profile | Workflow | Role Input | Secret Tier Input | Default Role | Default Secret Tier | Mandatory Gates |
|---|---|---|---|---|---|---|
| Autonomous Sweep | `governance-autonomous-sweep` | N/A | `secret_tier` | N/A | `admin-only` | `ROLES_CHARTER_VERSION=v1`, deterministic audit path |
| Release Gate | `release-governance-gate` | `approver_role` | `secret_tier` | `ControlPlaneOperator` | `admin-only` | `audit.status == PASS`, `approver_role == ControlPlaneOperator`, `ROLES_CHARTER_VERSION=v1` |

## Role-to-Command Source
- Use `constitution/policies/ROLE_COMMAND_AUTHZ_POLICY_V1.md` as the only role-command authorization source.

## Secret Tier Source
- Use `constitution/policies/SECRETS_TIERING_POLICY_V1.md` as the only secret-tier source.

## Release Gate Source
- Use `constitution/policies/RELEASE_GOVERNANCE_GATE_POLICY_V1.md` as the only release gate source.

## Action Required Conditions
1. `audit.status != PASS`
2. `reason_code != null`
3. `secret tier gate failed`

## Change Management
Any profile change requires:
1. update this matrix
2. update referenced policy files
3. synchronize workflow gate value (`OPM_VERSION`)
4. update workflow bindings
5. record ADR in `constitution/decision-log/`
