# Contributing to ai-governance

## Runtime Policy

The supported runtime baseline is:

- control-plane-go (primary runtime)
- audit-core/rust (integrity module)

The TypeScript runtime located at .legacy/hub is deprecated and must not be used for new development, testing, or documentation examples.

All contributions must target the current runtime baseline.

## Development Rules

- Do not introduce new runtime layers.
- Do not modify integrity boundaries without explicit design approval.
- Keep schema enforcement deterministic.
- Avoid expanding scope beyond the stated task.

## Integrity Boundary

All hash generation and checksum verification logic must reside in audit-core/rust.

control-plane-go is responsible for orchestration and invoking the integrity module.

## Pull Request Requirements

- Changes must not reference .legacy/hub in examples or quickstart instructions.
- Documentation must reflect control-plane-go as the primary runtime.
- Integrity-sensitive changes require justification and deterministic test evidence.

## Deterministic Output

All audit-related outputs must:

- Conform to the defined JSON schema
- Avoid nondeterministic serialization
- Produce stable SHA-256 checksums

Non-deterministic behavior is considered a violation.
