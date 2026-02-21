# Contributing to ai-governance

## Governance-First Policy

This repository is governance-first.

- Primary contribution surface is constitution/policy/schema documentation.
- Runtime adapters are frozen and treated as compatibility-only surfaces.
- Do not expand runtime implementation scope unless explicitly approved.

## Scope of Changes

Allowed by default:
- role model closure
- policy/contract matrix alignment
- schema determinism and evidence contract updates
- human-readable governance documentation

Not allowed by default:
- adding new runtime layers
- major runtime refactor
- adapter migration work (Go/Rust/legacy) without explicit architecture approval

## Development Rules

- Keep changes minimal and deterministic.
- Lock role set before adding anything new.
- Preserve internal-government vs external-enterprise boundary.
- Keep final human sovereignty language explicit.

## Pull Request Requirements

- Changes must align charter, policy, and schema in the same PR.
- PR must include deterministic evidence references (`plan/result/evidence` linkage).
- Human-facing docs should remain short and concrete.

## Deterministic Output

All governance artifacts must:
- conform to defined JSON schemas
- avoid nondeterministic serialization
- produce stable verification checksums
