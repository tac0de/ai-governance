# Role Separation Policy v1

## Policy ID
RSP-V1

## Scope
Applies to all `validate`, `run`, and `audit` flows in ai-governance.

## Rules
1. Strategy Board defines constitutional direction only.
2. Policy Office defines executable constraints only.
3. Audit Core is authoritative for integrity verdicts.
4. CEO role is co-owned (Human CEO + AI CEO), but final decision authority remains with Human CEO.
5. CTO executes plans only after policy validation and subject to audit outcomes.
6. Head of Product can propose and prioritize, but cannot execute boundary overrides.
7. Head of Revenue can drive distribution, but cannot bypass policy/audit outcomes.

## Enforcement Mapping
- Policy reject before run: action is blocked.
- Audit reject after run: action outcome is invalidated and requires operator follow-up.
- Any direct bypass attempt maps to governance violation and must be logged.

## Non-Bypass Requirement
No runtime path may bypass both:
- policy evaluation
- audit verification

## Enterprise Role Lock
- Enterprise layer is fixed to exactly four roles:
  - `CEO`
  - `CTO`
  - `HeadOfProduct`
  - `HeadOfRevenue`
- Any additional enterprise role requires explicit architecture approval.

## Change Management
Any change to role boundaries requires:
1. charter update
2. policy update
3. ADR entry in `constitution/decision-log/`
