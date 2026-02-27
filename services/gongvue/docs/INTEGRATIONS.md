# INTEGRATIONS

## Core MCPs
- `core-analytics-mcp`
  - aggregate_events
  - compute_kpi_summary
  - detect_anomaly
- `core-safety-fallback-mcp`
  - classify_llm_error
  - select_fallback_policy
  - emit_degrade_notice

## Governance Interfaces
- `schemas/bridge_intent.schema.json`
- `schemas/mcp_change_request.schema.json`
- `traces/governance/mcp-request-*.json`

## Extension Baseline
- 1차 모델: Plugin + Sidecar
- SDK 제공은 L2+ 단계로 분리

## Plugin Contract (v0.1)
- mount path: `/opt/gongvue/plugins`
- entry file: `custom_action.js`
- required inputs: `event_id`, `event_type`, `trace_ref`, `payload_ref`
- required outputs: `actions`, `policy_verdict`

## Sidecar Contract (v0.1)
- endpoint env: `GONGVUE_SIDECAR_WEBHOOK_URL`
- required event fields: `event_id`, `event_type`, `trace_ref`, `payload_ref`, `idempotency_key`
- auth mode: `hmac_sha256_signature`
- timeout/retry: `2000ms`, max `3` attempts

## Boundary Rule
- 중앙은 정책/검증/감사만 담당한다.
- 런타임 구현은 서비스 저장소에서 수행한다.
