# ai-governance

ai-governance is a deterministic, schema-enforced execution and audit framework.

## Runtime Baseline

The current runtime architecture is:

- Primary runtime: control-plane-go
- Integrity module: audit-core/rust
- Legacy runtime: .legacy/hub (TypeScript, deprecated and not used)

Only control-plane-go and audit-core/rust are part of the supported execution path.

The directory .legacy/hub is retained for historical reference and must not be used in development, testing, or quickstart flows.

## Architecture Overview

- control-plane-go
 - Orchestration
 - Process control
 - I/O handling
 - Schema validation

- audit-core/rust
 - Canonicalization
 - SHA-256 hashing
 - Checksum verification
 - Deterministic integrity enforcement

control-plane-go invokes audit-core/rust for integrity-sensitive operations.

## Quickstart

Prerequisites:

- Go (stable)
- Rust (stable toolchain)

Build and run primary runtime:

- Build Go runtime from control-plane-go
- Build Rust integrity module from audit-core/rust

Do not use .legacy/hub for quickstart or execution.

## Determinism

All audit flows must:

- Pass JSON Schema validation
- Produce deterministic canonical serialization
- Match SHA-256 checksums for plan/result/evidence

Integrity verification is enforced by audit-core/rust.
