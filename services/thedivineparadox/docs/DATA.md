# DATA

## Data Classification
- Internal by default; restricted when evidence includes sensitive operational or policy artifacts.

## PII Status
- Contains PII: no by contract design.
- If PII appears in evidence, enforce immediate redaction and high-tier review before reuse.

## Retention
- Evidence summaries: retain by trace reference policy.
- Derived strategic insights: retain only with linked evidence refs and trace refs.
- Incident records: retain according to governance incident playbook requirements.

## Access Controls
- RBAC enforced for service owners and designated reviewers only.
- All access and approvals must be trace-recorded.
- No anonymous or unmanaged external access is permitted.
