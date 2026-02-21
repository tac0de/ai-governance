# The Divine Paradox Complex Logic Plan v1

## Governance Timestamp
- KST: 2026-02-20T15:43:12+09:00
- UTC: 2026-02-20T06:43:12Z

## Purpose
Define hard conditions and an execution roadmap for evolving `thedivineparadox` from a lightweight decision demo into a complex logic-driven web game.

## Definition: Complex Logic Game (for this project)
A release qualifies as "complex logic" only if it satisfies all of the following:

1. State-Coupled Systems
- At least 5 core state variables are mutually coupled.
- A single action changes at least 3 variables with non-linear side effects.

2. Deferred Consequences
- Action effects must include delayed outcomes across 2+ future turns.
- At least one delayed effect must invert short-term benefit into long-term cost.

3. Strategic Branching
- At least 3 viable play styles must exist (stability-first, control-first, volatility-first).
- No single strategy should dominate across >70% of sampled seeds.

4. Deterministic + Replayable Runtime
- Identical seed + action sequence must produce identical outcomes.
- Full run replay must be reconstructable from event logs.

5. Progressive Cognitive Load
- First 60 seconds: 1 primary interaction path only.
- By turn 3+: additional systems unlock (risk intel, combo penalties, delayed events).

## Required Engine Conditions
- Fixed-timestep update contract for simulation-critical logic.
- Separation between render state and game simulation state.
- Event bus with typed events:
  - `turn.started`
  - `action.committed`
  - `effect.immediate.applied`
  - `effect.deferred.scheduled`
  - `effect.deferred.resolved`
  - `run.ended`

## Required MCP/Reference Conditions
- `webgame-ref-mcp` must produce ranked references with score breakdown.
- Every UI/loop proposal must attach:
  - top 3 benchmark references
  - score rationale
  - expected KPI impact hypothesis
- Image references must include provenance metadata:
  - source URL
  - capture timestamp
  - relevance reason

## KPI Gate Conditions
Promotion to the next release track requires all of:

1. First Session Engagement
- `FTUE completion (0-60s) >= 65%`
- `second decision rate >= 55%`

2. Logic Depth Adoption
- `turn 3 reach rate >= 40%`
- `branch diversity index >= 0.55`

3. Retention and Voluntary Spend Signal
- `D1 return >= target baseline`
- `voluntary spend trigger rate` improves without pay-to-win signal

## Execution Roadmap

### Phase A: Simulation Foundation
- Formalize state transition table and delayed effect scheduler.
- Add deterministic seed mode and replay export.
- Add simulation unit tests for all core actions and penalties.

### Phase B: Interaction Depth
- Introduce action synergy/anti-synergy system.
- Add adaptive pressure events based on player history.
- Add tutorial-to-depth unlock path (first minute -> turn 3 loop).

### Phase C: Economy and Live Ops
- Add non-pay-to-win paid experiments:
  - scenario packs
  - visual themes
  - replay/analysis slots
- Validate spend triggers via A/B tests tied to retention safety metrics.

### Phase D: Governance-Coupled Scaling
- Enforce reference evidence as release gate artifact.
- Bind design decisions to benchmark score deltas and KPI outcomes.
- Require post-release audit summary per milestone.

## Ownership Map
- Game Level Design Department: state coupling, branch viability, delayed effects.
- Game UI Department: progressive cognitive load and readability.
- Game Engine Department: deterministic runtime and replay guarantees.
- Webgame Reference Intelligence Department: benchmark evidence and provenance.
