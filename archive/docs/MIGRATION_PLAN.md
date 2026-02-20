# Migration Plan (PR#1 - ai-governance)

Purpose: lock `ai-governance` as the constitution repo (policy + contracts + docs only) and move all runtime code to the `engine` repo.

Note:
- Source path mappings below are migration-time references (historical).
- Some listed source paths no longer exist in current `ai-governance` working tree.

Principles
- `ai-governance` will not accept runtime code PRs going forward.
- `contracts` changes use SemVer and must state whether the change is breaking; breaking changes are disallowed here (publish a new versioned contract file instead).
- PR#2 (engine) must be “no behavior change” — structure relocation only.
- Legacy alias naming is deprecated; migration must adopt `kernel` naming for new runtime package/module paths.

Migration map (source → engine target)
- `legacy runner package` → `engine/packages/runner/` (rename target: `kernel-runner`)
- `legacy core package` → `engine/packages/core/` (engine root must not be used directly; rename target: `kernel-core`)
- `mcp/obsidian-mcp` → `engine/integrations/mcp/obsidian/`
- `mcp/workflow-mcp` → `engine/integrations/mcp/workflow/`
- `mcp/trends-mcp` → `engine/integrations/mcp/trends/`
- `mcp/usage-bridge` → `engine/integrations/mcp/usage-bridge/`
- `scripts/*` → `engine/tools/scripts/`
- `_artifacts` remains in `ai-governance` (historical/output only)

Dependency direction
- `ai-governance` → `engine` → `apps`; reverse dependencies are not allowed.

Verification checklist (PR#1 ready when all true)
- `ai-governance` contains no runtime code.
- `contracts/` exists with versioned interfaces/schemas.
- Engine builds cleanly after relocation (validated in PR#2).
