# Done Gate Policy v1

## Policy ID
DGP-V1

## Scope
Applies to all governance implementation tracks in ai-governance.

## Core Principle
Every track must explicitly finish before moving to the next track.

## Done Gate (Mandatory)
A track is considered complete only when all three are true:
1. **Documented**: policy/contract/ADR text is updated for the decided change.
2. **Gated**: at least one enforceable gate (workflow/runtime check) is aligned with the decision.
3. **Verified**: at least one deterministic validation evidence exists (YAML parse, command output, or run artifact).

## Exit Rule
- If any Done Gate item is missing, the track remains open.
- Open tracks must not start a new macro track.

## Operator Rule
- Operator view stays concise: only see completion state (`DONE` or `OPEN`) plus blocking item.
- Detailed engineering notes stay in policy/ADR/incident documents.

## Change Management
Any Done Gate rule change requires:
1. update this policy
2. update operating profile matrix linkage
3. record ADR in `constitution/decision-log/`
