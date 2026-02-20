# Platform Semi-Automation (94%)

## Objective
Run platform development with high automation speed while preserving safety and decision quality.

## Operating split
- 94% automated lane:
  - build/test/lint
  - sync-hub guard + secret scan
  - dry-run deploy checks
  - ops metrics and usage telemetry capture
- 6% human-gate lane:
  - production deploy approvals
  - billing/policy changes
  - auth/rules relaxations
  - destructive data operations

## MCP strategy
Use `workflow-mcp` as the orchestration MCP with these tools:
- `workflow_plan`
- `guard_pack`
- `recovery_playbook`
- `source_feasibility`
- `rate_limit_snapshot`
- `ops_metrics_summary`
- `semi_auto_strategy`
- `local_time_now`

## Standard loop
1. Generate strategy + plan.
2. Execute low-risk automated path.
3. Collect metrics (`.ops`).
4. Evaluate guardrails.
5. Request approval only for 6% human-gate actions.

## Hard stops
- sync-hub guard fails
- security scan fails
- budget cap reached
- policy violation detected
