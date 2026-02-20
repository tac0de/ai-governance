# Payment Semi-Automation Runbook

## Objective
Enable revenue quickly with minimum human bottleneck:
- Human handles legal/settlement identity steps.
- AI handles repeatable operational setup and daily control loops.

## Phase 1 (Human-only, one-time)
- Register settlement method (real card/bank).
- Complete KYC/business verification.
- Complete tax profile and payout account setup.
- Confirm account is live-ready (not test-only).

## Phase 2 (AI semi-automation)
- Product/price catalog creation and updates.
- Checkout/session config generation.
- Webhook endpoint registration and signature validation setup.
- Access grant/revoke flows after payment status change.
- Retry queue for failed callbacks/events.
- Daily reconciliation summary and alert generation.

## Required Guardrails
- `AUTO_CHARGE=false` by default.
- `AUTO_REFUND=false` by default.
- Real billing action requires explicit human gate.
- Per-service/monthly budget caps must be enforced.
- All payment config changes must be audit-logged.

## Minimal Environment Policy
- Keep only non-secret operational toggles in local env.
- Use secret manager/CI secret for payment credentials.
- Scope keys per environment (dev/stage/prod).

## Day-1 KPI
- First successful real payment.
- Payment-to-access grant latency.
- Failed payment event recovery rate.

## Escalation
- Escalate immediately on charge mismatch, payout delay, legal/tax warning, or duplicate charge signals.
