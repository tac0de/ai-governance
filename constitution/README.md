# AI Constitution v0

AI Constitution is the single source of normative truth for ai-governance v0.

## Scope
- Philosophy and role separation (Planner, Executor, Auditor)
- JSON Schemas for plan/result/evidence/audit
- Fixed reason codes and severities
- Deterministic test vectors

## Role separation
- Planner: generates `plan.json` outside this v0 implementation scope.
- Executor: validates and executes a plan, then emits `result.json` and `evidence.json`.
- Auditor: deterministically decides `PASS` or `REJECT` with a fixed `reason_code`.

## Determinism contract
Given identical inputs (`plan.json`, `result.json`, `evidence.json`) and identical environment policy,
Auditor must produce the same `status`, `reason_code`, and `governance_command`.

## Reason code policy
- Reason codes are fixed in `reasons/reason_codes.json`.
- Runtime must never invent ad-hoc reason strings.
- Violations are machine-comparable by `code` and `path`.

## Cases
- `cases/pass`: expected PASS vectors
- `cases/reject`: expected REJECT vectors
- Expected outputs are defined by `*.expected.audit.json`.
- `cases/thedivineparadox`: local simulation vectors for global mood transitions (MVP v0.1).
