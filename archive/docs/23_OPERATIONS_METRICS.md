# Operations Metrics (Lightweight)

## Goal
Track core operational KPIs with low overhead while keeping `ai-governance` governance-focused.

## Storage
- Local read path: `.ops/ops_metrics.csv`
- `ai-governance` consumes and reviews metrics; runtime writers are external (`engine` side).

## Read commands (ai-governance)
```bash
test -f .ops/ops_metrics.csv && tail -n 20 .ops/ops_metrics.csv
```

Quick aggregation by event type (if file exists):
```bash
awk -F, 'NR>1{count[$1]++} END{for (k in count) print k, count[k]}' .ops/ops_metrics.csv 2>/dev/null || true
```

## KPI interpretation
- deployment failure rate
- security warning count
- recovery lead time proxy

## Operating rule
Use `ai-governance` for KPI review and governance decisions; keep metric generation in runtime repositories.
