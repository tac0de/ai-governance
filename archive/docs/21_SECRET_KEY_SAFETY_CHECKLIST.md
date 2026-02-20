# Secret Key Safety Checklist

This document defines the minimum rules for API key safety in this workspace.

## 1) Never expose keys

- Never paste keys in chat, tickets, screenshots, or notes.
- Never commit keys to Git.
- Never print full keys in logs.

## 2) Where keys are allowed

- `.env` files that are excluded by `.gitignore`
- Secret managers (GCP Secret Manager, GitHub Actions Secrets, etc.)
- Local secure storage (for example, OS keychain)

## 3) Required repo hygiene

- `.env`, `secrets/`, `*.pem`, `*.key` must stay in `.gitignore`.
- Use `.env.example` with placeholders only.
- Keep production and development keys separated.

## 4) If leakage is suspected

1. Revoke the exposed key immediately.
2. Issue a new key and replace references.
3. Check usage/billing for abnormal calls.
4. Record incident time and scope in an internal note.

## 5) One-line rule

Treat every exposed key as compromised and rotate immediately.
