# Incident Playbook

## Trigger Conditions
- Policy breach, deterministic validation failure, or production-impacting governance regression.
- Service-node production release without explicit human architect gate.
- Traceability or fallback guarantee broken after architecture migration.

## Response Flow
1. Freeze affected service or MCP change.
2. Capture evidence refs and trace head hash.
3. Apply containment according to service RUNBOOK.
4. Record incident summary and post-incident action items.
5. If caused by migration release, require PM corrective brief before unfreeze.

## Exit Criteria
- Root cause documented.
- Corrective controls merged.
- Validation checks pass on main branch.
- Human architect sign-off is recorded for reopening production deployment.
