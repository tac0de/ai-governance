#!/usr/bin/env node

const fs = require("fs");

const contractPath = ".ops/run_contract.json";
const contract = JSON.parse(fs.readFileSync(contractPath, "utf8"));
const required = [
  "run_id",
  "risk_level",
  "human_gate_required",
  "artifacts",
  "status",
  "source",
  "created_at",
];

for (const key of required) {
  if (!(key in contract)) {
    console.error(`[run-contract] missing key: ${key}`);
    process.exit(1);
  }
}

if (!Array.isArray(contract.artifacts) || contract.artifacts.length < 2) {
  console.error("[run-contract] artifacts must include trace/report/contract");
  process.exit(1);
}

console.log("[run-contract] PASS");
