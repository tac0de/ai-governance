# GCP Secure + Cost Automation (Manual-Prereq Split)

## Objective
Use Google AI services with strong security boundaries and cost control.

## Boundary
- `ai-governance`: policy and audit-oriented documentation.
- Runtime provisioning scripts: externalized to runtime repository (`engine`).

## Manual prerequisites (account owner only)
- `gcloud auth login`
- Billing account linkage to project
- Optional budget notification channels

## Governance rules
- Keep `GCP_ENABLE_REAL_APPLY=false` by default.
- Enable real apply only during controlled setup windows.
- Keep sensitive data out of hosted-LLM context.

## Operational note
If infrastructure apply commands are needed, run them in `engine` where runtime automation is owned.
