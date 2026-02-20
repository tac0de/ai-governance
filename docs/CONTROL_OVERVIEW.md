# Control Overview

## Scope
Minimal control-plane governance for `ai-governance`.

## Design rules
- AI is treated as stateless for governance decisions.
- Authority is enforced by repository policy, CI checks, and explicit decision logs.
- Safe defaults are applied when policy/config is missing.

## Active control assets
- Guard: `tools/control_plane_guard.sh`
- Final check: `tools/main_hub_final_check.sh`
- Sweep check: `tools/repo_sweep.sh`
- Policy config examples: `config/*.example.json`

## Required pattern
Before merge handoff, run:
```bash
bash tools/repo_sweep.sh --strict
bash tools/main_hub_final_check.sh
```

## Non-goals
- No domain runtime execution.
- No MCP runtime server hosting inside `ai-governance`.
- No business logic execution in governance repository.
