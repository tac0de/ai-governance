# ENV Automation Fuse Policy

## Principle
Decentralize service deployment automation, centralize shared risk fuses.

## Allowed Automation
- Service-level `.env` generation/update by AI for local runtime and deployment workflows.
- Per-service rollout can run independently when within global fuse limits.

## Central Fuse (must stay centralized)
- Budget cap (monthly and per-service).
- Model allowlist and max token policy.
- Default dry-run and real-apply toggles.
- High-risk action gate (`human_gate_required` conditions).

## Secret Handling
- Secrets are stored in central secret systems (CI secrets/secret manager), not copied into repo files.
- Service `.env` receives minimum-scope credentials only.
- Shared root-level credentials are prohibited.

## Audit Requirements
- Every `.env` change must produce:
  - timestamp
  - actor (agent/human)
  - reason
  - diff summary
  - rollback reference
- Audit logs must be append-only and reviewable.

## Portfolio Risk Model
- Small failures are acceptable in isolated services.
- Large failures are prevented by central fuse policy.
- Cross-service blast radius is controlled by scope-limited keys and caps.

## Escalation
- Escalate to Chairman only when central fuse changes are required or high-severity risk is detected.
