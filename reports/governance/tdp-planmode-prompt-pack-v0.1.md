# TDP Plan Mode Prompt Pack v0.1

Purpose: copy-paste prompts for next-day planning and execution on TheDivineParadox (TDP) hardening and growth.
Date: 2026-02-23

## Current Baseline
- Governance path is mandatory bridge.
- Shared service SLO contract is enforced from ai-governance.
- TDP has analytics and KPI endpoints (`/events/ux`, `/kpi-summary`).
- MCP reality: only `example-mcp` is registered/allowlisted; no production-grade MCP portfolio yet.

---

## Prompt 00: Session Bootstrap (Use First)
```text
You are in plan mode for TheDivineParadox.

Hard constraints:
1) Mandatory governance bridge path. No direct bypass.
2) Deterministic-first design for verdict-critical paths.
3) Follow this report format by default:
   1. WHAT I DID
   2. WHERE IT IS RUNNING
   3. HUMAN REQUIRED (links + paths)
   4. RISK / UNKNOWN
4) Keep changes minimal, testable, and API-evidence based.

Context:
- Repo 1 (governance core): /Users/wonyoung_choi/ai-governance
- Repo 2 (service): /Users/wonyoung_choi/projects/thedivineparadox

Task:
- Start with a short state audit, then propose one macro plan with clear stop conditions.
- Do not ask repeated micro-approvals unless scope/risk changes.
- Execute immediately after plan approval.
```

---

## Prompt 01: Macro Ideation Sprint (Retention + Conversion)
```text
Run a constrained ideation sprint for TDP with one objective:
Increase user return and depth without violating deterministic governance.

Deliverables:
1) 12 ideas total (no fluff):
   - 4 low-cost quick wins
   - 4 medium experiments
   - 4 high-upside bets
2) For each idea, include:
   - Mechanism (why it may work)
   - Implementation scope (frontend/backend/MCP)
   - Primary KPI impact (D1, vote completion, post-vote result open, fallback rate)
   - Failure mode and rollback trigger
3) Rank top 3 by impact-to-effort and governance risk.
4) Output one recommended 2-week sequence.

Rules:
- Prefer simple UX first, complexity later.
- No idea that depends on hidden randomness for core verdict path.
- Keep evidence and traceability requirements explicit.
```

---

## Prompt 02: MCP Portfolio Blueprint (Most Important Next Step)
```text
Design a production MCP portfolio for TDP.
Current MCP state is effectively empty (example placeholder only).

Output exactly 3 MCPs for phase-1:
- MCP-A: User Signal Analytics MCP
- MCP-B: Experiment Orchestrator MCP
- MCP-C: Narrative Safety and Fallback MCP

For each MCP define:
1) Job-to-be-done
2) Inputs/outputs contract (JSON shape, deterministic fields)
3) Allowed capabilities and risk tier
4) Required approval tier
5) Trace linkage requirements (intent_ref, evidence_ref, usage source_ref)
6) Failure policy and fallback behavior
7) Minimal conformance tests

Also produce:
- Registry updates needed in ai-governance (`control/registry/mcps.v0.1.json`)
- Allowlist updates needed for TDP (`services/thedivineparadox/mcp.allowlist.json`)
- Rollout order with one-day blast radius controls.
```

---

## Prompt 03: MCP Contract Authoring (Governance Core Only)
```text
Implement governance-side artifacts for one selected MCP (no product runtime implementation in governance repo):
- mcps/<mcp-name>/manifest.json
- mcps/<mcp-name>/docs/MCP.md
- mcps/<mcp-name>/docs/CAPABILITIES.md
- mcps/<mcp-name>/docs/SECURITY.md
- Registry wiring
- Allowlist wiring for TDP
- Validation compatibility with scripts/validate_all.sh

Rules:
- Do not implement real runtime connectors in ai-governance.
- Keep artifacts deterministic and schema-aligned.
- Add only minimal required files.

After changes:
- Run governance validation scripts.
- Return exact files changed and unresolved risks.
```

---

## Prompt 04: Service-Side MCP Adapter Plan (TDP Repo)
```text
In /Users/wonyoung_choi/projects/thedivineparadox, design service-side adapters for approved MCP contracts.

Goal:
- Integrate MCP usage without breaking existing APIs (`/daily-question`, `/vote`, `/daily-result`, `/trace`, `/kpi-summary`).

Required output:
1) Adapter boundaries (where MCP calls happen, where they cannot happen)
2) Deterministic fallback path for each adapter
3) API-level evidence exposure points
4) Migration or storage needs
5) Test plan: unit + integration + failure injection

Do not overbuild. Focus on one thin vertical slice first.
```

---

## Prompt 05: Token-Efficiency and Trace Instrumentation
```text
Optimize agent and LLM operation cost under deterministic trace protocol.

Produce:
1) Measurement map:
   - Where usage is measured (API layer, MCP layer, recompute path)
   - How usage is stored and surfaced
2) Cost gates:
   - Budget thresholds for prompt/completion/total tokens
   - Automated fail or degrade policy
3) Trace schema alignment:
   - Ensure measured usage references are hash-linked and append-only
4) Minimal code changes + validation commands

Constraints:
- No hidden side channels.
- No non-deterministic verdict logic.
```

---

## Prompt 06: One-Shot Planning + Autopilot Execution
```text
Run one-shot planning and execution for TDP within approved scope.

Planning gate must include:
- objective
- scope
- forbidden actions
- risk tier
- completion criteria
- rollback condition

After approval:
- Execute in autopilot mode.
- Interrupt only if scope deviation or risk escalation is required.
- End with default report format.
```

---

## Prompt 07: Release Readiness and Kill-Switch Review
```text
Run release readiness review for TDP with strict bug/risk focus.

Checklist:
1) CORS and origin policy
2) Secret boundary (staging/prod separation)
3) Explicit DB migration in deploy pipeline
4) Fallback behavior under LLM auth/timeout/error
5) KPI endpoint correctness and null-safe behavior
6) Trace completeness and evidence hash presence
7) Rollback and kill-switch clarity

Output severity-ordered findings first.
If no findings, explicitly state residual risks.
```

---

## Prompt 08: Daily Operator Prompt (Fast)
```text
Today objective: move TDP market validation forward with minimum risk.

Do:
1) Check deployment and health.
2) Check KPI trend and fallback rate.
3) Pick one highest-impact experiment for the day.
4) Implement with deterministic trace/evidence.
5) Ship and report in default format.

Avoid:
- Side quests
- Governance bypass
- Unbounded refactors
```

---

## Prompt 09: If Architect Is Fatigued (Low-Cognitive Mode)
```text
Assume architect provides minimal input.
You must operate with structured defaults and ask only binary/high-value questions.

Default behavior:
- Use mandatory governance path.
- Use smallest safe scope.
- Prefer reversible changes.
- Preserve deterministic constraints.

Ask at most 3 questions, each with recommended option first.
Then proceed autonomously.
```

---

## Suggested Tomorrow Run Order
1) Prompt 00
2) Prompt 02
3) Prompt 03 (for MCP-A first)
4) Prompt 04
5) Prompt 05
6) Prompt 07
7) Prompt 08

