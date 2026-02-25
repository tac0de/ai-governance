# INTEGRATIONS

## Core MCPs (Phase 1)
- `core-analytics-mcp`
  - `aggregate_events`
  - `compute_kpi_summary`
  - `detect_anomaly`
- `core-safety-fallback-mcp`
  - `emit_degrade_notice`

## Governance Interfaces
- `schemas/bridge_intent.schema.json`
- `schemas/mcp_change_request.schema.json`
- `schemas/trace_record.schema.json`

## Asset Pipeline
- Local lab source: `/Users/wonyoung_choi/local-image-lab`
- Deterministic output root: `/Users/wonyoung_choi/local-image-lab/outputs/fairway-dynasty/v0.1`
- Imported runtime assets: `/Users/wonyoung_choi/projects/fairway-dynasty/public/assets/fairway/v0.1`

## Boundary Rule
- Runtime MCP implementations remain outside `ai-governance`.
- Governance core stores only contract/evidence/trace artifacts.
