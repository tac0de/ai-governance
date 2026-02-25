# TheDivineParadox Focus Plan v0.1

Scope: UI/UX + MCP request flow (service -> central governance) + divine sprite animation (8+ frames).

## 0) Operating Constraints

- Central governance owns MCP contract/ID/capabilities (`core-*` namespace).
- Service runtime owns MCP adapter/invocation only.
- High-risk changes require human gate.
- Deterministic trace + evidence refs are mandatory.

## 1) UI/UX Only Plan

Objective:
- Increase first-session completion and result-view conversion with a simpler, short-attention flow.

Primary UX loop:
1. Open page -> see single dominant question in <3s.
2. Tap one clear CTA -> submit vote.
3. Immediate micro-reward and outcome hint -> move to result.
4. Result page gives one next action -> encourages repeat.

Deliverables:
- `apps/web/app/page.tsx`
  - keep one primary CTA only
  - remove secondary cognitive noise above-the-fold
  - show immediate post-submit state change
- `apps/web/app/result/page.tsx`
  - add one clear next action card (return tomorrow / see state trend)
- `apps/web/app/globals.css`
  - enforce stronger visual hierarchy (single hero, single action line)
  - tune motion for meaning (submit success, state transition)
- instrumentation extension (high-signal)
  - add `cta_focus_seen`
  - add `result_next_action_click`

Acceptance:
- `npm --prefix apps/web run lint`
- mobile + desktop manual sanity:
  - first viewport shows one question + one CTA
  - submit feedback appears instantly
  - next action is visible without scrolling (mobile included)

Stop condition:
- UI has exactly one dominant action per step and no ambiguous branch in first interaction.

## 2) MCP Addition Request Flow (Service -> Central)

Objective:
- Make MCP capability expansion explicit, auditable, and centrally owned.

Flow:
1. Service proposes MCP addition request artifact.
2. Central governance validates risk/capability overlap and decides tier.
3. If approved, central updates:
  - `control/registry/mcps.v0.1.json`
  - `mcps/core-*/manifest.json`
  - `services/<service>/mcp.allowlist.json`
4. Service syncs runtime allowlist and adapter mapping.
5. Dual validation:
  - `ai-governance/scripts/validate_all.sh`
  - `thedivineparadox/scripts/validate_governance.sh`

Request artifact template (service side):
- path: `tmp/tdp.mcp.request.<slug>.json`
- required fields:
  - `request_id`
  - `service_id`
  - `target_core_mcp_id`
  - `capability_name`
  - `risk_tier`
  - `justification`
  - `input_schema_summary`
  - `expected_trace_fields`
  - `human_gate_required`

Policy:
- Service cannot mint new MCP IDs.
- New ID/capability is central governance change by default.

Stop condition:
- Any MCP change without central registry + manifest update is blocked.

## 3) Divine Sprite 8+ Frame Plan

Objective:
- Replace 3-frame rough loop with smoother 8-12 frame sprite animation and mood variants.

Target spec:
- Base loop: 8 frames minimum (recommended 12).
- Mood packs:
  - `calm`
  - `warning`
  - `chaotic`
- Frame continuity target:
  - adjacent-frame structural similarity >= 0.88 (SSIM-style check)

Generation strategy (local-image-lab):
1. Generate canonical frame-1 (`txt2image`).
2. Chain `image2image` low-strength for frame-2..N.
3. Keep stable character anchors in prompt.
4. Apply subtle phase changes only:
  - halo pulse
  - idle float
  - cloth/glow flicker
5. Build sprite sheet + metadata json.

Files:
- `scripts/generate_divine_sprite_local.sh`
  - extend to `FRAME_COUNT=8|12`
  - mood argument: `MOOD=calm|warning|chaotic`
- `apps/web/public/assets/divine/<mood>/...`
  - frame png set + sheet
- `apps/web/app/lib/divineSprite.ts` (new)
  - mood -> asset mapping
  - frame timing profile
- `apps/web/app/page.tsx`
  - state-based mood switch (from daily/god state)

Verification:
- generation command example:
  - `FRAME_COUNT=12 MOOD=calm bash scripts/generate_divine_sprite_local.sh`
- visual check:
  - no hard jumps between adjacent frames
  - animation stable at 60fps and 30fps modes
- web check:
  - first paint unaffected by heavy asset load (lazy load mood packs)

Stop condition:
- minimum 8-frame loop per mood and visually smooth transition confirmed.

## 4) Execution Order (No time estimate)

1. UX simplification patch (single-action flow + events).
2. Sprite pipeline extension to 8+ frames + mood packs.
3. MCP request artifact path + policy enforcement wiring.
4. End-to-end validation and staging check.

## 5) Required Commands

- Central governance:
  - `bash /Users/wonyoung_choi/ai-governance/scripts/validate_all.sh`
- Service backend:
  - `npm --prefix /Users/wonyoung_choi/projects/thedivineparadox/apps/backend run lint`
  - `npm --prefix /Users/wonyoung_choi/projects/thedivineparadox/apps/backend run test:unit`
  - `npm --prefix /Users/wonyoung_choi/projects/thedivineparadox/apps/backend run test:integration`
- Service web:
  - `npm --prefix /Users/wonyoung_choi/projects/thedivineparadox/apps/web run lint`
