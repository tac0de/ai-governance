# 2026-02-19 — TDP positioning and UX shift

## Positioning update
- Reframed product narrative to:
  - "AI God grants power, humanity pays the cost."
- Maintained same deterministic loop and cost constraints.

## UI/UX changes
- Updated hero copy and product language to divine-gift/cost framing.
- Reworked control panel labels and action wording for thematic consistency.
- Replaced raw JSON-first display with readable world ledger and decree output.
- Preserved mobile responsiveness while improving visual hierarchy.

## Deployment state
- Frontend redeployed to Cloud Run (`thedivineparadox-web`).
- Root domain and API domain both route correctly.

## Additional infra
- Added `kernel.thedivineparadox.com` DNS CNAME.
- Kernel domain mapping exists; certificate provisioning pending.
