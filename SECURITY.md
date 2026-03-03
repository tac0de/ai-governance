# Security Policy

## Scope

This repository contains governance contracts, schemas, documentation, and validation scripts.

It does not host production runtime code for independent services.

## Reporting

If you believe you found a security issue in this repository:

- do not publish exploit details in a public issue
- open a private security report through GitHub, if available
- if private reporting is not available, open a minimal issue asking for a security review without disclosing sensitive details

## What Counts Here

Relevant issues include:

- unsafe validation behavior
- accidental disclosure of sensitive local paths or secrets
- workflow misconfiguration that could expose repository integrity
- contract drift that weakens deterministic release checks

## Out Of Scope

Out of scope for this repository:

- bugs in independent service runtimes
- product vulnerabilities in linked services
- deployment issues outside this repository

Those should be reported to the owning service repository.
