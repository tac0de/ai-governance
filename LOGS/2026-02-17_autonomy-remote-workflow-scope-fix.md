- Date: 2026-02-17
- Project: ai-governance
- Type: fix
- Tags: workflow, autonomy, openai
- Summary (1 line): Aligned `autonomy-99-remote.yml` to current ai-governance structure and added agent-pair trace generation.

## What changed

- Removed broken references to deleted `scripts/*` runtime paths.
- Updated workflow to use current scope checks:
  - `tools/repo_sweep.sh --strict`
  - `tools/main_hub_final_check.sh`
  - `tools/validate_env_fuse.sh`
- Added lightweight planner-executor agent-pair smoke run (mock by default, real call only with `OPENAI_REAL_CALL=true` and key).
- Added artifacts:
  - `.ops/agent_pair_trace.json`
  - `.ops/natural_ops_report.md`
  - `.ops/run_contract.json`

## Why

- Existing workflow could not execute under current repository layout.
- Needed deterministic run output and explicit OpenAI-key path for remote automation testing.

## Validation

- `bash tools/repo_sweep.sh --strict`
- `bash tools/main_hub_final_check.sh`
