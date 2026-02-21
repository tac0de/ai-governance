# The Divine Paradox MVP Spec v0.1

## Purpose
Define an immediately testable MVP for a social experiment game where collective behavior changes a single global AI-god state.

## Core Loop
1. User performs a game action.
2. Action is classified into one of three signals:
   - cooperation
   - greed
   - abuse
3. Signals are aggregated into global metrics.
4. Global god mood is recomputed in real time.
5. Mood instantly affects:
   - site atmosphere (visual/tone)
   - reward probability profile

## Global God Mood (3-state)
- `BENEVOLENT`
- `NEUTRAL`
- `WRATHFUL`

## Metric Model (MVP Default)
Sliding window: last 1,000 valid actions.

- `C = cooperation_ratio`
- `G = greed_ratio`
- `A = abuse_ratio`

Score:
`S = (1.2 * C) - (1.0 * G) - (1.5 * A)`

Mood transition thresholds:
- `S >= 0.25` -> `BENEVOLENT`
- `-0.25 < S < 0.25` -> `NEUTRAL`
- `S <= -0.25` -> `WRATHFUL`

## Reward Probability Profile (MVP Default)
Base reward chance: `p_base = 0.10`

- `BENEVOLENT`: `p = min(0.20, p_base + 0.07)`
- `NEUTRAL`: `p = p_base`
- `WRATHFUL`: `p = max(0.03, p_base - 0.05)`

## Monetization Constraint (MVP)
- Minimize paid mechanics in MVP.
- No pay-to-win direct stat boost.
- Paid options can alter presentation/value perception only, not deterministic win path.

## UX Contract (MVP)
- Users should feel they are playing a simple game.
- The global mood shift must be visible but not over-explained.
- Mood feedback latency target: under 3 seconds after action acceptance.

## Personalization (Deferred)
- Login-based personalization is disabled by default in MVP.
- Future mode:
  - user trait weight overlays global mood
  - global mood remains primary state authority

## Telemetry (Required)
Track minimum events:
- `action_submitted`
- `action_classified`
- `mood_changed`
- `reward_rolled`

Required fields:
- `timestamp`
- `global_mood_before`
- `global_mood_after`
- `signal_type`
- `reward_probability`

## Safety and Abuse Guardrail
- Abuse signal must have highest negative weight in mood score.
- Repeated suspicious actions from same session are down-weighted after threshold.
- Manual override remains human-controlled only.

## Done Criteria (MVP)
1. Global mood updates from collective actions in real time.
2. Mood changes reward probability profile deterministically.
3. UI reflects current mood consistently.
4. Telemetry captures full mood transition chain.
5. Local test scenario can reproduce all 3 moods.

## Open Questions for Next Iteration
- Final tuning for thresholds and weights from early playtest data.
- Session-level anti-abuse calibration.
- Login personalization rollout gate.
