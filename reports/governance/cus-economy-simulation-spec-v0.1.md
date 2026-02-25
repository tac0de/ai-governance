# CUS Economy Simulation Spec v0.1

## Objective
Deterministically evaluate inflation, progression velocity, and purchase pressure before monetization rollout.

## Inputs (Snapshot-locked)
- Session length distribution (`p25`, `p50`, `p90` minutes)
- Reward drop rates (`run_fail`, `run_success`, `daily_bonus`)
- Purchase frequencies (`new_user`, `retained_user`, `payer_user`)
- Offer exposure per session

## Deterministic Equations
Given input snapshot `I`:

1) `inflation_index`
- `faucet = run_success*0.62 + run_fail*0.38 + daily_bonus*0.40 + offer_exposure_per_session*0.05`
- `sink = 0.62`
- `inflation_index = faucet / sink`

2) `progression_velocity_days_to_featured_cosmetic`
- `effective_session = p50*0.6 + p90*0.3 + p25*0.1`
- `daily_progress_rate = (effective_session/12) * (run_success*0.55 + run_fail*0.25 + daily_bonus*0.20)`
- `days = 10 / max(daily_progress_rate, 0.0001)`

3) `purchase_pressure_index`
- `weighted_purchase = new_user*0.45 + retained_user*0.35 + payer_user*0.20`
- `purchase_pressure_index = min(1, offer_exposure_per_session*0.22 + weighted_purchase*4.2)`

## Risk Thresholds
- `low`:
  - `inflation_index <= 1.05` and `purchase_pressure_index <= 0.25`
- `medium`:
  - `inflation_index <= 1.15` and `purchase_pressure_index <= 0.35`
- `high`:
  - any value above medium thresholds

## Stop-Ship Rules
- `risk_level == high` => rollout hold
- missing `verdict_hash` => hold
- hash mismatch on deterministic re-run => hold

## Human Gate Conditions
- mandatory human gate if any is true:
  - `risk_level == high`
  - price/probability/bundle policy boundary change included
  - monetized offer exposure policy changed

## Evidence Contract
- `simulation_version`
- `input_snapshot_ref`
- `output_summary_ref`
- `verdict_hash`
