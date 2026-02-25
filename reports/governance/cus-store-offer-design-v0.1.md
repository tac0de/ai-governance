# CUS Store and Offer Design v0.1

## Store IA
- Tabs:
  - Featured
  - Skins
  - FX Packs
  - Season Pass
  - Account

## Offer Catalog
- Starter Pack (one-time):
  - 600 verdict-gems + 1 exclusive skin
  - price tier: starter-low
- Daily Cosmetic:
  - 1 rotating visual item, fixed daily reset
  - price tier: daily-low|daily-mid
- Season Pass (28-day):
  - free track + premium track cosmetics
  - price tier: pass-standard

## UX Constraints
- Close button always visible.
- No full-screen forced purchase on death.
- Max one proactive offer modal per session.
- No fake scarcity countdown.

## KPI Targets
- payer conversion >= 2.5%
- ARPPU >= baseline + 8%
- day-7 retention delta >= -1%p (no material regression)

## Rollback Conditions
- Forced-modal complaint spike over governance threshold.
- day-7 retention regression < -3%p.
- purchase success rate degrades > 20% from baseline.
