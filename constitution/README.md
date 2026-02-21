# AI Constitution v0

AI Constitution is the single source of normative truth for ai-governance v0.

## Human-First Entry
- Start with `HUMAN_GOVERNANCE_BRIEF_V1.md`.
- Use this folder as governance contracts and policy source.
- Keep runtime-level detail out of default human review flow.

## Governance Core
- Planner: generates `plan.json` outside this v0 implementation scope.
- Executor: validates and executes a plan, then emits `result.json` and `evidence.json`.
- Auditor: deterministically decides `PASS` or `REJECT` with a fixed `reason_code`.

## Determinism contract
Given identical inputs (`plan.json`, `result.json`, `evidence.json`) and identical environment policy,
Auditor must produce the same `status`, `reason_code`, and `governance_command`.

## Evidence Rule
- Every decision path must be traceable and deterministic.
- PR-linked evidence is required for merge-impacting delivery.

## Reason Code Policy
- Reason codes are fixed in `reasons/reason_codes.json`.
- Runtime must never invent ad-hoc reason strings.
- Violations are machine-comparable by `code` and `path`.

## Core Reading Order
1. `HUMAN_GOVERNANCE_BRIEF_V1.md`
2. `charter/AI_GOVERNANCE_ROLES_V1.md`
3. `contracts/trace-protocol.v1.md`
4. `policies/RELEASE_GOVERNANCE_GATE_POLICY_V1.md`
5. `decision-log/ADR-0006-hybrid-mcp-governance-binding.md`

## Cases
- `cases/pass`: expected PASS vectors
- `cases/reject`: expected REJECT vectors
- Expected outputs are defined by `*.expected.audit.json`.
- Domain-specific historical cases are moved to `archive/`.

## Technical Appendix
For runtime and schema-level verification, use `TECHNICAL_APPENDIX_V1.md`.

## Archive
- Non-core product/domain documents are retained under `archive/` for reference only.
