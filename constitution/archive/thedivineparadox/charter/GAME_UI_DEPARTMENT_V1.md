# Game UI Department v1

## Purpose
Define and ship the player-facing interface system for `thedivineparadox` so global god-state changes are immediately visible, readable, and emotionally legible.

## Scope
- Own visual state language for three god moods:
  - benevolent
  - neutral
  - wrathful
- Own interaction design for core MVP loops.
- Own UI consistency rules across web and mobile breakpoints.
- Own first-screen engagement contract for `0-60s` onboarding loops.

## Inputs
- Level and progression specs from Game Level Design Department.
- Product narrative direction from Domain Unit.
- Policy constraints for safe messaging and non-manipulative UX.
- Reference packs from Webgame Reference Intelligence Department.

## Outputs
- Versioned UI specs and component behavior rules.
- Mood-reactive UI token map (color, motion, copy tone).
- Release notes describing player-facing UI impact.
- Reference evidence artifact per release tag (`benchmark set + rationale + deltas`).

## Department Rules
- Must not hide governance-critical warnings or player-impact states.
- Must keep UI transitions deterministic for identical state inputs.
- Must keep accessibility baseline as a release requirement.
- Must produce at least one desktop and one mobile reference-backed layout before implementation.
- Must not ship new visual direction without a stored reference artifact ID.

## Coordination Boundary
- Works with Game Level Design Department on pacing and reward readability.
- Works with Game Engine Department on runtime rendering constraints.
- Works with Webgame Reference Intelligence Department for benchmark acquisition.
- Works with product implementation teams on component delivery.
- Works with governance roles only through documented policy and contract references.
