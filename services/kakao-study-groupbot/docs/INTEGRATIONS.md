# INTEGRATIONS

## External APIs
- Kakao Chatbot skill endpoint: 5초 내 응답 또는 `useCallback` 경로 사용.
- OpenAI Responses API: 학습 코칭/요약/피드백 생성.
- OpenAI Batch API: 과제 리포트/일일 요약 비동기 처리.

## Runtime Interface Contracts
- Ingress: `POST /kakao/skill`
- Async callback: callback token 1분 유효 구간 내 실행.
- Model routing: 기본 저비용 모델, 학습계획/오답분석/장문은 상위 모델 승급.

## MCP Usage
- `core-analytics-mcp`
  - aggregate_events
  - compute_kpi_summary
  - detect_anomaly
  - propose_learning_actions
- `core-safety-fallback-mcp`
  - classify_llm_error
  - select_fallback_policy
  - emit_degrade_notice
- `core-experiment-mcp`
  - assign_cohort
  - resolve_flag
  - kill_switch
- `core-study-session-governor-mcp`
  - evaluate_group_session_state
  - select_next_learning_intervention
  - enforce_turn_and_participation_policy
  - emit_learning_session_trace_contract

## Permissions Scope
- Least-privilege allowlist and capability pinning only.
- Default change tier: medium (`policy_plus_owner`).
- Boundary expansion/new core registration: high + human gate.
