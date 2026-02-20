# DECISIONS

Note (2026-02-18):
- Historical entries may reference legacy/migrated paths (`scripts/`, `mcp/`) that are no longer executable inside `ai-governance`.
- Treat those paths as decision-time context; current executable surface is under `tools/` and workflow files.

## 2026-02-12: Adopt 94% semi-automation strategy as default platform mode

- Context: Platform work needed higher throughput without removing critical safety approvals.
- Decision: Add `semi_auto_strategy` MCP tool and define 94% automated lane + 6% human-gate lane.
- Rationale (<= 5 lines):
  Preserve speed for repetitive engineering work while keeping risky actions explicitly approved.
- Consequences:
  Daily execution can be mostly automated, but production-risk steps always require human confirmation.
- Follow-ups:
  Apply this strategy to channel-kakao execution and monitor deploy/security/recovery metrics weekly.

## 2026-02-12: Add usage-bridge telemetry tools into workflow-mcp

- Context: Rate-limit and ops telemetry needed a minimal MCP surface before building more sub-MCP servers.
- Decision: Extend `mcp/workflow-mcp` with `source_feasibility`, `rate_limit_snapshot`, `ops_metrics_summary`.
- Rationale (<= 5 lines):
  Reuse existing MCP runtime, avoid extra dependencies, and deliver immediate integration value.
- Consequences:
  Usage telemetry can now be read from `.ops` via MCP tools with no UI scraping dependency.
- Follow-ups:
  Connect these tool outputs to channel-kakao admin/operator flow and report view.

## 2026-02-12: Enforce orchestration commit discipline via local guard

- Context: Orchestration updates can drift from MASTER_CONTEXT/DECISIONS/LOGS under time pressure.
- Decision: Add `scripts/sync_hub_guard.sh` and run it from `.githooks/pre-commit`.
- Rationale (<= 5 lines):
  Prevent common misses before commit with minimal local checks and no new dependencies.
- Consequences:
  Commits touching orchestration/policy paths must include context update, log entry, and decision update.
- Follow-ups:
  Mirror the same behavior in CI checks if stricter enforcement is needed.

## 2026-02-12: Bootstrap sync hub operational memory

- Context: Shared context across ChatGPT and Codex sessions was fragmented.
- Decision: Establish MASTER_CONTEXT.md, DECISIONS.md, and LOGS/ as required sync artifacts in-repo.
- Rationale (<= 5 lines):
  Keep one source of truth, reduce context drift, and enforce traceability with minimal complexity.
- Consequences:
  Every significant session must write a log and update stable facts/decisions.
- Follow-ups:
  Validate sync-hub CI workflow and keep templates enforced.

## 2026-02-12: Move default execution lane to 99% autonomy (security-first)

- Context: Non-security development operations needed higher autonomy after baseline guardrails stabilized.
- Decision: Add `scripts/autonomy_99_loop.sh` as the default execution loop; keep secret scan and security controls mandatory with `human_gate_required` on session/approval boundaries.
- Rationale (<= 5 lines):
  Most day-to-day operations are low-risk and should run end-to-end without manual coordination overhead.
- Consequences:
  Engineering throughput increases while security checks remain hard-stop gates and manual auth/approval can resume loop explicitly.
- Follow-ups:
  Apply this loop to each active service and monitor metrics from `.ops/ops_metrics.csv`.

## 2026-02-12: Add remote background autonomy workflow with human-gate issue handoff

- Context: User requested remote background execution with approval only when security/session boundaries are hit.
- Decision: Add `.github/workflows/autonomy-99-remote.yml` to run every 30 minutes and open a GitHub issue when loop exits with `human_gate_required`.
- Rationale (<= 5 lines):
  Keep default operations autonomous while surfacing only boundary exceptions for human action.
- Consequences:
  Platform loop runs unattended on GitHub-hosted runners and escalates only gate-required events.
- Follow-ups:
  Add repository labels `operations` and `human-gate` for issue triage consistency.

## 2026-02-12: Add local-only hardening command for terminal privacy

- Context: User wanted local-only operation while keeping external automation from this Mac.
- Decision: Add `scripts/local_only_mode.sh` to enforce Warp cloud/sync/telemetry/crash-reporting settings to OFF and emit status JSON.
- Rationale (<= 5 lines):
  Keep execution local-first and reduce accidental external data exposure during secret handling.
