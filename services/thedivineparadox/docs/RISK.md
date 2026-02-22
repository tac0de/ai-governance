# RISK

## Security Risks
- Risk: external API expansion can introduce unreviewed capability drift.
- Control: allowlist-only API surface, change-management gate, and approval-tier escalation rules.

## Privacy Risks
- Risk: evidence bundles may include sensitive metadata.
- Control: data classification checks, moderation pre/post gates, and restricted access controls with audit traces.

## Operational Risks
- Risk: asynchronous batch runs can mask failures and degrade explainability.
- Control: mandatory failure capture, fallback to deterministic local validation path, and trace-linked incident records.

## Legal Risks
- Risk: untracked external API usage can violate contractual or regional obligations.
- Control: integration docs as single contract source, owner approval evidence, and architect review for high-tier changes.

## Approval Tier Mapping
- Change class: routine prompt/profile tuning within approved API surface.
- Required tier: `medium`
- Rationale: policy review and owner approval are sufficient without boundary expansion.

- Change class: experimental API introduction/expansion, data-boundary change, external permission expansion.
- Required tier: `high`
- Rationale: governance boundary impact requires explicit human architect approval.
