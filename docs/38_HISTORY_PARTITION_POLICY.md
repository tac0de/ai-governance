# History Partition Policy (Active vs Dump-Sensitive)

## Objective
Ingest only new history and separate sensitive content into a dedicated dump bucket.

## Boundary
- `ai-governance`: policy definition and governance records only.
- Runtime partition execution: externalized to runtime repository (`engine`).

## Policy model
- `dump_sensitive`: sexual/sensitive/privacy-risk content
- `active`: all other entries

## Storage model
- state file example: `.ops/history_partition_state.json`
- manifest example: `knowledge/history/history_manifest.jsonl`

## Notes
- This policy is heuristic and should be reviewed periodically.
- For hosted-LLM sync, use sanitized active/public outputs only.
