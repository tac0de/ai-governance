# Release Notes v0.7.4

## Summary

`v0.7.4` finalizes a core-only governance kernel for B2B-ready linking and release control.

This release tightens boundary enforcement, removes non-core surfaces, and upgrades trace quality with structured daily reflection packets.

## Breaking Changes

- Removed non-core surfaces from this repository:
  - `control/agents/*`
  - non-core registry contracts (`department-flow`, `linked-services`, `service-diet`, `service-monitoring`, `service-normalization`, `service-role-allocation`)
  - non-core schemas associated with removed contracts
  - docs showcase pages and assets
  - GitHub Pages showcase workflow
  - `ops/*`
- Validation now enforces a core-only file set; removed surfaces are no longer accepted.

## Boundary Hardening

- Policy now explicitly forbids mutation outside `governance/**` during link/apply stages.
- Temporary-link rules now require revert + remediation evidence for any out-of-boundary mutation before release.

## Trace Quality Hardening

- Added `daily_reflection_packet` to allowed trace record types.
- Added required `daily_reflection` section in trace rules.
- Added schema: `schemas/reflection_packet.schema.json`.
- Reflection packets require concrete evidence, multi-step why-chain, owner, due date, and action items.

## Validation Surface Changes

- `scripts/validate_all.sh` now validates only the core contract set.
- `docs/baseline.v0.7.sha256` was regenerated for the new core file set.

## Compatibility Notes

- This release is intentionally opinionated toward a minimal core kernel.
- If teams need removed showcase or extended governance surfaces, they should be maintained outside this core repository.
