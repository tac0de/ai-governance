# SLO

## SLIs
- Validation success ratio for required governance checks.
- Mean validation latency per CI run.

## SLO Targets
- Validation success ratio >= 99.9% on main branch.
- Mean validation latency <= 60 seconds for `scripts/validate_all.sh`.

## Alert Thresholds
- Alert when two consecutive main-branch runs fail governance validation.

## Error Budget Policy
- Monthly window with immediate freeze on repeated deterministic failures.
