# ADR-0004: Adopt Command System v1 (Govern/Operate/Audit/Release)

## Status
Accepted

## Context
ai-governance v1 established role boundaries, release gate constraints, and operating profile version gating.
A unified command system is required to make authority, execution grammar, and audit traceability explicit.

## Decision
Adopt `constitution/contracts/command-system.v1.md` as the canonical command-system contract.

Key decisions:
1. Command taxonomy is fixed to four groups: `govern/*`, `operate/*`, `audit/*`, `release/*`.
2. Command envelope must carry gate context (`roles_charter_version`, `opm_version`, `secret_tier`).
3. Role-to-command authority is explicit and deterministic.
4. Execution grammar is standardized for policy/audit interpretation.

## Consequences
- Positive: improves deterministic interpretation from policy to runtime to audit.
- Positive: reduces ambiguity in who can execute which command.
- Constraint: command changes now require contract + policy + runtime sync.

## Linked Documents
- `constitution/contracts/command-system.v1.md`
- `constitution/policies/OPERATING_PROFILE_MATRIX_V1.md`
- `constitution/policies/ROLE_COMMAND_AUTHZ_POLICY_V1.md`

## Follow-up
- Bind runtime command IDs and workflow steps to command-system identifiers.
- Add incident mapping examples from command failure to reason_code.
