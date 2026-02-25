# SLO

## SLIs
- Availability: governance validation pipeline run success.
- Latency: one-turn governance decision p95 latency.
- Error rate: bridge submission/dispatch/consume failure ratio.

## SLO Targets
- Availability: >= 99.0% (7d)
- Latency: <= 1200ms p95 (rolling benchmark window)
- Error rate: <= 1.0% (7d)

## Alert Thresholds
- Validation reliability < 0.99: escalate to owner review.
- p95 latency > 1200ms: trigger performance investigation.
- fallback rate > 0.15: trigger policy/safety review.

## Error Budget Policy
- Window: 7d rolling
- Burn policy: consume budget on failed deterministic governance checks.
- Action policy: freeze non-critical scope until budget recovery.
