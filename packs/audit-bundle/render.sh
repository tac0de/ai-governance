#!/usr/bin/env bash
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_PATH="${1:-audit-bundle.json}"

command -v jq >/dev/null 2>&1 || {
  echo "jq is required" >&2
  exit 1
}

jq \
  --arg bundle_id "${BUNDLE_ID:-sample-bundle}" \
  --arg customer_id "${CUSTOMER_ID:-sample-customer}" \
  --arg service_id "${SERVICE_ID:-sample-service}" \
  --arg link_id "${LINK_ID:-sample-link}" \
  '
    .bundle_id=$bundle_id |
    .customer_id=$customer_id |
    .service_id=$service_id |
    .link_id=$link_id |
    .auth_contract_ref=("governance/links/active/" + $link_id + "/auth.contract.json") |
    .approval_receipt_ref=("governance/links/active/" + $link_id + "/approval.receipt.json")
  ' \
  "$PACK_DIR/bundle.template.json" > "$OUTPUT_PATH"
