# Sync Hub Guard — README

## Summary
This repository keeps a control-plane guard for governance path integrity.

## Current guard files
- Active guard: `tools/control_plane_guard.sh`
- Log helper: `tools/create_sync_bypass_log.sh`
- Archived legacy implementation: `.archive/original_sync_hub_guard.sh`

## Why the legacy guard is archived
A prior migration required temporary bypass, so the old guard implementation was archived for auditability.

## How to create a compliant log entry
1. Run helper:
   - `tools/create_sync_bypass_log.sh "Describe the change briefly"`
2. Update generated file in `LOGS/` with required fields.

## How to run guard locally
```bash
bash tools/control_plane_guard.sh <base_sha> <head_sha>
```

## Re-enable historical guard behavior
If needed, restore archived implementation as a separate reviewed change. Do not overwrite current guard casually.
