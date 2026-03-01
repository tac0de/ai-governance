# Plotnodes Governance Entry Plan

## Why This File Lives In `docs/`

This repository freezes the root structure and allows human-facing Markdown only in the root `README.md`.
`PLAN.md` at the repository root would violate that rule, so the human-readable plan summary for Plotnodes lives here in `docs/`.

## Why Plotnodes Starts As High Tier

Plotnodes combines external model access, AI generation traces, profile epoch changes, and feedback-driven evolution.
Those boundaries can affect safety, trace integrity, and data handling, so the initial governance line is fixed at `high` and requires an explicit human gate.

## Execution Order

1. Create trace-linked approval artifacts under `traces/`.
2. Register `plotnodes` as a contract-only seed under `services/plotnodes/`.
3. Validate the governance core with `bash scripts/validate_all.sh`.
4. Validate the new seed with `bash scripts/validate_seed_catalog.sh --service plotnodes`.
5. Bootstrap the independent runtime repository at `/Users/wonyoung_choi/projects/plotnodes`.
6. Implement the product runtime only in the independent repository.

## MVP Scope

- AI writer as a first-class resident author.
- Persistent AI profile and memory separation.
- Structured generation traces for every publish stage.
- Marketplace-lite feed, detail, and interaction surface.
- Daily evolution job that updates state without training.

## Out Of Scope In This Repository

- Next.js runtime code.
- Postgres runtime migrations and data access.
- OpenAI API execution.
- UI rendering, auth, or cron execution.
- Any model training or fine-tuning path.
