#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
state_ref="$(bash "$ROOT_DIR/scripts/hash_ref.sh" "$ROOT_DIR/fixtures/state.json")"
acceptance_ref="$(bash "$ROOT_DIR/scripts/hash_ref.sh" "$ROOT_DIR/fixtures/acceptance.tests.json")"

jq --arg s "$state_ref" --arg a "$acceptance_ref" '
  .state_ref=$s | .acceptance_tests_ref=$a
' "$ROOT_DIR/fixtures/intent.envelope.json" > "$ROOT_DIR/fixtures/intent.envelope.tmp.json"
mv "$ROOT_DIR/fixtures/intent.envelope.tmp.json" "$ROOT_DIR/fixtures/intent.envelope.json"

echo "state_ref=$state_ref"
echo "acceptance_tests_ref=$acceptance_ref"
