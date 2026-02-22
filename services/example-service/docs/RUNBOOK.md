# RUNBOOK

## Deploy
- Submit metadata changes with updated registry references and run all governance scripts.

## Rollback
- Revert last service metadata commit and re-run validation suite.

## Incident Steps
- Freeze non-compliant changes.
- Record failing path and validation message.
- Apply least-change fix and verify deterministic pass.

## Access and Key Revocation
- Remove service access tokens from integration stores and rotate keys.
