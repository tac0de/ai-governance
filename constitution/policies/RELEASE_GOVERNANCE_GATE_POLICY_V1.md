# Release Governance Gate Policy v1

## Policy ID
RGGP-V1

## Scope
Applies to any release tag creation and release workflow execution.

## Mandatory Gate Conditions
1. Release authority role must be `ControlPlaneOperator`.
2. Deterministic audit verdict must be `PASS`.
3. Charter version tag must be `v1` (`ROLES_CHARTER_VERSION`).

## Enforcement Rule
If either condition is not met, release tagging/publishing is blocked.

## CI Binding
The workflow gate must execute in this order:
1. build control-plane runtime
2. run deterministic validation path
3. run deterministic audit path
4. verify `audit.status == PASS`
5. verify release authority role
6. verify roles charter version tag

## Role Source
- Preferred: workflow dispatch input `approver_role`
- Fallback: repository variable `RELEASE_APPROVER_ROLE`

## Change Management
Any change to release gate conditions requires:
1. policy update
2. workflow update
3. ADR update in `constitution/decision-log/`
