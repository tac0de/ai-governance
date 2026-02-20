# OpenAI Admin Audit Workflow

## Purpose
Run a read-only daily audit for OpenAI organization administration signals.

This workflow does not run generation calls and does not expose key values in logs.

## Secret
- `OPENAI_ADMIN_API_KEY` (repository secret)

## Workflow
- File: `.github/workflows/openai-admin-audit.yml`
- Triggers:
  - daily schedule
  - manual `workflow_dispatch`

## Script
- File: `tools/openai_admin_audit.js`
- Outputs:
  - `.ops/openai_admin_audit_report.json`
  - `.ops/openai_admin_audit_report.md`

## Read-only endpoints
- `/v1/organization/projects`
- `/v1/organization/invites`
- `/v1/organization/users`
- `/v1/organization/audit_logs`

## Status model
- `ok`: all target endpoints succeeded and no high-risk findings.
- `warning`: low-risk finding only (for example pending invites).
- `error`: endpoint failure or high-risk finding.

## Guardrail
- Use admin key only for administration/audit workflows.
- Keep generation/API product calls on non-admin project keys.
- Rotate admin key immediately after any suspected exposure.
