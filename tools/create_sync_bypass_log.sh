#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "${ROOT_DIR}/LOGS"

ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
file="${ROOT_DIR}/LOGS/${ts}_bypass.md"

cat > "${file}" <<EOF
- Date: ${ts}
- Project: ai-governance
- Author: $(git config user.name || whoami)
- Type: orchestration-note
- Tags: orchestration,automation,guard
- Summary (1 line): Manual bypass used for local development

Bypass invoked locally. Please commit this log entry alongside your change.
EOF

echo "Created bypass log: ${file}"
