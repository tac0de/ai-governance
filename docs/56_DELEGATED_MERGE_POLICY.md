# Delegated Merge Policy

## Purpose
Delegate day-to-day PR validation and merge operations to the AI operator while escalating only macro-critical issues to the Chairman.

## Ownership
- Chairman: final merge authority for `ai-governance`.
- AI Operator: review, validate, and merge downstream repos (`kernel-engine` and later runtime repos) within guardrails.

## Auto-Merge Scope (AI Operator)
- Runtime-only PRs with clear scope and passing required checks.
- Refactor/migration PRs with no behavior change claim and evidence.
- MCP integration PRs that follow contract and trace requirements.

## Mandatory Checks Before Merge
- Required CI checks are green.
- Contract compatibility is preserved (no undocumented breaking change).
- Security baseline checks pass.
- Rollback path is explicit in PR body.

## Escalation to Chairman (must report before merge)
- Architecture-level tradeoff that changes strategic direction.
- Security/privacy risk above normal operational threshold.
- Budget-impacting infrastructure decision.
- Contract breaking change request.
- Incident with customer/brand impact.

## Emergency Reporting Trigger
- If any high-severity risk is detected, pause merge and report immediately with:
  - risk summary
  - affected scope
  - recommended decision

## Reporting Format (fixed)
- Critical check: one highest-risk point.
- Progress: done / in-progress / blocked.
- Expansion proposal: one actionable improvement option.
