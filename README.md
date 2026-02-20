# ai-governance

ai-governance is a deterministic, schema-enforced execution and audit framework.

## Runtime Baseline

The current runtime architecture is:

- Primary runtime: hub-go
- Integrity module: rust-audit-core
- Legacy runtime: .legacy/hub (TypeScript, deprecated and not used)

Only hub-go and rust-audit-core are part of the supported execution path.

The directory .legacy/hub is retained for historical reference and must not be used in development, testing, or quickstart flows.

## Architecture Overview

- hub-go
 - Orchestration
 - Process control
 - I/O handling
 - Schema validation

- rust-audit-core
 - Canonicalization
 - SHA-256 hashing
 - Checksum verification
 - Deterministic integrity enforcement

hub-go invokes rust-audit-core for integrity-sensitive operations.

## Quickstart

Prerequisites:

- Go (stable)
- Rust (stable toolchain)

Build and run primary runtime:

- Build Go runtime from hub-go
- Build Rust integrity module from rust-audit-core

Do not use .legacy/hub for quickstart or execution.

## Determinism

All audit flows must:

- Pass JSON Schema validation
- Produce deterministic canonical serialization
- Match SHA-256 checksums for plan/result/evidence

Integrity verification is enforced by rust-audit-core.
