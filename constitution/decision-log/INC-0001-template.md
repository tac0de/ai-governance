# INC-0001 Template: Runtime Incident Record

## Status
Open | Resolved

## Occurred At
- KST: `<YYYY-MM-DDTHH:MM:SS+09:00>`
- UTC: `<YYYY-MM-DDTHH:MM:SSZ>`

## Trigger Source
- Workflow: `<governance-autonomous-sweep | release-governance-gate | other>`
- Run URL: `<github actions run url>`

## Detection Signal
- audit.status: `<PASS|REJECT|N/A>`
- reason_code: `<HUNBUP_...|null|N/A>`
- Action Required condition: `<which condition matched>`

## Impact
- Scope: `<runtime/release/policy>`
- User-visible impact: `<none|brief description>`

## Root Cause
- Category: `<config|workflow|policy|runtime|schema|secret>`
- Detail: `<deterministic root cause>`

## Corrective Action
1. `<fix action>`
2. `<verification action>`

## Prevention
- Policy/Workflow hardening: `<what was added to prevent recurrence>`

## Linked Changes
- Commit(s): `<hash>`
- Related policy/doc: `<path>`

## Closure Criteria
- [ ] Same path re-run PASS
- [ ] No unresolved Action Required signal
- [ ] Prevention item merged
