# SLO

## SLIs
- Availability: 중앙 검증 파이프라인 실행 성공률
- Latency: 정책 검증 경로 p95 지연
- Error rate: 브릿지/검증 실패 비율

## SLO Targets
- Availability: >= 99.0% (7d)
- Latency: <= 1200ms p95 (rolling benchmark window)
- Error rate: <= 1.0% (7d)

## Alert Thresholds
- Validation reliability < 0.99: 운영자 검토
- p95 latency > 1200ms: 성능 원인 분석
- fallback rate > 0.15: 안전 정책 점검

## Error Budget Policy
- Window: 7d rolling
- Burn policy: 결정론 검증 실패 시 예산 소모
- Action policy: 예산 회복 전 고위험 변경 동결
