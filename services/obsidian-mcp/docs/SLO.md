# SLO

## SLIs
- Explainability coverage
- Validation reliability
- Operational latency p95
- D1 return rate
- Vote completion rate
- Post-vote result open rate
- LLM fallback rate

## SLO Targets
- Explainability coverage: 100%
- Validation reliability: >= 99%
- Operational latency p95: <= 1200 ms
- D1 return rate: >= 20%
- Vote completion rate: >= 65%
- Post-vote result open rate: >= 40%
- LLM fallback rate: <= 10%

## Alert Thresholds
- Explainability coverage < 100%: release block
- Validation reliability < 99%: incident escalation
- Operational latency p95 > 1200 ms for two windows: optimization gate
- D1 < 15% / completion < 55% / result-open < 30%: workflow quality review
- LLM fallback > 15%: reliability incident

## Error Budget Policy
- Window: 28 days
- Burn policy: tracked by explainability and validation misses
- Action policy: freeze non-essential changes when burn exceeds 50% before mid-window
