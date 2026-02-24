# Core Safety Fallback MCP

Purpose: normalize LLM failure handling and fallback policy selection.

Scope:
- Classify LLM failure categories.
- Select policy-bound fallback response mode.
- Emit deterministic degrade notice payloads.

Out of scope:
- Upstream model secret management.
- Free-form narrative generation without policy constraints.
