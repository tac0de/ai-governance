#!/usr/bin/env bash
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_ROOT="${1:-}"

if [[ -z "$TARGET_ROOT" ]]; then
  echo "usage: install.sh <service-root>" >&2
  exit 1
fi

command -v jq >/dev/null 2>&1 || {
  echo "jq is required" >&2
  exit 1
}

mkdir -p "$TARGET_ROOT"

while IFS= read -r rel_dir; do
  mkdir -p "$TARGET_ROOT/$rel_dir"
done < <(jq -r '.directories[]' "$PACK_DIR/payload.json")

while IFS= read -r encoded; do
  entry_json="$(printf '%s' "$encoded" | base64 --decode)"
  rel_path="$(printf '%s' "$entry_json" | jq -r '.path')"
  content="$(printf '%s' "$entry_json" | jq -r '.content')"
  mkdir -p "$(dirname "$TARGET_ROOT/$rel_path")"
  printf '%s' "$content" > "$TARGET_ROOT/$rel_path"
done < <(jq -r '.files[] | @base64' "$PACK_DIR/payload.json")
