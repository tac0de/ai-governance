# Minimal Main-Hub Strategy

## Purpose
Keep `ai-governance` as a constitution repository only, while limiting active ownership to `engine` level and touching `apps` only when needed.

Core concept reference: `docs/66_MAIN_HUB_CONCEPT.md`.

## Operating Intent
- Primary control surface: `ai-governance` + `engine`.
- `apps` are optional involvement, activated only by explicit product need.

## Keep in ai-governance (final)
- `contracts/` (versioned interfaces and schemas)
- `docs/` (governance, architecture, migration policies)
- `README.md`, `REPOS.md`, `DECISIONS.md`, `MASTER_CONTEXT.md`, `LOGS/`
- CI/policy guardrails under `.github/workflows/` that enforce constitution scope

## Remove from ai-governance (by manual migration)
- Runtime/service implementation directories
- Runtime MCP server implementations
- Runtime execution scripts and runtime build assets
- Heavy generated runtime artifacts (store outside this repo)

## Ownership Boundary
- `ai-governance`: governance truth and contract control
- `engine`: all runtime orchestration, adapters, execution traces, replay tooling
- `apps`: consume engine contracts/APIs only when product delivery requires

## Dependency Rule
- Allowed: `ai-governance -> engine -> apps`
- Blocked: any reverse dependency to `ai-governance`

## Manual Migration Sequence (user-operated)
1. Move runtime paths from `ai-governance` to `engine` using the approved mapping.
2. Run engine build/test and confirm no behavior change.
3. Replace moved paths in `ai-governance` with short docs/pointers only.
4. Keep only governance/contracts/docs in `ai-governance`.

## Definition of Done
- No runtime code remains in `ai-governance`.
- Contracts and governance docs are the only change surface in `ai-governance`.
- Engine runs successfully after migration.
- Apps remain out of scope unless explicitly activated.
