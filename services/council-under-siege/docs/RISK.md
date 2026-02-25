# RISK

## Security Risks
- Risk: policy bypass through non-governed execution path.
- Control: mandatory bridge routing + validation gate enforcement.

## Privacy Risks
- Risk: evidence payload includes user-identifiable data.
- Control: store only policy-bound evidence summaries in governance core.

## Operational Risks
- Risk: registry/allowlist drift creates invalid capability paths.
- Control: `scripts/validate_all.sh` cross-registry consistency checks.

## Legal Risks
- Risk: unsafe turn actions bypass moderation guardrails.
- Control: safety MCP policy checks and explicit escalation on high-risk changes.

## Approval Tier Mapping
- Change class: gameplay contract and policy-bound capability expansion
- Required tier: medium (escalate to high on economy/account/reward/policy-boundary impact)
- Rationale: default bounded risk with conditional human-gated escalation