- Consequences:
  Local-only mode can be applied and verified with one command.
- Follow-ups:
  Re-run status checks after Warp updates or reinstalls.

## 2026-02-12: Consolidate operation docs and add story-doc generator

- Context: Existing docs were verbose and harder to reuse during fast execution sessions.
- Decision: Rewrite core docs (`docs/07`-`docs/20`, `docs/PRIVATE_ACCESS_SETUP.md`) into concise English versions and add `scripts/generate_ai_story.sh`.
- Rationale (<= 5 lines):
  Reduce cognitive overhead and provide a quick narrative export path for human-readable onboarding.
- Consequences:
  Operational guides become shorter and easier to apply consistently.
- Follow-ups:
  Keep new docs aligned with script and workflow behavior as automation evolves.

## 2026-02-12: Define Kakao automation boundary with task router

- Context: User requested clarification on whether Kakao work can run while local machine is offline.
- Decision: Add `docs/27_KAKAO_AUTOMATION_BOUNDARY.md` and `scripts/kakao_task_router.sh`, then wire `AUTONOMY_KAKAO_TASK` into `scripts/autonomy_99_loop.sh`.
- Rationale (<= 5 lines):
  Explicitly separate API-capable tasks from console/login tasks so remote automation can run safely by default.
- Consequences:
  Kakao tasks now resolve to `api_auto` or `human_gate`, with automatic stop on boundary tasks.
- Follow-ups:
  Replace assumptions with verified API coverage per Kakao capability in each production integration.

## 2026-02-12: Keep LLM-cost-free default and add natural-language reporting

- Context: User requested continuous automation without LLM call cost and a readable status report, preferably to Kakao.
- Decision: Add no-cost guard in `autonomy_99_loop.sh` (`AUTONOMY_ALLOW_REAL_LLM=false` default), generate natural report via `scripts/natural_ops_report.sh`, and add optional Kakao memo sender `scripts/send_kakao_report.sh`.
- Rationale (<= 5 lines):
  Maintain cost safety by default while improving operator visibility with concise natural-language updates.
- Consequences:
  Real LLM calls require explicit opt-in; every remote run now produces a readable report artifact.
- Follow-ups:
  Add Kakao token and enable notify flag in GitHub settings if push delivery is required.

## 2026-02-12: Fix model policy to gpt-5-nano and gate high-tier usage

- Context: User approved default nano strategy and requested high-tier usage only as an exception path.
- Decision: Enforce `gpt-5-nano` as default model in automation loop, and require `human_gate` approval for high complexity/high-tier overrides.
- Rationale (<= 5 lines):
  Keep baseline cost low while still allowing controlled escalation for complex tasks.
- Consequences:
  Non-nano model usage or high complexity runs are blocked unless explicitly approved.
- Follow-ups:
  Revisit thresholds after 7-day production metrics and incident review.

## 2026-02-12: Add retry-3 safety stop policy for automation steps

- Context: User requested explicit safety behavior for transient errors under unattended automation.
- Decision: Retry each operational step up to 3 times, then stop with `human_gate_required`.
- Rationale (<= 5 lines):
  Improve resilience against transient failures while preventing repeated unsafe execution loops.
- Consequences:
  Temporary issues may auto-recover; persistent failures escalate cleanly to manual approval.
- Follow-ups:
  Tune retry delay based on production failure patterns.

## 2026-02-12: Add conservative local runner and CI run-result artifact

- Context: User requested a local-first runner that works across repositories without modifying project code paths by default.
- Decision: Add runner structure (policy/schema/runner/templates/docs) and wire `security-baseline` workflow to publish `run_result.json` as `run-result` artifact.
- Rationale (<= 5 lines):
  Establish a minimal, strict result contract and make CI outputs traceable while keeping integration non-breaking.
- Consequences:
  Teams can run `doctor/gate/report` locally and consume a consistent CI artifact without changing core application workflows.
- Follow-ups:
  Optionally extract runner assets into a shared template repository if multi-repo reuse demand increases.

## 2026-02-13: Enforce run-contract validation in security baseline

