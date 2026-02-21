#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
run1="$ROOT_DIR/traces/run1"
run2="$ROOT_DIR/traces/run2"

rm -rf "$run1" "$run2"
mkdir -p "$run1" "$run2"

bash "$ROOT_DIR/scripts/run_intent.sh" "$ROOT_DIR/fixtures/intent.envelope.json" "$run1" >/dev/null
bash "$ROOT_DIR/scripts/run_intent.sh" "$ROOT_DIR/fixtures/intent.envelope.json" "$run2" >/dev/null

v1="$(jq -c '{verdict,plan_ref,final_state_ref}' "$run1/final_result.json")"
v2="$(jq -c '{verdict,plan_ref,final_state_ref}' "$run2/final_result.json")"

if [[ "$v1" != "$v2" ]]; then
  echo "DETERMINISM_FAIL $v1 != $v2" >&2
  exit 1
fi

echo "DETERMINISM_PASS $v1"
