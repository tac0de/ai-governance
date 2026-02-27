# SLO

## SLIs
- Availability: 거버넌스 검증 파이프라인 가용성.
- Latency: 동기 응답 경로의 운영 지연 p95.
- Error rate: LLM fallback 및 정책 차단율.

## SLO Targets
- Availability: validation reliability >= 0.99 (7d).
- Latency: operational_latency_p95_ms <= 2800.
- Error rate: llm_fallback_rate <= 0.10 (24h).

## Alert Thresholds
- validation_reliability < 0.99: 정책/증빙 회귀 즉시 점검.
- operational_latency_p95_ms > 2800: callback 분기율과 큐 적체 점검.
- llm_fallback_rate > 0.15: OpenAI 회로차단기 기준 재평가.

## Error Budget Policy
- Window: 7d rolling.
- Burn policy: 일별 지표 편차 누적.
- Action policy: 임계 초과 시 medium 이상 변경 동결 후 원인 교정.
