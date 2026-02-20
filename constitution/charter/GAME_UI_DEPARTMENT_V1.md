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

## Inputs
- Level and progression specs from Game Level Design Department.
- Product narrative direction from Domain Unit.
- Policy constraints for safe messaging and non-manipulative UX.

## Outputs
- Versioned UI specs and component behavior rules.
- Mood-reactive UI token map (color, motion, copy tone).
- Release notes describing player-facing UI impact.

## Department Rules
- Must not hide governance-critical warnings or player-impact states.
- Must keep UI transitions deterministic for identical state inputs.
- Must keep accessibility baseline as a release requirement.

## Coordination Boundary
- Works with Game Level Design Department on pacing and reward readability.
- Works with product implementation teams on component delivery.
- Works with governance roles only through documented policy and contract references.
