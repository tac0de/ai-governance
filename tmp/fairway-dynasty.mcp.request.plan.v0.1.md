# Fairway Dynasty MCP Addition Request Plan v0.1

Date: 2026-02-25
Scope: Fairway Dynasty Phase-1 (operations-first, deterministic, no real payment)

## 0) Planning Gate

- Objective: Fairway Dynasty의 deterministic 운영 루프 결과를 중앙 거버넌스 분석 경로에 연결.
- Scope: 기존 core MCP capability 사용 요청(신규 MCP ID 없음), 승인/증빙/트레이스 경로 고정.
- Forbidden actions:
  - 서비스에서 신규 core MCP ID 생성
  - registry/manifest/allowlist 미동기 상태 배포
  - 실결제/계정경계 변경을 medium 티어로 처리
- Baseline risk: `medium`
- Completion criteria:
  - MCP request artifact 생성
  - service allowlist 반영
  - `validate_all.sh` 통과
- Rollback condition:
  - schema fail
  - evidence/trace hash linkage 누락
  - approval tier 대비 human gate 누락

## 1) Request Artifact

- Path: `reports/governance/mcp-request-fairway-dynasty-analytics-phase1-20260225.json`
- Request type: `capability_expansion`
- Target MCP: `core-analytics-mcp`
- Requested capabilities:
  - `aggregate_events`
  - `compute_kpi_summary`
  - `detect_anomaly`

## 2) Service Allowlist Contract

- Path: `services/fairway-dynasty/mcp.allowlist.json`
- Allowed MCPs:
  - `core-analytics-mcp`
  - `core-safety-fallback-mcp` (`emit_degrade_notice` only)

## 3) Validation

- `bash scripts/validate_all.sh`
- `bash scripts/test_determinism.sh`
- `bash scripts/bridge_one_shot_local.sh fairway-dynasty.phase1.operations_loop tmp/pm_objective_fairway_dynasty_phase1.txt medium true architect-owner`

## 4) Block Conditions

- service allowlist와 central registry capability mismatch
- intent/policy/evidence/trace 중 하나라도 누락
- deterministic hash mismatch
- payment/account boundary 변경인데 high-tier approval 부재
