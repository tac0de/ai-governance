# Secrets Tiering Policy v1

## Policy ID
STP-V1

## Purpose
Define a conservative secret activation model to minimize blast radius while preserving operational continuity.

## Tiers
1. `none` (default)
   - No privileged secret required.
   - Allowed for deterministic local governance checks.

2. `admin-only`
   - Requires `OPENAI_ADMIN_API_KEY`.
   - For governance/admin data-plane tasks only.

3. `repo-write`
   - Requires `OPENAI_ADMIN_API_KEY` and `REPO_ACCESS_TOKEN`.
   - For controlled write operations to repositories.

## Enforcement Rule
- Workflows must declare a `SECRET_TIER` source:
  - dispatch input (preferred)
  - repository variable fallback
- If required secrets for selected tier are missing, workflow must fail immediately.

## Defaults
- If no tier is provided, treat as `none`.
- Unknown tier value is invalid and must fail.

## Change Management
Any tier model update requires:
1. policy update
2. workflow gate update
3. ADR update
