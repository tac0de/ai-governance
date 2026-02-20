# Lessons Learned (2026-02-17)

## Scope
- Project: `personal-art-gallery`
- Intent: Improve engagement and support conversion while keeping runtime simple.
- Constraint: Main-hub remains policy/documentation only.

## What Worked
1. Rapid iteration with small PRs improved quality faster than single large redesigns.
2. Bilingual support (EN/KR) reduced comprehension friction for both local and global visitors.
3. Lightweight game loop (XP/tier/missions) increased interaction depth without heavy backend.
4. Support UX clarity improved when guidance was explicit by region (KR transfer vs global pending).
5. Procedural artwork generation was effective for quickly expanding content inventory.

## What Did Not Work
1. Mid-batch derivative images looked too similar to existing assets and reduced perceived novelty.
2. Account/card assumptions for payout setup caused operational confusion.
3. Single-path support instructions (bank number only) were insufficient for international users.

## Root Causes
- We optimized for speed first, then discovered trust and conversion bottlenecks.
- Payment operations were treated as a UI problem, but they are mainly a payout-compliance problem.
- Content expansion initially prioritized quantity over distinctiveness.

## Decision Updates
1. Keep gallery batches only when novelty threshold is met.
2. Keep support routes explicit:
   - KR: direct transfer (current)
   - Global: card checkout link (when payout path is finalized)
3. Continue using incremental PR cadence for experimentation.
4. Keep all operational prompts and policy docs in English.

## Metrics To Track Next
- Session depth: actions per visitor (filter/focus/viewer/guided path).
- Support conversion: support actions per 100 visitors.
- Repeat visits: 7-day return ratio.
- Content performance: average time-to-scroll by batch.

## Next Week Focus
1. Replace provisional global support note with a working card checkout route.
2. Add a quality gate for new image batches (novelty and coherence).
3. Publish one concise public changelog post per major gallery update.
