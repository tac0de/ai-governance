# The Divine Paradox Onboarding v1

## Purpose
Define a fixed onboarding baseline for the separate `thedivineparadox` product repository (local and remote), while keeping `ai-governance` as the governance/control repository.

## Repository Separation Rule
- `ai-governance`: governance policies, contracts, gates, audit standards.
- `thedivineparadox`: product code, UX, deployment pipeline, runtime integrations.
- Do not mix product runtime code into `ai-governance`.

## Local Repository Baseline (`thedivineparadox`)
Recommended minimum structure:

- `app/` (product runtime source)
- `infra/` (deployment descriptors and environment overlays)
- `scripts/` (local run/deploy wrappers)
- `.github/workflows/` (repo-owned product workflows)
- `docs/` (product-facing notes)

## Remote Repository Baseline
- Repository: `tac0de/thedivineparadox` (separate from `tac0de/ai-governance`).
- Branch protection: enabled on `main`.
- Actions permissions: least privilege, default read-only.
- Reusable governance checks may be called from `ai-governance` when needed.

## GCP Deployment Baseline
- Environment flow: `local test -> staging deploy -> production deploy`.
- Deploy path must be explicit in repo docs (`infra/`):
  - service name
  - region
  - artifact source
  - rollback command
- Production deployment requires release gate PASS from governance checks.

## OpenAI API Integration and Token Optimization Baseline
- API key management:
  - Runtime key stays in `thedivineparadox` secrets.
  - Governance/admin keys stay in `ai-governance` where applicable.
- Token optimization defaults:
  - set explicit model allowlist
  - cap max output tokens per request
  - enforce request budget ceiling per period
  - prefer cached/context-short prompts by default
- Any budget policy change must be documented before rollout.

## Required Gates Before First Production Deploy
1. Secrets tier is set and validated.
2. OPM/roles charter version gates are passing.
3. Incident template linkage is active for failure paths.
4. Done Gate criteria are marked `DONE`.

## Hand-off Protocol
- Product ideas are provided by the architect.
- Internal role owners convert ideas into execution tickets by role:
  - Product/Domain owner
  - Policy owner
  - Control-plane operator
  - Audit owner
- Each ticket must map to one governance gate and one verification artifact.

## Change Management
Any onboarding baseline change requires:
1. update this charter document
2. update linked policy references in `README.md`
3. record ADR in `constitution/decision-log/` when boundary/risk changes
