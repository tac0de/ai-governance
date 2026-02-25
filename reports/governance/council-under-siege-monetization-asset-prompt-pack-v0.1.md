# Agent-Collab Webgame Monetization + Asset Prompt Pack v0.1

Purpose: `Council Under Siege`를 과금 가능한 라이브 게임으로 고도화하되, 중앙거버넌스 경로와 증빙/추적 규칙을 유지한다.
Date: 2026-02-25

## Current Baseline
- Runtime repo: `/Users/wonyoung_choi/projects/council-under-siege`
- Governance repo: `/Users/wonyoung_choi/ai-governance`
- Local pixel lab: `/Users/wonyoung_choi/local-image-lab`
- Core rule: 과금/경제/정책경계 영향 변경은 기본 `high` 승인 티어로 본다.

---

## Prompt 00: Monetization Direction Lock
```text
You are product strategy lead for Council Under Siege.

Goal:
Design a monetization model that improves LTV without pay-to-win and without dark patterns.

Output exactly:
1) Core economy loops (soft currency, hard currency, sinks, faucets)
2) 3 monetization pillars:
   - cosmetics
   - convenience
   - seasonal pass
3) What is explicitly forbidden (pay-to-win, hidden odds, coercive timers)
4) Tier mapping:
   - low/medium/high with rationale
5) First 30-day rollout plan (week by week)

Constraints:
- Gameplay fairness must remain skill-first.
- Reward odds must be explainable and auditable.
- Any pricing/odds/economy boundary update is treated as high-risk candidate by default.
```

---

## Prompt 01: Store + Offer Design (Conversion Focus)
```text
Design a simple in-game store for a 90-second survival game.

Deliverables:
1) Store IA (tabs, item classes, pricing display rules)
2) Offer catalog (starter pack, daily cosmetic, season pass)
3) UX constraints:
   - no forced pop-up loop
   - no fake scarcity timer
   - one-tap close always visible
4) Data contract for events:
   - store_open
   - offer_view
   - offer_click
   - purchase_attempt
   - purchase_success
5) KPI targets:
   - payer conversion
   - ARPPU
   - day-7 retention delta

Also include rollback triggers if retention or sentiment drops.
```

---

## Prompt 02: Economy Safety Simulation
```text
Create a deterministic economy simulation spec before shipping monetization.

Output:
1) Inputs:
   - session length distribution
   - reward drop rates
   - purchase frequencies
2) Simulation equations for:
   - currency inflation
   - progression velocity
   - purchase pressure index
3) 3 risk thresholds and stop-ship rules
4) Required evidence fields to persist:
   - simulation_version
   - input_snapshot_ref
   - output_summary_ref
   - verdict_hash
5) Human gate conditions

Constraints:
- Same input snapshot must produce same verdict.
- No wall-clock/random/network dependency in verdict path.
```

---

## Prompt 03: Pixel Asset Batch Generation (local-image-lab)
```text
Generate production-candidate pixel assets for Council Under Siege using local-image-lab.

Environment:
- Lab path: /Users/wonyoung_choi/local-image-lab
- Script: run_sprite_gen.sh
- Sheet tool: make_sprite_sheet.py

Asset set:
1) Player variants x3 (base, elite, seasonal)
2) Enemy sets x3 (chaser, brute, shooter)
3) FX sets x3 (governance pulse, hit flash, pickup glow)
4) UI icons x6 (hp, score, wave, meter, shop, pass)

Output contract:
- Keep seed fixed per set.
- Save outputs to deterministic folder naming:
  /Users/wonyoung_choi/local-image-lab/outputs/cus-v1/<category>/<asset>/<seed>/
- Emit manifest json with:
  - prompt
  - seed
  - model
  - steps
  - output_paths

Command style example:
- /Users/wonyoung_choi/local-image-lab/run_sprite_gen.sh "pixel art ..." "/Users/wonyoung_choi/local-image-lab/outputs/cus-v1/.../frame-01.png" 4 101 sdxl
```

---

## Prompt 04: Governance-First Asset Intake
```text
Design a governance intake flow for AI-generated pixel assets.

Must define:
1) Provenance fields:
   - generator_tool
   - prompt
   - seed
   - model
   - generated_at
   - file_sha256
2) Policy checks:
   - IP/style infringement risk
   - harmful/regulated content check
   - age-rating consistency
3) Approval mapping:
   - cosmetic-only update: medium
   - monetized drop-table/rarity visual signaling change: high
4) Release gate checklist
5) Rollback protocol

Output format:
- one markdown checklist
- one JSON artifact template for provenance evidence
```

---

## Prompt 05: MCP Request Pack for Monetization Governance
```text
Create MCP capability request artifacts for monetization governance.

Need 2 requests:
1) core-analytics-mcp expansion
   - capabilities: track_store_funnel, compute_offer_elasticity
2) core-safety-fallback-mcp expansion
   - capabilities: detect_dark_pattern_risk, emit_monetization_guardrail_notice

For each request include:
- request_id
- approval_tier
- risk_tier
- human_gate_required
- constraints
- evidence_refs

Rules:
- Keep status=requested initially.
- Do not update central registry/manifest/allowlist until approved.
```

---

## Central Governance Opinion (Recommended)
1) 과금/경제/확률/가격 변경은 기본 `high`로 분류하고 human architect 승인 없이는 반영하지 않는 것이 안전하다.
2) AI 생성 에셋은 "결과 이미지"만 아니라 "생성 근거(prompt/seed/model/hash)"를 증빙으로 묶어야 추후 분쟁 대응이 가능하다.
3) `local-image-lab` 연계는 런타임 구현과 분리해 "asset evidence pipeline"으로 취급하고, 승인 전엔 게임 반영 금지 규칙을 권장한다.
4) 과금 UX는 성능보다 신뢰가 우선이다. 다크패턴 감지/차단 capability를 먼저 만들고 상점 확장을 진행하는 순서가 맞다.
5) 초기 30일은 매출 최대화보다 밸런스 안정화(인플레이션/이탈/불만 리스크) 기준 게이트가 우선이다.

---

## Suggested Next Run Order
1) Prompt 00
2) Prompt 03
3) Prompt 04
4) Prompt 02
5) Prompt 01
6) Prompt 05
