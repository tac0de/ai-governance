# Bridge PM Mode Transition (2026-02-22)

## Decision
- PM integration mode is switched from OpenAI API generation to local Codex PM generation.

## Rationale
- Reduce external token dependence for operational PM loops.
- Keep governance and bridge queue flow unchanged.
- Maintain single-channel work context in Codex for work-related planning/execution.

## Effect
- `scripts/bridge_pm_openai.sh` is retired.
- `scripts/bridge_local_pm.sh` is the active PM intent generator.
