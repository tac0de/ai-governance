# Service Report Sheet

## Scope
Service-level inventory only (not feature-level implementation details).

Note:
- `Repo/Path` values are external runtime-repo (`kernel-engine`) references, not local `ai-governance` paths.

## Current Services

| Service | Layer | Repo/Path | Status | Owner | KPI (Primary) | Value |
|---|---|---|---|---|---|---|
| Kernel Core Runtime | Engine | `kernel-engine/packages/core/` | Active (scaffold + runtime modules) | AI Operator (President) | Runtime health pass rate | Core execution/storage runtime for platform logic |
| Local Runner Service | Engine | `kernel-engine/packages/runner/runner` | Active | AI Operator (President) | Deterministic replay pass rate | Deterministic local doctor/gate/report execution flow |
| Obsidian MCP Service | Integration | `kernel-engine/integrations/obsidian-mcp` | Active | MCP Sub-agent (Integration) | MCP success request ratio | Vault note bridge for listing/reading/change workflows |
| Workflow MCP Service | Integration | `kernel-engine/integrations/workflow-mcp` | Active | MCP Sub-agent (Integration) | MCP tool-call success ratio | Workflow-side utility tools for orchestration support |
| Usage Bridge Service | Integration | `kernel-engine/integrations/usage-bridge` | Planned (feasibility stage) | MCP Sub-agent (Planned) | Telemetry capture completeness | Usage/telemetry bridge layer for runtime insight |
| Trends MCP Service | Integration | `kernel-engine/integrations/trends-mcp` | Planned (placeholder) | MCP Sub-agent (Planned) | Source freshness coverage | Trend/data connector slot for future integrations |
| Ops Automation Service | Engine Tools | `kernel-engine/tools/scripts` | Active | AI Operator (President) | Guard check pass rate | Operational automation, validation, and guard routines |

## Executive Summary
- Built services are concentrated in runtime core + MCP integration + ops automation.
- Product app services are intentionally deferred; current focus is infrastructure reliability.
- Expansion should follow approved MCP sub-agent workflow and contract boundaries.

## Next Review Trigger
- Re-run this sheet when a new MCP module is added or when any service moves from planned to active.
- Re-run this sheet when owner assignment or primary KPI definition changes.
