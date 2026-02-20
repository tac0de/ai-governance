# 14. LaaS Efficiency Playbook

## Objective
Operate LaaS with predictable cost and latency.

## Control policy
- preset per tier
- timeout per tier
- retry policy with upper bound
- fallback preset per tier

## Efficiency tactics
- reduce system prompt duplication
- isolate optional context blocks
- track latency by preset hash
- keep one-change-at-a-time rollout

## Exit condition
If OpenAI direct path outperforms cost/quality objectives consistently, keep LaaS optional only.
