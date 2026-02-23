# SLO

## SLIs
- Explainability coverage: percentage of insights containing both evidence refs and trace refs.
- Validation reliability: percentage of change sets passing governance validation scripts.
- Operational latency: p95 scenario synthesis latency for approved paths.
- Daily return rate (D1): share of users who return the next UTC day after first participation.
- Vote completion rate: share of sessions that submit one valid vote.
- Post-vote result open rate: share of successful vote sessions that open result view in the same session.
- LLM fallback rate: share of daily recompute events ending with `llm_status=degraded`.

## SLO Targets
- Explainability coverage: 100%
- Validation reliability: >= 99%
- Operational latency: p95 <= 1200 ms for candidate profile run
- Daily return rate (D1): >= 22%
- Vote completion rate: >= 70%
- Post-vote result open rate: >= 45%
- LLM fallback rate: <= 8%

## Alert Thresholds
- Explainability coverage < 100% in any release candidate: block merge and escalate to owner.
- Validation reliability < 99% over 7 days: trigger governance incident process.
- Latency > 1200 ms p95 for 2 consecutive windows: require optimization plan and rerun benchmark gate.
- Daily return rate (D1) < 18% over rolling 7 days: require product loop correction plan.
- Vote completion rate < 60% over rolling 3 days: trigger UX simplification review.
- Post-vote result open rate < 35% over rolling 3 days: require post-vote CTA redesign.
- LLM fallback rate > 12% over rolling 24h: trigger reliability incident and fallback messaging check.

## Error Budget Policy
- Window: 28 days
- Burn policy: tracked by explainability and validation misses.
- Action policy: freeze non-essential changes when burn exceeds 50% before mid-window.

## Measurement Notes
- Measurement window is UTC-day aligned for all product metrics.
- Product metrics are evaluated together with deterministic governance checks; neither may be optimized by bypassing trace obligations.
