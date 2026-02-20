# 2-Week Pilot: DTP Trace/Replay for Incident RCA

## Goal
Prove that DTP-based trace/replay reduces incident root-cause analysis (RCA) time with measurable evidence in 2 weeks.

## Scope
- Target repo for pilot governance: `ai-governance` (policy/contracts/docs only).
- Runtime implementation and instrumentation: `engine` repo (PR#2 only).
- No behavior change in production logic; instrumentation and replay tooling only.

## Hypothesis
If all critical execution paths emit canonical DTP traces and can be replayed deterministically, median RCA time will decrease by at least 30%.

## Primary KPI
- `RCA_TIME_MEDIAN`: median time (minutes) from incident open to verified root cause.

## Secondary KPIs
- `RCA_TIME_P90`: 90th percentile RCA time.
- `REPLAY_SUCCESS_RATE`: percent of incidents where replay reproduces the issue.
- `TRACE_COVERAGE`: percent of selected critical paths that emit valid DTP traces.

## Baseline (Days 1-3)
- Sample the last 10-20 incidents from existing records.
- Record open time, root-cause confirmation time, and reproduction status.
- Freeze baseline numbers before enabling DTP replay path.

## Execution Plan
### Week 1
- Define canonical DTP event contract usage for target flow(s).
- Instrument one high-traffic path in `engine`.
- Generate `.dtp` artifacts with deterministic serialization.
- Build replay validator that re-runs trace and checks output equivalence.

### Week 2
- Expand to one additional path if Week 1 is stable.
- Run incident drills (or real incidents) with DTP replay-first workflow.
- Compare KPI deltas vs. baseline and produce decision memo.

## Data Collection Rules
- Every pilot incident gets:
  - `incident_id`
  - open timestamp
  - root-cause verified timestamp
  - replay attempted (`yes/no`)
  - replay success (`yes/no`)
  - notes (one-line)
- Store summary as markdown in `ai-governance` docs and raw runtime traces in `engine` artifacts/log storage.

## Exit Criteria
- Median RCA time reduced by >= 30%, or
- Replay success >= 80% with clear blocker list for next iteration.

## Deliverables
- DTP pilot result note in `ai-governance` (`docs/`).
- Engine PR with instrumentation/replay implementation references.
- Go/No-go decision for broader rollout.

## Non-Goals
- No full platform rewrite.
- No provider migration.
- No Bash replacement; shell remains execution transport, not protocol layer.
