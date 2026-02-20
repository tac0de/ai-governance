#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

POLICY_FILE="${1:-config/env_fuse_policy.example.json}"

if [[ ! -f "${POLICY_FILE}" ]]; then
  echo "[env-fuse-check] ERROR: missing policy file: ${POLICY_FILE}"
  exit 1
fi

node - <<'NODE' "${POLICY_FILE}"
const fs = require("fs");
const path = process.argv[2];

function fail(msg) {
  console.error(`[env-fuse-check] ERROR: ${msg}`);
  process.exit(1);
}

let data;
try {
  data = JSON.parse(fs.readFileSync(path, "utf8"));
} catch (err) {
  fail(`invalid JSON in ${path}: ${err.message}`);
}

const must = [
  "version",
  "defaults",
  "budget",
  "model_policy",
  "risk_gate",
  "audit",
];

for (const k of must) {
  if (!(k in data)) fail(`missing key: ${k}`);
}

if (!Array.isArray(data.model_policy.allowlist) || data.model_policy.allowlist.length === 0) {
  fail("model_policy.allowlist must be a non-empty array");
}

const monthly = Number(data.budget.monthly_usd_cap);
const perService = Number(data.budget.per_service_usd_cap);
if (!Number.isFinite(monthly) || monthly <= 0) fail("budget.monthly_usd_cap must be > 0");
if (!Number.isFinite(perService) || perService <= 0) fail("budget.per_service_usd_cap must be > 0");
if (perService > monthly) fail("per_service_usd_cap must be <= monthly_usd_cap");

if (typeof data.defaults.dry_run !== "boolean") fail("defaults.dry_run must be boolean");
if (typeof data.defaults.real_apply_requires_human_gate !== "boolean") {
  fail("defaults.real_apply_requires_human_gate must be boolean");
}

if (typeof data.risk_gate.high_risk_requires_approval !== "boolean") {
  fail("risk_gate.high_risk_requires_approval must be boolean");
}
if (typeof data.risk_gate.contract_breaking_change_requires_approval !== "boolean") {
  fail("risk_gate.contract_breaking_change_requires_approval must be boolean");
}

if (!Array.isArray(data.audit.required_fields) || data.audit.required_fields.length < 5) {
  fail("audit.required_fields must include required audit keys");
}
if (data.audit.append_only !== true) fail("audit.append_only must be true");

console.log("[env-fuse-check] PASS");
NODE