- Context: Orchestration runs needed a standard approval contract check in CI.
- Decision: Add `scripts/validate_run_contract.sh`, create `.ops/run_contract.json`, and validate/upload it in `.github/workflows/security-baseline.yml`.
- Rationale (<= 5 lines):
  Keep approval boundaries machine-verifiable and prevent silent policy drift.
- Consequences:
  `human_gate_required=true` without `approved_by` now fails validation.
  CI emits `run-contract` as an artifact for audit traceability.
- Follow-ups:
  Extend the same contract generation to autonomy remote workflow after approval UX is finalized.

## 2026-02-13: Extend run-contract enforcement to autonomy remote workflow

- Context: Security baseline had run-contract validation, but autonomy remote loop did not emit the same contract artifact.
- Decision: Add create/validate/upload steps for `.ops/run_contract.json` in `.github/workflows/autonomy-99-remote.yml`.
- Rationale (<= 5 lines):
  Keep policy evidence shape consistent between baseline checks and autonomous execution.
- Consequences:
  `autonomy-99-remote` now emits `autonomy-99-run-contract` artifact every run.
  Exit code `3` is recorded as `human_gate_required` with explicit contract status.
- Follow-ups:
  Replace placeholder approver string with a real approval identity once approval workflow is integrated.

## 2026-02-13: Add bilingual operator instruction doc

- Context: Human-facing instructions needed Korean and English in one place for daily operations.
- Decision: Add `docs/35_HUMAN_INSTRUCTIONS_BILINGUAL.md` and link it from `README.md`.
- Rationale (<= 5 lines):
  Reduce onboarding friction and operator mistakes under mixed-language collaboration.
- Consequences:
  Operators now have a single KR/EN quick-start page for boundary and command rules.
- Follow-ups:
  Keep command examples aligned with script/workflow updates in each release.

## 2026-02-13: Add Top4 account security runbook and progress tracker

- Context: User wanted highest practical security management for Google, GitHub, Apple, and ChatGPT with minimal cognitive load.
- Decision: Add `docs/36_TOP4_ACCOUNT_SECURITY_RUNBOOK.md`, `config/top4_security_baseline.example.json`, and `scripts/top4_account_security.sh`.
- Rationale (<= 5 lines):
  Separate manual identity-proof steps from automatable progress tracking to reduce operational mistakes.
- Consequences:
  Operator now has one command surface (`init/status/next/done/links`) and a shared baseline checklist for four critical accounts.
- Follow-ups:
  Keep provider links/checkpoints updated if account security UI or policy changes.

## 2026-02-13: Add Obsidian MCP + incremental RAG sync + history partition

- Context: User prioritized Obsidian MCP-based large-document RAG linkage, remote continuity, and strict history partition with sensitive dump bucket.
- Decision: Add `mcp/obsidian-mcp`, `scripts/obsidian_rag_sync.sh`, `scripts/obsidian_remote_sync.sh`, and `scripts/history_partition.sh` with runbooks.
- Rationale (<= 5 lines):
  Keep local vault as source of truth, sync only sanitized outputs to GPT, and reduce manual sorting cost with incremental classification.
- Consequences:
  New notes can be ingested from baseline-forward only, sensitive/sexual content can be routed to dump bucket, and remote private mirror is available.
- Follow-ups:
  Tune keyword rules and move from heuristic classification to metadata/tag-driven policy over time.

## 2026-02-13: Add untracked-file classification and GCP secure/cost automation

- Context: User requested worktree cleanup classification and automated Google Cloud integration with strict security/cost posture.
- Decision: Add `scripts/classify_untracked.sh`, `scripts/gcp_secure_cost_setup.sh`, and `docs/39_GCP_SECURE_COST_AUTOMATION.md`; update `.gitignore` for generated/sensitive local artifacts.
- Rationale (<= 5 lines):
  Reduce repository noise, separate local-sensitive outputs, and automate repeatable GCP hardening tasks while preserving human control over identity/billing steps.
- Consequences:
  Untracked files can be categorized quickly, and GCP setup can run in controlled phases (`status/apply/budget`) with `GCP_ENABLE_REAL_APPLY` gate.
- Follow-ups:
  Provide project ID and billing account in `.env`, then run `apply` and `budget` with authenticated gcloud session.

