# DATA

## Data Classification
- Internal by default for governance artifacts.

## PII Status
- Contains PII: no by contract design.
- If PII appears in artifacts, redact and escalate to high-tier review.

## Retention
- `traces/` is the in-repo short-term governance diary.
- Long-lived records are exported to the external Obsidian governance hub after validation.

## Access Controls
- RBAC for owner/reviewer roles only.
- Every approval and execution artifact must remain trace-linked.
