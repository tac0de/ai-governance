- Date: 2026-02-12
- Project: ai-governance
- Type: implementation
- Tags: model-policy, nano, human-gate
- Summary (1 line): Enforced default gpt-5-nano policy and human-gate escalation for high-tier runs.

Notes:

- Added model-tier checks in `scripts/autonomy_99_loop.sh`.
- Wired `task_complexity` and `allow_high_tier` inputs in remote workflow.
- Updated docs and decision records for nano-first operating policy.
