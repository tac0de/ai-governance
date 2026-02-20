# 09. Testing and Error Prevention

## Objective
Catch deployment risks before production with lightweight checks.

## Test layers
1. Unit logic checks
2. Command-path smoke tests
3. Access-control regression tests
4. Predeploy script gate

## Required predeploy checks
- env variable presence
- required collections/config keys
- command routing integrity
- syntax/runtime smoke checks
- adapter normalization integrity (`NormalizedResult`, `NormalizedFailureCode`)
- core/adapter boundary check (no model-specific prompt/output logic in core)

## Error prevention rules
- Fail closed on missing access docs.
- Log blocked/success/error outcomes.
- Keep deterministic fallback for upstream API failures.

## Release gate
No deployment when predeploy fails.
