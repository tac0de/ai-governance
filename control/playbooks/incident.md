# Incident Playbook

## Trigger Conditions
- Policy breach, deterministic validation failure, or production-impacting governance regression.

## Response Flow
1. Freeze affected service or MCP change.
2. Capture evidence refs and trace head hash.
3. Apply containment according to service RUNBOOK.
4. Record incident summary and post-incident action items.

## Exit Criteria
- Root cause documented.
- Corrective controls merged.
- Validation checks pass on main branch.
