#!/usr/bin/env bash
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_ROOT="${1:-}"
LINK_ID="${2:-sample-link}"

if [[ -z "$TARGET_ROOT" ]]; then
  echo "usage: install.sh <service-root> [link-id]" >&2
  exit 1
fi

TARGET_LINK_DIR="$TARGET_ROOT/governance/links/active/$LINK_ID"
mkdir -p "$TARGET_LINK_DIR"

for template_path in \
  link.request.json \
  link.grant.json \
  link.route.json \
  auth.contract.json \
  approval.receipt.json \
  scan.intake-contract.json \
  scan.boundary-seal.json \
  scan.baseline.json \
  scan.plan.json \
  scan.review-gate.json \
  review.outcome.json \
  gate.approval.json \
  residue.check.json \
  status.json \
  scan.pre-release.json
do
  sed "s/__LINK_ID__/${LINK_ID}/g" "$PACK_DIR/$template_path" > "$TARGET_LINK_DIR/$template_path"
done
