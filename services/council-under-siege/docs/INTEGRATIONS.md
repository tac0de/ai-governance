# INTEGRATIONS

## Core MCPs
- `core-analytics-mcp`
  - aggregate_events
  - compute_kpi_summary
  - detect_anomaly
  - propose_learning_actions
- `core-safety-fallback-mcp`
  - classify_llm_error
  - select_fallback_policy
  - emit_degrade_notice

## Governance Interfaces
- `schemas/bridge_intent.schema.json`
- `schemas/mcp_change_request.schema.json`
- `schemas/trace_record.schema.json`

## Boundary Rule
- Runtime MCP implementations remain outside `ai-governance`.
