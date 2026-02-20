# 73. Error Management Department (Incident/Reliability)

## Mission
Treat failures as structured events, not ad-hoc chat messages.

## Ownership
- Owner: Reliability Lead (AI operator in this repo)
- Scope: incident triage, fallback policy, RCA record quality

## Severity Levels
- `SEV-1`: security/data integrity risk, policy breach, or system-wide block
- `SEV-2`: major workflow failure with no quick workaround
- `SEV-3`: localized failure with workaround available

## Standard Flow
1. Detect and classify severity
2. Contain impact (fail closed, disable risky path)
3. Recover service path (safe fallback first)
4. Record RCA with exact trigger, boundary, and prevention action

## Mandatory RCA Fields
- incident_id
- first_seen_at (UTC)
- impacted_scope
- root_cause
- containment_action
- permanent_fix
- regression_test_added (yes/no)

## Policy
- Unknown failure defaults to safe mode.
- Repeated failure without regression test is not considered closed.
