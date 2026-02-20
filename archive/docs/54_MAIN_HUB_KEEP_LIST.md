# Main-Hub Keep List (Explicit)

## Keep directories
- `.github/workflows/`
- `contracts/`
- `docs/`
- `LOGS/`

## Keep root files
- `README.md`
- `REPOS.md`
- `MASTER_CONTEXT.md`
- `DECISIONS.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `PROJECT_STORY_FOR_HUMANS.md`
- `.gitignore`

## Remove/migrate out of ai-governance
- `.archive/`
- legacy runner/core directories
- `mcp/`
- `scripts/`
- runtime outputs and heavy artifacts under `.ops/` (keep lightweight state only)
- Runtime legacy snapshot moved in phase 1: `.archive/docs_only_phase1/`
- Root runtime metadata/tools snapshot moved in phase 2: `.archive/docs_only_phase2/`
- Side project docs archive (2026-02-18): `.archive/side_projects_2026-02-18/`

## Notes
- Runtime implementation should live outside `ai-governance` (engine repo layer).
- Product implementation should live outside `ai-governance` (apps repo layer).
- Dependency direction stays: `ai-governance -> engine -> apps`.
