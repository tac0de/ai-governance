# ai-governance

Constitution repo for the kernel platform: this repo defines governance, contracts, and architecture rules for deterministic AI operations.

## In 10 seconds
- `ai-governance` defines rules.
- `engine` executes runtime orchestration.
- `apps` deliver user experiences.
- Direction is fixed: `ai-governance -> engine -> apps` (no reverse dependency).

## Architecture layers
- Layer 1 (`Orchestration Governance`): policy, contracts, decision records in `ai-governance`.
- Layer 2 (`Multi-Orchestration Runtime`): adapters, execution, traces, replay in `engine`.
- Layer 3 (`Product Architecture`): domain apps and UX surfaces in `apps`.

## What this repo is
- Source of truth for governance and architecture boundaries.
- Versioned contract home (`contracts/`).
- Human-readable operating docs and migration plans (`docs/`).

## What this repo is NOT
- No runtime service code.
- No runtime MCP server implementation.
- No build artifacts, binaries, or infra execution payloads.

## Main-Hub v0 Exception
- `constitution/` is the normative source for v0 (schemas, reason codes, deterministic cases).
- `hub/` is a limited deterministic runtime module for v0 (`validate`, `run`, `audit`) on Node 20+.
- This exception is scoped to local/offline verification only and does not allow service deployment.

### v0 CLI
- `cd hub && npm install`
- `cd hub && npm run build`
- `node hub/dist/index.js validate --plan constitution/cases/pass/case001.plan.json`
- `node hub/dist/index.js run --plan constitution/cases/pass/case001.plan.json --outdir out/case001`
- `node hub/dist/index.js audit --plan constitution/cases/pass/case001.plan.json --result out/case001/result.json --evidence out/case001/evidence.json --out out/case001/audit.json`

## Governance rules
- PR required for all changes; reviewer required.
- Contracts use SemVer; breaking change is blocked in-place (publish new version instead).
- Scope gate: runtime paths are blocked in this repo by CI.
- Naming gate: legacy aliases are blocked for new changes; use `kernel-*` / `kernel/*`.

## Start here
- Contracts: `contracts/`
- Docs language rule: `docs/08_AGENT_HUMAN_DOC_GUIDE.md`
- Migration boundary: `docs/MIGRATION_PLAN.md`
- Automation boundary: `docs/51_AUTOMATION_BOUNDARY.md`
- Offline high-privilege checklist: `docs/63_OFFLINE_WORK_CHECKLIST.md`
- Docs-only keep list: `docs/54_MAIN_HUB_KEEP_LIST.md`
- Local + remote parser: `docs/65_LOCAL_REMOTE_REPO_PARSER.md`
- Main-hub concept: `docs/66_MAIN_HUB_CONCEPT.md`
- OpenAI admin audit workflow: `docs/67_OPENAI_ADMIN_AUDIT_WORKFLOW.md`
- OpenAI weekly usage workflow: `.github/workflows/openai-usage-weekly-report.yml`
- Reusable auto-merge workflow: `.github/workflows/reusable-auto-merge.yml`
- Reusable personal gallery auto-push workflow: `.github/workflows/reusable-personal-gallery-auto-push.yml`
- Reusable personal gallery change-report workflow: `.github/workflows/reusable-personal-gallery-change-report.yml`
- Personal gallery auto push workflow guide: `docs/68_PERSONAL_GALLERY_AUTO_PUSH_WORKFLOW.md`
- Model adapter audit baseline: `docs/69_MODEL_ADAPTER_AUDIT_BASELINE.md`
- DTP protocol principles: `docs/70_DTP_PROTOCOL_PRINCIPLES.md`
- Engine trace 1.1.0 mapping checklist: `docs/71_ENGINE_TRACE_110_MAPPING_CHECKLIST.md`
- Testing department baseline: `docs/72_TESTING_DEPARTMENT.md`
- Error management department baseline: `docs/73_ERROR_MANAGEMENT_DEPARTMENT.md`
- MCP taskforce baseline: `docs/74_MCP_TASKFORCE.md`
- Finance/accounting department baseline: `docs/75_FINANCE_ACCOUNTING_DEPARTMENT.md`
- Historiqa execution ladder: `docs/76_HISTORIQA_EXECUTION_LADDER.md`
- Weekly finance template: `docs/77_WEEKLY_FINANCE_REPORT_TEMPLATE.md`
