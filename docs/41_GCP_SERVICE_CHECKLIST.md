# GCP Service Checklist Runbook

## Objective
Define the governance checklist for current GCP integration status.

## Boundary
- `ai-governance`: checklist schema, policy, and review log.
- Runtime environment (`engine`): actual discovery/collection command execution.

## Checklist focus
- gcloud installation and active account
- project selection status (`GCP_PROJECT_ID`)
- key API enablement (Vertex, Secret Manager, Monitoring, Logging, Billing Budgets, Firestore, Firebase)
- Firebase project linkage
- runtime service account existence
- budget existence state

## Output examples
- `.ops/gcp_service_checklist.md`
- `.ops/gcp_service_checklist.json`

## Note
Generate checklist artifacts in runtime automation layer, then attach summaries back to `ai-governance`.
