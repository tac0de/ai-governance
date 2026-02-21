#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${ROOT_DIR}/out/core-boundary-gate"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

require_cmd go
require_cmd jq
if command -v sha256sum >/dev/null 2>&1; then
  SHA_CMD="sha256sum"
elif command -v shasum >/dev/null 2>&1; then
  SHA_CMD="shasum -a 256"
else
  echo "Missing hash command: sha256sum or shasum" >&2
  exit 1
fi

mkdir -p "${OUT_DIR}/run1" "${OUT_DIR}/run2"

echo "[core-gate] JSON syntax check for schemas and cases"
while IFS= read -r json_file; do
  jq -e . "$json_file" >/dev/null
done < <(find "${ROOT_DIR}/schemas/jsonschema" "${ROOT_DIR}/constitution/cases" -type f -name '*.json' | sort)

echo "[core-gate] Build control-plane hub"
(
  cd "${ROOT_DIR}/control-plane/go"
  go build -o "${OUT_DIR}/cp-bin" ./cmd/hub
)

echo "[core-gate] Schema validation through hub validate (pass vectors)"
while IFS= read -r plan_file; do
  "${OUT_DIR}/cp-bin" validate --plan "$plan_file"
done < <(find "${ROOT_DIR}/constitution/cases/pass" -type f -name '*.plan.json' | sort)

run_pipeline() {
  local outdir="$1"
  "${OUT_DIR}/cp-bin" run --plan "${ROOT_DIR}/constitution/cases/pass/case001.plan.json" --outdir "$outdir"
  "${OUT_DIR}/cp-bin" audit \
    --plan "${ROOT_DIR}/constitution/cases/pass/case001.plan.json" \
    --result "${outdir}/result.json" \
    --evidence "${outdir}/evidence.json" \
    --out "${outdir}/audit.json"
}

echo "[core-gate] Deterministic semantic verdict check (double run)"
run_pipeline "${OUT_DIR}/run1"
run_pipeline "${OUT_DIR}/run2"

echo "[core-gate] Canonicalize and hash outputs"
for target in result evidence audit; do
  jq -cS . "${OUT_DIR}/run1/${target}.json" > "${OUT_DIR}/run1/${target}.canonical.json"
  jq -cS . "${OUT_DIR}/run2/${target}.json" > "${OUT_DIR}/run2/${target}.canonical.json"
  eval "${SHA_CMD} \"${OUT_DIR}/run1/${target}.canonical.json\"" | awk '{print $1}' > "${OUT_DIR}/run1/${target}.sha256"
  eval "${SHA_CMD} \"${OUT_DIR}/run2/${target}.canonical.json\"" | awk '{print $1}' > "${OUT_DIR}/run2/${target}.sha256"
done

verdict_run1="$(jq -c '{status, reason_code, governance_command}' "${OUT_DIR}/run1/audit.json")"
verdict_run2="$(jq -c '{status, reason_code, governance_command}' "${OUT_DIR}/run2/audit.json")"

if [[ "${verdict_run1}" != "${verdict_run2}" ]]; then
  echo "Deterministic verdict mismatch:" >&2
  echo "run1=${verdict_run1}" >&2
  echo "run2=${verdict_run2}" >&2
  exit 1
fi

echo "[core-gate] PASS"
