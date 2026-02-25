# CUS Monetization Direction v0.1

## Objective
Increase LTV without pay-to-win or coercive monetization, while preserving governance-first safety controls.

## Core Economy Loops
- Soft currency: `council-credits`
  - Sources: run completion, mission milestones, seasonal free track.
  - Sinks: cosmetic unlock crafting, reroll tokens for non-power visual items.
- Hard currency: `verdict-gems`
  - Sources: direct purchase, seasonal premium bundle.
  - Sinks: premium cosmetics, battle pass premium track, convenience-only boosts.
- No power sales:
  - Hard currency must never directly increase survival DPS/HP/speed in ranked loop.

## Monetization Pillars
1. Cosmetics
- Skins, trails, governance pulse visual packs, UI themes.
- Tiered rarity is visual-only and must disclose odds if randomized.

2. Convenience
- Extra loadout slots (visual presets), post-run stat pages, cosmetic quick-equip.
- Must not affect combat stats or wave scaling.

3. Seasonal Pass
- 28-day pass with free + premium tracks.
- Premium adds cosmetics and profile prestige only.

## Forbidden Patterns
- Pay-to-win stat boosts in core survival loop.
- Hidden odds or misleading rarity wording.
- Fake scarcity countdown reset loops.
- Forced modal purchase loops with blocked close action.
- Loss-framed coercive prompts immediately after death.

## Governance Tier Mapping
- `low`
  - Copy-only improvements with no price/odds/exposure rule change.
- `medium`
  - Cosmetic catalog additions with fixed price and no probability mechanics.
- `high` (default for monetization boundaries)
  - Price changes, bundle structure change, probability/rarity mechanics,
  - offer exposure frequency policy,
  - any progression/economy boundary changes.

## 30-Day Rollout
- Week 1:
  - Publish policy-safe store IA and event contract.
  - Enable cosmetic-only static offers.
- Week 2:
  - Run economy simulation + governance gate review.
  - Add seasonal pass draft with no paid power.
- Week 3:
  - A/B test offer placement frequency under dark-pattern guardrails.
  - Monitor retention and sentiment regressions.
- Week 4:
  - Freeze winning configuration.
  - Prepare high-tier approval packet for broader catalog expansion.

## Rollback Triggers
- Day-7 retention drops > 4%p from baseline.
- Support complaints on coercion/fairness exceed threshold.
- Economy simulation risk score flips to high.
