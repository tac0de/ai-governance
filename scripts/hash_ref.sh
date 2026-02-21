#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <json_file>" >&2
  exit 1
fi

file="$1"
canonical="$(jq -cS . "$file")"
if command -v sha256sum >/dev/null 2>&1; then
  printf '%s' "$canonical" | sha256sum | awk '{print $1}'
else
  printf '%s' "$canonical" | shasum -a 256 | awk '{print $1}'
fi
