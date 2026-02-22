# SLO

## SLIs
- Explainability coverage: percentage of insights containing both evidence refs and trace refs.
- Validation reliability: percentage of change sets passing governance validation scripts.
- Operational latency: p95 scenario synthesis latency for approved paths.

## SLO Targets
- Explainability coverage: 100%
- Validation reliability: >= 99%
- Operational latency: p95 <= 1200 ms for candidate profile run

## Alert Thresholds
- Explainability coverage < 100% in any release candidate: block merge and escalate to owner.
- Validation reliability < 99% over 7 days: trigger governance incident process.
- Latency > 1200 ms p95 for 2 consecutive windows: require optimization plan and rerun benchmark gate.

## Error Budget Policy
- Window: 28 days
- Burn policy: tracked by explainability and validation misses.
- Action policy: freeze non-essential changes when burn exceeds 50% before mid-window.
