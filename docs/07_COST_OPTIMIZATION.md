# 07. Cost Optimization Guide

## Objective
Reduce AI operating cost while preserving response quality for production.

## Baseline policy
- Enforce token caps per request.
- Route simple requests to cheaper models.
- Reserve expensive reasoning for complex tasks.
- Require request IDs for usage tracing.

## Control points
1. `max_tokens_per_call`
2. `max_iterations`
3. daily budget cap
4. timeout guard
5. kill switch

## Practical steps
- Cache repeated static context.
- Keep prompts compact and deterministic.
- Log token estimates when provider usage is unavailable.
- Disable non-critical logging under load.

## KPI set
- Cost per successful request
- Error-adjusted cost
- P95 latency by tier
- Budget burn rate by day

## Rollback trigger
If quality drops or incident rate rises after optimization, revert the latest cost policy change first.
