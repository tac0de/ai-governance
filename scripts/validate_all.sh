#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1" >&2; exit 1; }
}

require jq

jq -e '
  (.intent_id | type=="string" and length>0) and
  (.policy_profile=="strict" or .policy_profile=="balanced" or .policy_profile=="creative") and
  (.state_ref | test("^[a-f0-9]{64}$")) and
  (.plan_ref==null or (.plan_ref | test("^[a-f0-9]{64}$"))) and
  (.budget.max_tokens | type=="number" and .>0) and
  (.budget.max_steps | type=="number" and .>0) and
  (.acceptance_tests_ref==null or (.acceptance_tests_ref | test("^[a-f0-9]{64}$")))
' "$ROOT_DIR/fixtures/intent.envelope.json" >/dev/null

jq -e '
  (.must_include_sources | type=="boolean") and
  (.max_hallucination_score | type=="number" and .>=0 and .<=1) and
  (.required_sections | type=="array" and length>0)
' "$ROOT_DIR/fixtures/acceptance.tests.json" >/dev/null

jq -e '
  (.source=="jira" or .source=="github" or .source=="web" or .source=="db") and
  (.content_ref|test("^[a-f0-9]{64}$")) and
  (.confidence|type=="number" and .>=0 and .<=1) and
  (.access_level=="internal" or .access_level=="public") and
  (.sections|type=="array") and
  (.hallucination_score|type=="number" and .>=0 and .<=1)
' "$ROOT_DIR/fixtures/evidence.summary.json" >/dev/null

jq -e '
  .version=="v0.1" and
  (.tiers.low.approval_mode=="auto") and
  (.tiers.medium.approval_mode=="policy_plus_owner") and
  (.tiers.high.approval_mode=="mandatory_human_gate")
' "$ROOT_DIR/policies/approval_tier_policy.v0.1.json" >/dev/null

echo "VALIDATION_PASS"
