# Contracts

Canonical interface and data contracts shared across Codex repos.

## Versioning
- SemVer applies to each file: `MAJOR.MINOR.PATCH` in the `version` field or exported metadata.
- Only backward‑compatible changes are allowed here (additive, optional fields, clearer docs).
- Breaking changes are disallowed; publish a new versioned contract file instead of mutating an existing one.
- Every change must land via PR with review from an engine maintainer.

## Files
- `event.schema.json` – envelope for all emitted events.
- `trace.schema.json` – normalized trace/log record format.
- `provider.interface.ts` – LLM/provider surface expected by the engine.
- `provider.adapter.interface.v1.ts` – normalized adapter contract for model-specific differences.
- `command.contract.example.json` – example command envelope validated/routed by `ai-governance`.

## DTP note
- DTP is a protocol contract, not a programming language.
- Language/model/provider choices are implementation details as long as contracts are preserved.
