# INTEGRATIONS

## Core MCPs
- `core-analytics-mcp`
  - `aggregate_events`
  - `compute_kpi_summary`
  - `detect_anomaly`
- `core-safety-fallback-mcp`
  - `classify_llm_error`
  - `select_fallback_policy`
  - `emit_degrade_notice`
- `core-governance-journal-mcp`
  - `export_trace_bundle`
  - `append_governance_diary_entry`
  - `verify_export_receipt`

## Governance Interfaces
- `schemas/bridge_intent.schema.json`
- `schemas/mcp_change_request.schema.json`
- `schemas/trace_record.schema.json`

## Runtime Reference (External)
- Runtime repo path: `/Users/wonyoung_choi/projects/obsidian-mcp`
- Primary role: long-lived governance diary and export sink for validated traces.

## Boundary Rule
- Runtime vault operations remain outside `ai-governance`.
- Governance core stores only policy-bound validation artifacts before export.