## 2026-02-13: Upgrade Obsidian classification to tag/frontmatter priority

- Context: User prioritized high-throughput large-document classification for Obsidian-to-RAG with fewer heuristic errors.
- Decision: Update `scripts/obsidian_rag_sync.sh` and `mcp/obsidian-mcp/src/server.js` to classify by explicit tags/frontmatter first.
- Rationale (<= 5 lines):
  Explicit metadata is more reliable than raw keyword-only matching for operational note routing.
- Consequences:
  Classification now follows `dump > private > public > keyword fallback`, improving control over GPT sync boundary.
- Follow-ups:
  Add optional team-wide tag convention linting in future.

## 2026-02-13: Add Obsidian tag conflict lint guard

- Context: After tag-priority classification, conflicting tags in one note could still cause policy ambiguity.
- Decision: Add `scripts/lint_obsidian_tags.sh`, run it in `.githooks/pre-commit` (repo mode), and enforce it before `obsidian_rag_sync.sh sync` (vault mode).
- Rationale (<= 5 lines):
  Prevent ambiguous classification early and keep RAG boundary deterministic.
- Consequences:
  Notes containing multiple bucket tags (`dump/private/public`) are blocked until fixed.
- Follow-ups:
  Add optional strict mode requiring at least one explicit bucket tag for target folders.

## 2026-02-13: Add Obsidian tag lint strict mode by path

- Context: Tag conflict lint alone does not prevent missing bucket tags in critical export folders.
- Decision: Extend `scripts/lint_obsidian_tags.sh` with `OBSIDIAN_TAG_STRICT=true` and `OBSIDIAN_TAG_REQUIRED_PATHS` path-prefix policy.
- Rationale (<= 5 lines):
  Guarantee explicit classification for high-sensitivity/high-export paths without forcing all notes.
- Consequences:
  Matching folders fail lint when no bucket tag exists; non-matching folders remain flexible.
- Follow-ups:
  Consider promoting strict mode to default after observing false-positive rate.

## 2026-02-13: Add automatic strict-violation lint report on sync

- Context: User requested a separate report file summarizing strict violations on each `obsidian_rag_sync.sh sync` run.
- Decision: Extend `scripts/lint_obsidian_tags.sh` to emit optional markdown report and wire `obsidian_rag_sync.sh` to write `.ops/obsidian_tag_lint_report.md`.
- Rationale (<= 5 lines):
  Keep strict policy feedback explicit and auditable without scanning terminal logs.
- Consequences:
  Each sync now leaves a lint summary with checked file count and violation list.
- Follow-ups:
  Add timestamped history rotation if report retention needs grow.

## 2026-02-13: Add lint report history rotation on sync

- Context: User approved automatic history retention for Obsidian strict lint reports.
- Decision: Update `scripts/obsidian_rag_sync.sh` to archive timestamped copies under `.ops/obsidian_tag_lint_reports/` after each sync lint run.
- Rationale (<= 5 lines):
  Preserve audit trail across runs without relying on overwritten latest report.
- Consequences:
  Operators can trace strict violations over time and compare run-to-run changes.
- Follow-ups:
  Add retention cap cleanup if history volume becomes large.

## 2026-02-13: Add ability-to-kernel-engine migration and login/DB expansion scaffold

- Context: User requested sync/rename migration from `ability-*` into remote kernel-engine flow, inheritance extraction, and extension from localStorage-only logic to login/database.
- Decision: Add sync/extraction scripts, `docs/40_ABILITY_TO_KERNEL_ENGINE_MIGRATION.md`, and kernel-engine scaffold (`db/schema.sql`, repository adapters, local->DB migration skeleton).
- Rationale (<= 5 lines):
  Keep migration repeatable, auditable, and incremental while preserving legacy gameplay logic.
- Consequences:
  Core inheritance points are extractable as report artifacts, and auth/DB rollout can start without rewriting everything at once.
- Follow-ups:
  Configure actual `../kernel-engine` git remote and wire API auth/session implementation to chosen provider.

## 2026-02-13: Push Firebase auth/progress endpoint and add GCP service checklist

