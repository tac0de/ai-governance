# The Divine Paradox Divine Visual Baseline v1

## Governance Timestamp
- KST: 2026-02-20T15:43:12+09:00
- UTC: 2026-02-20T06:43:12Z

## Purpose
Define a fixed visual baseline for the "divine entity" so asset generation, sprite framing, and vision review are consistent.

## Canonical Divine Form (v1)
- Archetype: transcendent adjudicator symbol (non-human deity icon).
- Core silhouette: floating mask-core with no explicit limbs.
- Structure: core body + dual halo + rune orbit.
- Readability target: recognizable at 32x32 without text labels.

## Mood Variants

### 1) Benevolent
- Shape language: rounded, soft, stable symmetry.
- Palette direction: muted teal + pale gold.
- Motion profile: low-frequency, smooth, calm pulse.
- Emotional signal: guidance, restraint, protection.

### 2) Neutral
- Shape language: balanced, static, high symmetry.
- Palette direction: ivory + gray-blue.
- Motion profile: medium-frequency idle drift.
- Emotional signal: observation, judgment pending.

### 3) Wrathful
- Shape language: angular accents, fractured edge highlights.
- Palette direction: ember red + dark rust.
- Motion profile: higher-frequency jitter + impact spikes.
- Emotional signal: condemnation, pressure, imminent backlash.

## Sprite Framing Contract (Baseline)
- Frame layout: 3 frames horizontal sprite sheet (`idle A`, `idle B`, `impact`).
- Base resolution: 32x32 per frame.
- Required exports:
  - `divine-benevolent-sheet.png`
  - `divine-neutral-sheet.png`
  - `divine-wrathful-sheet.png`
- Fallback alias:
  - `divine-sprite-sheet.png` points to neutral baseline when needed.

## Layer Contract
- Base layer: pixel sprite sheet (identity carrier).
- FX layer: SVG aura/shock overlay (mood amplification only).
- Rule: FX must not replace silhouette readability of base sprite.

## Hard Quality Gates
A candidate is rejected if any of the following fails:
- Silhouette is not distinguishable at 32x32.
- Mood variants are only color-swapped without shape/motion difference.
- Impact frame does not visually differ from idle frames.
- Wrathful variant lacks urgency cues in motion or edge treatment.

## Vision Review Rubric (MCP-aligned)
- silhouette_score >= 70
- readability_score >= 70
- motion_score >= 65
- mood_coherence_score >= 70
- overall_score >= 70

## Prohibited Elements
- Direct imitation of specific religious figures or copyrighted character likenesses.
- Over-detailed facial anatomy that collapses at 32x32.
- Random noise animation that breaks mood coherence.

## Execution Note
This baseline is normative for v1 asset production and vision scoring.
Any change requires an explicit version bump.
