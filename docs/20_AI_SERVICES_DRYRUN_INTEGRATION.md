# 20. AI Services Dry-Run Integration

## Objective
Validate service wiring without live-cost side effects.

## Dry-run rules
- deterministic mock response
- no external paid call
- full log path preserved
- command routing unchanged

## What to validate
- access policy behavior
- timeout handling
- fallback behavior
- billing event schema compatibility

## Promotion rule
Move from dry-run to live only after API test + predeploy pass + daily budget cap confirmation.
