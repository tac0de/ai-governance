# 08. Agent-Human Documentation Guide

## Objective
Keep documentation readable for humans while preserving machine-usable structure.

## Rule set
- Operational docs in `docs/`: Korean-first.
- Contracts/schemas/prompt templates: English source-of-truth.
- If a Korean doc references a contract/prompt, keep the exact English identifier unchanged.
- User-facing assistant replies: configurable per service
- Keep sections short and operational

## Minimal structure per doc
1. What this document controls
2. Why it matters
3. One immediate action
4. Validation checklist

## Sync policy
When architecture changes:
- Update narrative doc (Markdown)
- Update structured state (JSON)
- Update command/runbook references

## Anti-patterns
- Philosophy-only writing
- Unbounded TODO lists
- Missing rollback instructions

## Logging boundary
- `LOGS/` is operation history and audit evidence.
- Keep command outputs, timestamps, and trace identifiers unchanged for reproducibility.
