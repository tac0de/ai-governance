# Game Engine Department v1

## Purpose
Define and operate the runtime engine baseline for `thedivineparadox` so gameplay presentation behaves like a game system, not a static webpage.

## Scope
- Own rendering runtime contracts for web and mobile web.
- Own deterministic animation state flow for gameplay-critical visuals.
- Own performance budgets for low-power client devices.

## Inputs
- UI behavior contracts from Game UI Department.
- Gameplay loop contracts from Game Level Design Department.
- Policy constraints for safe and transparent player-facing behavior.

## Outputs
- Versioned engine runtime specs.
- Deterministic state transition map for gameplay-critical animations.
- Device profile matrix (`desktop`, `high-end mobile`, `baseline mobile`).

## Department Rules
- Must keep game-critical animation state deterministic for identical inputs.
- Must provide fallback behavior when engine features are unavailable.
- Must not introduce hidden state mutation outside documented runtime contracts.

## Coordination Boundary
- Works with Game UI Department on render/UI contract boundaries.
- Works with Game Level Design Department on runtime feasibility and pacing cost.
- Works with product implementation teams on engine delivery.
- Works with governance roles only through documented policy and contract references.
