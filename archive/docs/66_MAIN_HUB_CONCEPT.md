# Main-Hub Concept (Core Principle)

## One-line definition
`ai-governance` is a governance and routing layer that controls AI execution without performing domain logic.

## Core principle
- `ai-governance` is not an execution engine.
- `ai-governance` must not include domain logic.
- `ai-governance` must not write domain prompts directly.

## Architectural positioning
Company analogy:
- `ai-governance`: HQ (Command and Governance)
- `engine`: Operations layer
- `module`: Domain team
- `model`: External workforce

Rule:
- `ai-governance` decides who executes.
- `ai-governance` does not decide domain answer content.

## Responsibilities (strict)
- command validation
- policy enforcement
- model tier selection
- engine routing
- audit logging
- optional rate limiting
- future-ready permission checks

## Non-responsibilities (strict)
- no domain prompt authoring
- no analysis logic
- no RAG logic
- no memory-processing logic
- no business-domain logic

## Command contract example
```json
{
  "command": "ANALYZE_ENTITY",
  "analysis_type": "public_figure_profile",
  "policy": "neutral_public_info_only",
  "engine": "analysis_engine_v1",
  "module": "public_figure_profile",
  "model_tier": "standard",
  "audit": true
}
```

Main-hub validates this contract shape and routes it to the target engine.

## Execution flow
1. User
2. Main-hub (validation + routing)
3. Engine
4. Module
5. Model
6. Engine (JSON normalization)
7. Main-hub (audit log)
8. Response

## Design principles
- stateless core
- deterministic routing
- policy-first execution
- JSON-only contracts
- expandable command taxonomy

## Future expansion compatibility
- multi-engine orchestration
- permission layers
- tier-based model switching
- enterprise audit mode
- external service adapters
