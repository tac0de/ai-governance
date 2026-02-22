# RUNBOOK

## Deploy
- Update service docs and policy contracts in a single change set.
- Run `bash scripts/validate_all.sh` and `bash scripts/test_determinism.sh`.
- Run `bash scripts/benchmark_gate.sh` before merge.

## Rollback
- Revert the latest service contract change set.
- Re-run validation and determinism checks to confirm baseline restoration.

## Incident Steps
- Detect: failed validation gates, moderation violations, missing evidence refs, or benchmark regressions.
- Contain: freeze release, disable experimental path outputs, and route to deterministic baseline flow.
- Recover: restore last compliant contract set and regenerate trace-linked incident summary.
- Verify: all required scripts pass and evidence/trace linkage is restored.

## Fallback Strategy
- If OpenAI API path is degraded or blocked, produce no autonomous verdict and emit governance-safe fallback notes requiring human review.
- Preserve evidence refs and trace refs so audit continuity remains intact.

## Access and Key Revocation
- Rotate external API credentials according to incident severity.
- Remove access for non-compliant operators and record revocation trace refs.
