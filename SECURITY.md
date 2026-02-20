# Security Policy

## Reporting a Vulnerability
Do not open public issues for security vulnerabilities.

Report privately to the repository owner with:
- vulnerability description
- reproduction steps
- impact summary

## Secret Handling
- Never commit API keys, tokens, passwords, or private keys.
- Never stage `.env`.
- Use `.env.example` for non-secret defaults only.

## Local Guard
This repository uses `.githooks/pre-commit` to detect obvious secret patterns before commit.

## If a Secret Was Exposed
1. Revoke and rotate the secret immediately.
2. Remove the leaked value from working tree and staged changes.
3. Notify the repository owner.
4. Rewrite history only when required.

## Runtime Security Posture (v0)
- Deterministic execution and audit trail are required.
- `hub` executes through controlled wrapper logic and records evidence.
- Policy violations must map to fixed `reason_code` values.
