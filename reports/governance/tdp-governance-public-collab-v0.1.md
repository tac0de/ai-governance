# TDP Governance Public Collaboration v0.1

## Objective
Open the governance design for TheDivineParadox social experiment to external collaborators while preserving deterministic safety and release control.

## Public Scope (Allowed)
- Governance contracts and schemas.
- Deterministic trace rules and opcode policy.
- Service SLO contract structure and KPI definitions.
- MCP contract manifests/capabilities/security docs.
- Validation scripts and conformance expectations.

## Private Scope (Not Public)
- Runtime secrets and key material.
- Infra internals, cloud project identifiers, and privileged IAM details.
- Any data that can deanonymize participants.
- Operational runbooks with exploit-relevant detail.

## Collaboration Model
- Proposal-first: all external changes start as contract proposals.
- Determinism-first: same input + same evidence => same verdict.
- Evidence-first: every merged change has traceable evidence refs.
- Human architect final gate: no autonomous release approval.

## Mandatory Gates
1) Governance bridge linkage required.
2) Approval tier policy must be respected.
3) `scripts/validate_all.sh` must pass.
4) Determinism check must pass.
5) High-risk boundary changes require explicit architect approval.

## MCP Contribution Rules
- MCP contributions are contract artifacts in governance core only.
- Runtime implementations must live outside `ai-governance`.
- Each MCP proposal must include:
  - job-to-be-done
  - deterministic input/output contract
  - capability list
  - risk level and required approval tier
  - failure and fallback policy

## Review SLA Targets
- Triage first response: <= 24h.
- Contract review pass/fail decision: <= 72h.
- Security/risk escalation response: <= 12h.

## Rollout Strategy
- Phase A: read-only public documentation and proposal intake.
- Phase B: curated collaborator pilot on MCP contracts.
- Phase C: broader contribution window with strict template compliance.

## Success Criteria
- External proposals accepted without deterministic regressions.
- No governance bypass incidents.
- KPI interpretability and trace completeness maintained at 100% explainability coverage.
