#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage:
  export_governance_journal.sh <trace_path> [export_root]

Defaults:
  export_root: traces/governance-journal
USAGE
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_arg="$1"
export_root="${2:-$ROOT_DIR/traces/governance-journal}"
mcp_registry="$ROOT_DIR/control/registry/mcps.v0.1.json"
obsidian_allowlist="$ROOT_DIR/services/obsidian-mcp/mcp.allowlist.json"
journal_mcp_id="core-governance-journal-mcp"

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1" >&2; exit 1; }
}

hash_stream() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}

hash_file() {
  local target="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$target" | awk '{print $1}'
  else
    shasum -a 256 "$target" | awk '{print $1}'
  fi
}

require jq

if [[ "$source_arg" = /* ]]; then
  source_path="$source_arg"
else
  source_path="$ROOT_DIR/$source_arg"
fi

if [[ ! -e "$source_path" ]]; then
  echo "SOURCE_PATH_MISSING $source_arg" >&2
  exit 1
fi

source_abs="$(cd "$(dirname "$source_path")" && pwd)/$(basename "$source_path")"
traces_root="$ROOT_DIR/traces"
case "$source_abs" in
  "$traces_root"/*) ;;
  *)
    echo "SOURCE_PATH_OUTSIDE_TRACES $source_arg" >&2
    exit 1
    ;;
esac

if [[ ! -f "$mcp_registry" || ! -f "$obsidian_allowlist" ]]; then
  echo "JOURNAL_CONTRACT_MISSING" >&2
  exit 1
fi

if ! jq -e --arg id "$journal_mcp_id" '.mcps | any(.id==$id)' "$mcp_registry" >/dev/null 2>&1; then
  echo "JOURNAL_MCP_NOT_REGISTERED $journal_mcp_id" >&2
  exit 1
fi

if ! jq -e --arg id "$journal_mcp_id" '.allowed_mcps | any(.mcp_id==$id)' "$obsidian_allowlist" >/dev/null 2>&1; then
  echo "JOURNAL_MCP_NOT_ALLOWED_FOR_OBSIDIAN $journal_mcp_id" >&2
  exit 1
fi

file_rows=""
if [[ -f "$source_abs" ]]; then
  rel_path="${source_abs#$ROOT_DIR/}"
  file_hash="$(hash_file "$source_abs")"
  file_rows="$(printf '%s\t%s\n' "$rel_path" "$file_hash")"
else
  while IFS= read -r file_path; do
    rel_path="${file_path#$ROOT_DIR/}"
    file_hash="$(hash_file "$file_path")"
    file_rows+="${rel_path}"$'\t'"${file_hash}"$'\n'
  done < <(find "$source_abs" -type f | sort)
fi

if [[ -z "$file_rows" ]]; then
  echo "SOURCE_HAS_NO_FILES $source_arg" >&2
  exit 1
fi

bundle_hash="$(printf '%s' "$file_rows" | hash_stream)"
export_id="journal-export-${bundle_hash:0:16}"
mkdir -p "$export_root"

packet_path="$export_root/${export_id}.packet.json"
receipt_path="$export_root/${export_id}.receipt.json"

printf '%s' "$file_rows" | jq -R -s '
  split("\n")
  | map(select(length>0))
  | map(split("\t"))
  | map({path: .[0], sha256: .[1]})
' > "$export_root/.${export_id}.files.tmp.json"

jq -cn \
  --arg version "v0.1" \
  --arg export_id "$export_id" \
  --arg mcp_id "$journal_mcp_id" \
  --arg sink_service "obsidian-mcp" \
  --arg source_path "${source_abs#$ROOT_DIR/}" \
  --arg source_bundle_hash "$bundle_hash" \
  --slurpfile files "$export_root/.${export_id}.files.tmp.json" \
  '{
    version: $version,
    export_id: $export_id,
    mcp_id: $mcp_id,
    sink_service: $sink_service,
    source_path: $source_path,
    source_bundle_hash: $source_bundle_hash,
    status: "prepared",
    files: $files[0]
  }' > "$packet_path"

rm -f "$export_root/.${export_id}.files.tmp.json"

packet_hash="$(bash "$ROOT_DIR/scripts/hash_ref.sh" "$packet_path")"

jq -cn \
  --arg version "v0.1" \
  --arg export_id "$export_id" \
  --arg packet_path "${packet_path#$ROOT_DIR/}" \
  --arg packet_sha256 "$packet_hash" \
  --arg sink_service "obsidian-mcp" \
  '{
    version: $version,
    export_id: $export_id,
    packet_path: $packet_path,
    packet_sha256: $packet_sha256,
    sink_service: $sink_service,
    verification_status: "pending_external_ack"
  }' > "$receipt_path"

echo "EXPORT_READY export_id=$export_id"
echo "packet=${packet_path#$ROOT_DIR/}"
echo "receipt=${receipt_path#$ROOT_DIR/}"
