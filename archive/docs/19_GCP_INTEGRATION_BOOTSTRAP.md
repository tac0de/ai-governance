# 19. GCP Integration Bootstrap

## Objective
Prepare GCP resources without overbuilding early.

## Minimal bootstrap
- project selection
- billing account linkage
- firestore baseline
- cloud functions deployment target
- budget alert policy

## Guardrails
- no complex multi-project split at MVP stage
- enforce daily spend alert
- use least-privilege service roles

## Exit criteria
Bootstrap is complete when deploy/test/rollback all run from one documented path.
