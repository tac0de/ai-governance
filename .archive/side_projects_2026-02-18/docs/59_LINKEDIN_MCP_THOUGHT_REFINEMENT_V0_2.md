# LinkedIn MCP Design Draft v0.2

## Purpose
Thought Refinement Engine for converting factual work logs into high-integrity publishing drafts.

## Core Principles
- Refinement before posting.
- Clarity before speed.
- No exaggeration.
- No auto-publish.
- Log-first accumulation.

## System Structure

### 1) Input Layer
- Weekly note summaries
- Project change logs
- Failure records
- Personal notes

Rules:
- Accept fact records first, not raw idea dumping.
- Emotional text must be tagged and isolated (`emotion/*`).

### 2) Distillation Layer

Step A: Claim Extraction
- What I claimed
- What I learned
- Where I was wrong

Step B: Compression
- Compress to 30% length
- Remove vague abstractions
- Soften absolute statements

Step C: Structural Rewrite
- Problem -> Experiment -> Result -> Lesson
- Remove emotional phrasing and keep logical structure

### 3) Integrity Filter
- Detect exaggeration
- Neutralize personal/company attacks
- Warn on legal/financial sensitive terms
- Convert certainty language to observation language

Example:
- "This is completely wrong"
- -> "This approach appears to have long-term risk"

### 4) Output Layer
- Primary: LinkedIn draft
- Secondary: 5-line structure summary
- Secondary: 1-sentence core insight
- Internal archive version

Rule:
- Save non-published drafts as internal assets.
- Core asset is thought archive quality, not posting frequency.

## Operating Guardrails (.env Concept)
- `THOUGHT_REFINEMENT_MODE=true`
- `AUTO_PUBLISH=false`
- `EMOTION_TAG_REQUIRED=true`
- `MIN_REVIEW_DELAY_HOURS=24`
- `MAX_POSTS_PER_WEEK=2`

## State Guard (Pre-publish Checklist)
1. Is this sentence verifiable?
2. Is this sentence exaggerated?
3. Will future-me still agree with this?

If any answer is "No", keep as Draft.

## Architecture Philosophy
AI is a distiller, not an amplifier.
The goal is not to make thoughts bigger, but denser and more reliable.
