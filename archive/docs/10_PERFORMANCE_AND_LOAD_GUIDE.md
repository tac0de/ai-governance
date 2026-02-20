# 10. Performance and Load Guide

## Objective
Maintain stable latency under concurrent chatbot traffic.

## Baseline controls
- tune function concurrency conservatively
- cap max instances for budget control
- set clear request timeout boundaries

## Optimization order
1. Reduce prompt size
2. Improve cache hit rate
3. Lower upstream round trips
4. Tune infra concurrency

## Monitoring set
- P50/P95 latency
- timeout rate
- error rate by provider
- cold start impact

## Incident fallback
- downgrade expensive tiers temporarily
- reduce max tokens
- switch to stable fallback preset/model
