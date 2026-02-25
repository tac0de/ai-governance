# Obsidian MCP Onboarding Report 2026-02-25

## Repository
- URL: `https://github.com/tac0de/obsidian-mcp`
- Visibility: `PUBLIC`
- Default branch: `main`
- Initial tag: `v0.1.0`
- Local path: `/Users/wonyoung_choi/projects/obsidian-mcp`

## Implementation Snapshot
- Runtime stack:
  - Node.js `>=20`
  - `@modelcontextprotocol/sdk`
  - `zod`
  - `zod-to-json-schema`
- Transport:
  - `stdio` only (v0.1)
- Tool surface (read-only):
  - `vault.list_notes`
  - `vault.read_note`
  - `vault.search_notes`
  - `vault.get_metadata`

## Determinism and Guardrails
- Deterministic ordering:
  - sorted note paths
  - sorted search matches
- Boundary controls:
  - enforced `OBSIDIAN_VAULT_ROOT`
  - absolute/traversal/symlink escape blocked
  - max file size bound (`MAX_FILE_BYTES`, default `262144`)
- Side-effect controls:
  - no write tools
  - no outbound network calls in handlers

## Quality Gates
- `npm run typecheck` => pass
- `npm run test` => pass
- `npm run build` => pass
- Test coverage focus:
  - deterministic re-call equality
  - traversal rejection with fixed error code prefix
  - empty query rejection
  - oversized file rejection

## OSS Metadata
- License: `MIT`
- Funding:
  - `.github/FUNDING.yml` => `github: [tac0de]`
- Added:
  - `README.md`
  - `SECURITY.md`
  - `CONTRIBUTING.md`
