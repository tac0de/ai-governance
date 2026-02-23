This service is governed by repository root `AGENTS.md`.

# Scope Narrowing

- This file only narrows execution for `services/thedivineparadox`.
- Root policy precedence is strict and unchanged.

# Service Execution Mode

- Use one macro planning gate before execution whenever feasible.
- Planning gate must define: objective, scope, forbidden actions, risk tier, completion criteria, and rollback condition.
- After planning approval, run in autopilot mode inside approved scope.
- Switch from direct execution to macro planning when one or more conditions are met:
- More than one repository/service boundary is affected.
- External infra changes are required (cloud, secrets, DB, DNS, CI/CD).
- Rollback is non-trivial or data-impacting.
- Ambiguity remains after initial context collection.
- Ask for human input only on interrupt conditions:
- Scope deviation is required.
- Risk tier exceeds approved level.
- Critical validation fails or rollback condition is triggered.
- Interrupt scenario examples:
- Production deploy target or region differs from approved plan.
- Secret source or runtime credential path differs from approved contract.
- Deterministic test or trace hash verification fails.
- Data migration requires destructive or irreversible action.

# Service Reporting

- Default report format remains mandatory:
- `1. WHAT I DID`
- `2. WHERE IT IS RUNNING`
- `3. HUMAN REQUIRED (links + paths)`
- `4. RISK / UNKNOWN`
- Korean aliases may be used in parallel.

# Service Safety

- Keep changes deterministic and evidence-linked.
- Prefer API/shell-verifiable outcomes over UI-only claims.
- Do not change service policy files or schema contracts without explicit human architect approval.
