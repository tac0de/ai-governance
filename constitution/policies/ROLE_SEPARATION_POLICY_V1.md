# Role Separation Policy v1

## Policy ID
RSP-V1

## Scope
Applies to all `validate`, `run`, and `audit` flows in ai-governance.

## Rules
1. Strategy Board defines constitutional direction only.
2. Policy Office defines executable constraints only.
3. Control Plane Operator executes plans only after policy validation.
4. Audit Core is authoritative for integrity verdicts.
5. Domain Unit can request execution but cannot override policy/audit outcomes.

## Enforcement Mapping
- Policy reject before run: action is blocked.
- Audit reject after run: action outcome is invalidated and requires operator follow-up.
- Any direct bypass attempt maps to governance violation and must be logged.

## Non-Bypass Requirement
No runtime path may bypass both:
- policy evaluation
- audit verification

## Change Management
Any change to role boundaries requires:
1. charter update
2. policy update
3. ADR entry in `constitution/decision-log/`
