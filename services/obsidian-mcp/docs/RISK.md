# RISK

## Security Risks
- Risk: vault path escape or unbounded file reads.
- Control: strict boundary checks and deterministic rejection contracts.

## Privacy Risks
- Risk: note metadata may include sensitive fields.
- Control: classify evidence as internal and enforce redaction before export.

## Operational Risks
- Risk: result-order instability across repeated queries.
- Control: sorted deterministic output and replay checks.

## Legal Risks
- Risk: policy drift when enabling write-capable tools.
- Control: require high-tier governance review for capability expansion.

## Approval Tier Mapping
- Change class: read-only workflow tuning and documentation updates.
- Required tier: medium.
- Rationale: bounded data-read scope with owner review.

- Change class: write/delete capability onboarding.
- Required tier: high.
- Rationale: irreversible data-impact boundary requires architect gate.
