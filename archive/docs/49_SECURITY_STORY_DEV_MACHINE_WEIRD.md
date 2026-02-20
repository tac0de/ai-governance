# Security Story: When a Dev Machine Feels "Weird"

This note is written as reusable security material (internal training, B2B hygiene package, or a public post).

## Hook (1 paragraph)

When a developer says "my computer is acting weird", treat it as a security event until proven otherwise. The goal is not to panic. The goal is to ensure that *remote controls still hold* even if the endpoint is compromised: protected branches, required CI checks, secret scanning, and explicit approval boundaries.

## What Happened (Realistic Sequence)

1. A direct push to `main` was rejected by GitHub with a protected-branch error (changes must go through a Pull Request).
2. A PR was opened and CI checks ran normally.
3. The PR could not be merged because the repository required an approving review.
4. GitHub does not allow a PR author to approve their own PR.
5. In a solo-maintainer repo (only one collaborator with write access), "required approvals = 1" creates a merge deadlock.

## Why This Matters (Security Lens)

- If the endpoint is compromised, branch protection stops direct-to-`main` changes.
- Review requirements prevent single-actor changes, but they must match your team reality.
- A control that permanently blocks shipping becomes a workaround generator (and workarounds are where incidents happen).

## Minimal Fix (Choose One)

### Option A: Solo repo (pragmatic)

- Keep PR requirement.
- Set required approving reviews to `0` so the maintainer can merge without a second human.
- Keep CI checks + secret scanning as the primary guardrails.

### Option B: Team repo (strong)

- Keep PR requirement.
- Require `>= 1` approving review.
- Ensure *at least two* collaborators have write access (so the policy is actually satisfiable).

## "Cancelled" CI Signals (DevOps Hygiene Example)

GitHub Pages builds can show `Cancelled` when a higher-priority build request is queued (concurrency / superseded run). Treat this as an *ambiguous* signal:

- Do not gate merges on a check that often ends as `cancelled`.
- Use "latest successful deploy" (environment URL / last successful run) as the source of truth.
- Document the expected cancellation behavior so contributors do not misread it as failure.

## 30-Minute Response Card (If a Dev Machine Feels Compromised)

### 0-5 minutes: Contain

- Stop doing sensitive actions (deploys, key generation, token creation).
- Record: time, symptoms, what you were doing, and any unusual prompts/popups.

### 5-15 minutes: Account protection (highest ROI)

- GitHub:
  - Review recent sessions and SSH keys.
  - Revoke suspicious tokens.
  - Rotate any secrets that may have been exposed.
- Cloud providers / LLM providers:
  - Rotate API keys if you suspect exposure.
  - Check usage anomalies (unexpected spend, spikes).

### 15-30 minutes: Endpoint triage (lightweight)

- Check for persistence:
  - Login items / LaunchAgents / cron.
- Check for suspicious network activity:
  - Unexpected listeners or outbound connections.
- If uncertainty remains:
  - Treat the machine as untrusted for secrets until rebuilt.

## Principle (One line)

Design platform workflows so that "my computer is weird" slows you down, but does not break the system or force unsafe shortcuts.

