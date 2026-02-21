# Release Governance Gate Policy v1

## Policy ID
RGGP-V1

## Scope
Applies to any release tag creation and release workflow execution.

## Mandatory Gate Conditions
1. Release authority role must be `CTO`.
2. Deterministic audit verdict must be `PASS`.
3. Charter version tag must be `v1` (`ROLES_CHARTER_VERSION`).
4. PR evidence must be present (`pr_ref` in governed artifacts).
5. Mandatory ops toolchain evidence must be valid (`bash`, `git`, `gh`).

## Enforcement Rule
If any condition is not met, release tagging/publishing is blocked.

## CI Binding
The workflow gate must execute in this order:
1. build control-plane runtime
2. run deterministic validation path
3. run deterministic audit path
4. verify `audit.status == PASS`
5. verify release authority role
6. verify roles charter version tag
7. verify PR evidence (`pr_ref`) across plan/result
8. verify mandatory toolchain declaration from plan

## Role Source
- Preferred: workflow dispatch input `approver_role`
- Fallback: repository variable `RELEASE_APPROVER_ROLE`

## Legacy Compatibility
- Historical `v1.0` evidence may contain `ControlPlaneOperator` alias.
- New governed write path (`v1.1`) must use `CTO`.

## Policy Dependency
- `constitution/policies/OPS_TOOLCHAIN_POLICY_V1.md`
- `constitution/contracts/trace-protocol.v1.md`
- `schemas/jsonschema/plan.schema.json`
- `schemas/jsonschema/result.schema.json`

## Change Management
Any change to release gate conditions requires:
1. policy update
2. workflow update
3. ADR update in `constitution/decision-log/`