- Context: User requested handling remaining manual parts directly and wanted a checklist for currently integrated/applied GCP services.
- Decision: Push Firebase token verification + authenticated progress endpoint to kernel-engine (`c869bde`), and add `scripts/gcp_service_checklist.sh` with runbook `docs/41_GCP_SERVICE_CHECKLIST.md`.
- Rationale (<= 5 lines):
  Make authentication expansion executable immediately while giving operators a current-state GCP visibility report.
- Consequences:
  kernel-engine now has a secure Firebase ID token verification helper and a protected progress endpoint scaffold; ai-governance can generate `.ops/gcp_service_checklist.{md,json}` on demand.
- Follow-ups:
  Set `.env` (`GCP_PROJECT_ID`, optional billing ID), authenticate gcloud account, and re-run checklist for applied status snapshot.

## 2026-02-14: Limit OpenAI model set to max 3 and adopt an official prompting standard

- Context: User requested limiting large-model usage to a small, stable set and aligning prompts to official guidance.
- Decision: Define an explicit OpenAI model allowlist (max 3) and publish a single prompting standard + template doc (`docs/45_LLM_MODEL_SET_AND_PROMPTING_STANDARD.md`).
- Rationale (<= 5 lines):
  Reduce operational complexity and avoid model sprawl while keeping prompts portable and auditable.
- Consequences:
  Automation runs with real OpenAI calls will raise a human gate if the model is not in the allowlist.
- Follow-ups:
  If/when provider strategy changes, update the allowlist and record the change here.

## 2026-02-14: Adopt No-PII-to-LLM policy across all providers

- Context: User confirmed a strict privacy requirement: prevent personal data leakage while using LLMs.
- Decision: Treat all hosted LLM providers as untrusted and enforce a No-PII-to-LLM boundary.
- Rationale (<= 5 lines):
  "Zero leakage" cannot be guaranteed if PII is sent to hosted APIs; the only robust guarantee is to prevent sending PII.
- Consequences:
  Add a best-effort PII detector (`scripts/pii_guard.sh`) and require it to remain enabled for real OpenAI calls.
- Follow-ups:
  Integrate `pii_guard` at every model-call boundary in services as they are added.

## 2026-02-17: Enforce constitution runtime-path gate and kernel naming transition

- Context: ai-governance must remain policy/contracts/docs only, and legacy alias naming is deprecated.
- Decision: Add CI workflow to block runtime path changes in ai-governance PRs and rename local legacy plan/agent artifacts to `kernel`.
- Rationale (<= 5 lines):
  Convert governance docs into an executable enforcement gate and prevent naming drift.
- Consequences:
  PRs touching forbidden runtime paths in ai-governance fail CI; local operator files now use kernel naming.
- Follow-ups:
  Complete folder-level runtime relocation and final naming cleanup in engine PR#2.

## 2026-02-18: Add read-only OpenAI admin audit workflow for governance automation

- Context: User added `OPENAI_ADMIN_API_KEY` and requested server-side automation value without mixing admin authority into generation paths.
- Decision: Add `tools/openai_admin_audit.js`, schedule `.github/workflows/openai-admin-audit.yml`, and publish sanitized audit artifacts (`.ops/openai_admin_audit_report.{json,md}`).
- Rationale (<= 5 lines):
  Keep admin-key usage constrained to read-only governance checks and create deterministic daily evidence.
- Consequences:
  Organization administration signals (projects/invites/users/audit logs) can be reviewed by workflow summary and artifact without exposing key data.
- Follow-ups:
  If endpoint failures persist, verify org RBAC and admin-key scope, then re-run `workflow_dispatch`.

## 2026-02-18: Codify ai-governance as governance-routing layer only

- Context: User provided a strict architecture statement: ai-governance must not perform domain analysis/prompt/business logic.
- Decision: Add canonical concept doc `docs/66_MAIN_HUB_CONCEPT.md` and command contract example `contracts/command.contract.example.json`.
- Rationale (<= 5 lines):
  Freeze responsibility boundaries in one explicit source so routing/policy decisions stay deterministic and auditable.
- Consequences:
  ai-governance scope is now documented as command validation + policy enforcement + routing + audit only.
- Follow-ups:
  Keep new docs/contract references aligned in README and strategy docs as engine/module interfaces evolve.
