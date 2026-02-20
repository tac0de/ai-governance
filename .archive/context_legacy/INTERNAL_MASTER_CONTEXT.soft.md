# MASTER_CONTEXT

## 0.1) Reasoning level policy (default):

- low: Copy edits, simple HTML/CSS edits, small refactors, file moves, rename-only changes, one-liner scripts, trivial Q&A.
- medium: Typical feature work, glue code, CLI wiring, straightforward bugfixes, basic tests, small data transforms.
- high: Cross-file refactors, non-trivial debugging, concurrency, performance work, security/auth flows, infra changes, release steps, anything that can break prod or lock accounts.
- very high: Architecture decisions, migrations, irreversible operations, incident response, cryptography/key handling, access-control changes, multi-system rollouts.

Escalation rules:

- If user says "urgent", "high-stakes", "production", "security", "login/account", use high (or very high if keys/migrations).
- If requirements are ambiguous or success criteria unclear, use high until clarified.
- If a single mistake can cause data loss or account lockout, use very high.

Operator UI:

- Prefix every assistant response with `level=<low|medium|high|very high>`.
- Default response format (v2):
  - `1) Conclusion (1 line):`
  - `2) Risk (1 line, or "none"):`
  - `3) One next action (exact command/file/button):`

## 0.2) LLM model set (max 3) + prompting standard

- Model policy: keep the OpenAI generation model surface area <= 3.
- Current allowlist: `gpt-5-nano`, `gpt-5-mini`, `gpt-5`.
- Source + template: `docs/45_LLM_MODEL_SET_AND_PROMPTING_STANDARD.md`.

## 0.3) No-PII-to-LLM policy (all providers)

- Rule: Never send personal data to any hosted LLM provider.
- Enforcement: Keep model-facing context in curated packs; run `scripts/pii_guard.sh` as a best-effort detector.
- Note: If personal data must be processed, do it outside the hosted LLM boundary (redaction/pseudonymization first).

## 0.4) Prompt skills (command templates)

- Source + templates: `docs/46_PROMPT_SKILLS_COMMANDS.md`.
- Local helper: `scripts/prompt_skill.sh {BUGFIX|DOC_WRITE|SAFE_PUBLISH}`.

## 0.4) Prompt skills (command templates)

- Source + templates: `docs/46_PROMPT_SKILLS_COMMANDS.md`.
- Local helper: `scripts/prompt_skill.sh {BUGFIX|DOC_WRITE|SAFE_PUBLISH}`.

## 0) TL;DR

- Now: Added conservative local-first Codex runner under `codex/` (doctor/gate/report + schema/templates/docs).
- Now: Added `codex-result` artifact publishing to `security-baseline` GitHub Actions workflow.
- Now: Added 99% autonomy remote background workflow with `human_gate_required` issue handoff.
- Now: Added local-only hardening script for Warp privacy controls.
- Now: Consolidated core operation guides into concise English docs and added story-doc generator script.
- Now: Added Kakao task boundary matrix and automation router (`api_auto` vs `human_gate`).
- Now: Added natural-language ops reporting and optional Kakao notification path.
- Now: Enforced default `gpt-5-nano` model policy with high-tier human-gate escalation.
- Now: Added OpenAI model allowlist (max 3) and prompting standard doc.
- Now: Added retry safety policy (3 retries per step, then `human_gate_required`).
- Now: Fixed Kakao notify script portability by removing `rg` dependency.
- Now: Added local_time_now to `workflow-mcp` for reliable local clock sync in ChatGPT.
- Now: Added `run_contract` validation script and CI enforcement in security-baseline workflow.
- Now: Added `run_contract` generation/validation artifact flow in autonomy-99 remote workflow.
- Now: Added bilingual human operator instructions (`docs/35_HUMAN_INSTRUCTIONS_BILINGUAL.md`).
- Now: Added Top4 account security runbook and local progress tracker script for Google/GitHub/Apple/ChatGPT hardening.
- Now: Added tac0de trace demo (local generator + demo runner) to produce Deep-mode trace artifacts under `.ops/` without side effects.
- Now: Added local-only hardening script for Warp privacy controls.
- Now: Added ability-to-codex-engine sync/migration toolkit and login+DB expansion scaffold (`codex-engine/`).
- Now: Added GCP current integration checklist generator and pushed Firebase auth/progress endpoint into codex-engine remote.
- Now: Added repo-to-Obsidian sync script and synced docs/LOGS/context files into vault `Sync/mastermind-hub`.
- Blocker: Service runtime inventory and production topology are still UNKNOWN.
- Next: Apply 99% autonomy loop to channel-kakao MVP execution loop.
- Constraints: Keep changes minimal and non-disruptive.
- Security: Never store credentials in tracked files.

## 1) Active Projects

### Project: mastermind-hub

- Objective: Operate as a synchronization hub for cross-session execution context.
- Current state: Guardrails, CI checks, orchestration commit-discipline guard, usage-bridge MCP tools, `local_time_now` MCP time sync tool, `obsidian-mcp` + Obsidian-to-RAG sync pipeline, `run_contract` validation across baseline/autonomy workflows, Top4 account security runbook/tracker, untracked-file classifier, GCP secure/cost automation script, 94% strategy tooling, 99% autonomy loop script with human-gate flow, remote background workflow, and local Codex runner baseline are present.
- Next actions (1-5):
  1. Keep MASTER_CONTEXT.md aligned with stable facts.
  2. Record explicit choices in DECISIONS.md.
  3. Append one LOGS file per significant session.
  4. Enforce orchestration changes with context + decision + log in one commit.
  5. Validate sync-hub workflow on push/PR.
- Links: UNKNOWN

## 2) Stack & Environment

- Client: UNKNOWN
- Backend: Shell scripts + documentation orchestration
- Firebase products: UNKNOWN
- Runtime versions: UNKNOWN
- Deploy workflow: GitHub Actions + manual script execution
- CI status: Sync Hub Check workflow added (pending remote run)

## 3) Constraints

- Must: Use repository files as operational source of truth.
- Must not: Store secrets in tracked files or logs.
- Unknowns: Project/service inventory, exact runtime matrix, production topology.

## 4) Risks / Security Notes

- Risk: Context drift between sessions and tools.
- Mitigation: Enforce updates in MASTER_CONTEXT.md, DECISIONS.md, and LOGS/ for each significant action.

## 5) Backlog

- Idea: Channel-neutral bot core + channel adapters / Monetization trigger: Paid openchat conversion > stable weekly threshold / Constraint: Keep ops simple and low-cost.
