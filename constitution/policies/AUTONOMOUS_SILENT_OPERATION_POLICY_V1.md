# Autonomous Silent Operation Policy v1

## Policy ID
ASOP-V1

## Scope
Applies to autonomous scheduled operations in ai-governance.

## Core Rule
Default mode is silent and signal-only.

## Governance Baseline Gate
- Autonomous sweep must verify `ROLES_CHARTER_VERSION=v1` before execution.
- If charter tag verification fails, run must stop as policy violation.

## Logging Policy
- Do not open or update GitHub issues for heartbeat/status records.
- Do not create periodic status comments.
- Record routine status in:
  - GitHub Actions Step Summary
  - Artifact JSON (`status.json`)

## Signal Emission Rule
Emit human-facing signal only when:
1. runtime status is not PASS
2. deterministic audit indicates REJECT
3. release gate condition fails

## Workflow Consolidation Rule
- Keep autonomous scheduled workflows minimal.
- Prefer one consolidated sweep workflow over many repo-noisy jobs.
- Use `concurrency` to avoid overlapping runs.

## Change Management
Any policy change requires:
1. policy document update
2. workflow update
3. ADR record update
