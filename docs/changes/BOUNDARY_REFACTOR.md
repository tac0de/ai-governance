# Boundary Refactor Change Log

## Intent

Apply trust-boundary isolation so governance core remains deterministic and audit-focused while MCP implementation volatility is decoupled.

## File Changes

- Added `docs/architecture/TRUST_BOUNDARY.md`
  - Fixed decision: hybrid with externalized MCP implementations (B).
  - Defined core vs extension boundary and prohibited behaviors.
- Added `scripts/core_boundary_gate.sh`
  - Core gate: JSON validity check, hub validate, canonicalization + SHA-256, deterministic semantic verdict check.
- Added `.github/workflows/trust-boundary-core-gate.yml`
  - Core-only CI gate on core paths.
- Added `conformance/README.md`
  - Declared replay/offline conformance contract.
- Added `conformance/mcp.manifest.example.json`
  - Example MCP manifest aligned to governance contract fields.
- Added `conformance/fixtures/trello-replay/manifest.json`
  - Replay fixture metadata (offline mode).
- Added `conformance/fixtures/trello-replay/golden/input.json`
  - Fixed input fixture.
- Added `conformance/fixtures/trello-replay/golden/output.json`
  - Fixed output fixture.
- Added `conformance/fixtures/trello-replay/golden/output.sha256`
  - Canonical output hash.
- Added `scripts/conformance_run.sh`
  - Replay-only conformance runner with PASS/FAIL output.
- Added `.github/workflows/mcp-conformance.yml`
  - Separate CI workflow for MCP conformance assets.
- Added `packages/mcps/README.md`
  - Declared no executable MCP implementations in-repo.
- Updated `README.md`
  - Clarified supported execution path and trust boundary.

## Structural Move

- Moved local MCP implementation from `packages/trello-mcp` to external sibling location: `../mcp-remote-trello/trello-mcp`.

## Risks

- Existing local workflow that expects `packages/trello-mcp` in this repository will break until it points to the external location.
- Core deterministic check is semantic (`status`, `reason_code`, `governance_command`) because current evidence includes volatile fields.
