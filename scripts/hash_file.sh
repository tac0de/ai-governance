#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <file>" >&2
  exit 1
fi

target="$1"
if [[ ! -f "$target" ]]; then
  echo "FILE_NOT_FOUND $target" >&2
  exit 1
fi

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$target" | awk '{print $1}'
else
  shasum -a 256 "$target" | awk '{print $1}'
fi
