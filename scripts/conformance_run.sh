#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE_ROOT="${ROOT_DIR}/conformance/fixtures"

if [[ "${NO_NETWORK:-1}" != "1" ]]; then
  echo "Conformance must run in offline mode (NO_NETWORK=1)." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Missing required command: jq" >&2
  exit 1
fi

if command -v sha256sum >/dev/null 2>&1; then
  HASH_CMD="sha256sum"
elif command -v shasum >/dev/null 2>&1; then
  HASH_CMD="shasum -a 256"
else
  echo "Missing hash command: sha256sum or shasum" >&2
  exit 1
fi

status=0

while IFS= read -r manifest; do
  fixture_dir="$(dirname "$manifest")"
  fixture_id="$(jq -r '.fixture_id' "$manifest")"
  replay_mode="$(jq -r '.mode' "$manifest")"
  allow_network="$(jq -r '.allow_network' "$manifest")"
  output_file="${fixture_dir}/$(jq -r '.output_file' "$manifest")"
  expected_hash_file="${fixture_dir}/$(jq -r '.expected_output_sha256_file' "$manifest")"

  if [[ "$replay_mode" != "replay" ]]; then
    echo "FAIL ${fixture_id}: mode must be replay" >&2
    status=1
    continue
  fi

  if [[ "$allow_network" != "false" ]]; then
    echo "FAIL ${fixture_id}: allow_network must be false" >&2
    status=1
    continue
  fi

  canonical_output="$(jq -cS . "$output_file")"
  actual_hash="$(printf '%s' "$canonical_output" | eval "$HASH_CMD" | awk '{print $1}')"
  expected_hash="$(tr -d '[:space:]' < "$expected_hash_file")"

  if [[ "$actual_hash" != "$expected_hash" ]]; then
    echo "FAIL ${fixture_id}: hash mismatch expected=${expected_hash} actual=${actual_hash}" >&2
    status=1
    continue
  fi

  echo "PASS ${fixture_id}: replay hash matched"
done < <(find "$FIXTURE_ROOT" -type f -name manifest.json | sort)

exit "$status"
