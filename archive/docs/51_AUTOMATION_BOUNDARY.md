# Automation Boundary (ai-governance vs outside-this-repo)

## Objective
Keep `ai-governance` as constitution-only while allowing automated execution and artifact exchange in downstream repos.

## Storage and Ownership Rules
- `ai-governance` stores policy, contracts, governance docs, migration plans, and result summaries only.
- Runtime traces, raw logs, replay inputs/outputs, and build artifacts must live outside this repo (engine-side storage/repo).
- `ai-governance` may store pointers/indexes to external artifacts (ID, URI, checksum, timestamp), not raw payloads.

## Write Policy
- Agents can read `ai-governance` for policy/contracts at any time.
- Agents must not write runtime code or runtime artifacts into `ai-governance`.
- Any automation that generates execution output writes to `engine` paths first, then writes a short summary back to `ai-governance/docs`.

## DTP Artifact Policy
- `.dtp` is a deterministic machine artifact for replay and verification.
- `.md`/`.txt` is human-facing explanation and decision context.
- Both are required for pilot and operations:
  - `.dtp`: reproducibility
  - `.md`/`.txt`: reviewability and governance

## Document Classes
- Command docs (machine-facing): strict, executable conventions and contract constraints used by agents and automation.
- Explanation docs (human-facing): intent, rationale, and operational understanding for reviewers/operators.
- Logs (machine diary): append-only execution records and replay evidence, stored outside this repo with indexed pointers in `ai-governance`.

## MCP Creation Policy
- MCP servers are not pre-created in `ai-governance`.
- MCP components are created by sub-agents only when a concrete integration need is approved.
- New MCP work is implemented in `engine` integration paths and linked back to `ai-governance` governance docs.

## Validation Gate
- PRs to `ai-governance` fail review if they include runtime code paths (`src/`, runtime `mcp` servers, executable service packages).
- PRs to `engine` must reference related `ai-governance` contracts/policies when behavior touches governed interfaces.

## v0 Exception (Hunbup/Hub Module Split)
- `hub/` is allowed only as a deterministic v0 execution experiment module (`validate`, `run`, `audit`) with local CLI usage.
- `constitution/` remains the single source of truth for normative rules (Markdown, schemas, reason codes, test vectors).
- Runtime serviceization, network execution expansion, and plugin-style runtime extension are out of scope and explicitly disallowed in v0.
