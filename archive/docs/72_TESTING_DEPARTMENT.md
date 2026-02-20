# 72. Testing Department (QA)

## Mission
Prevent regressions before merge by running small, deterministic checks on every change.

## Ownership
- Owner: QA Lead (AI operator in this repo)
- Scope: governance docs, contracts, workflows, and structure integrity

## Mandatory Checks
1. Contract schema validity (`contracts/*.json` parse)
2. Type contract syntax sanity (`contracts/*.ts` parse by `node --check` where applicable)
3. Governance file presence (`README.md`, `docs/55_OPERATING_CHARTER.md`, `docs/09_TESTING_AND_ERROR_PREVENTION.md`)
4. Workflow syntax sanity (`.github/workflows/*.yml` must exist and be non-empty)

## Release Policy
- If any mandatory check fails, merge is blocked.
- No manual bypass for routine changes.

## KPI
- Merge gate pass rate
- Regression escape count (target: zero)
