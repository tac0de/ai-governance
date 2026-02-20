#!/usr/bin/env node

import fs from "fs";
import path from "path";
import { createHash, randomUUID } from "crypto";

function stableStringify(value) {
  if (value === null || typeof value !== "object") {
    return JSON.stringify(value);
  }

  if (Array.isArray(value)) {
    return `[${value.map((v) => stableStringify(v)).join(",")}]`;
  }

  const body = Object.entries(value)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([k, v]) => `${JSON.stringify(k)}:${stableStringify(v)}`)
    .join(",");

  return `{${body}}`;
}

function sha256Hex(value) {
  return createHash("sha256").update(stableStringify(value)).digest("hex");
}

function getArg(name, fallback = "") {
  const key = `--${name}`;
  const i = process.argv.indexOf(key);
  if (i >= 0 && process.argv[i + 1]) return process.argv[i + 1];
  return fallback;
}

function vaultFilePath(date = new Date()) {
  const yyyy = date.getUTCFullYear();
  const mm = String(date.getUTCMonth() + 1).padStart(2, "0");
  const dd = String(date.getUTCDate()).padStart(2, "0");
  return path.resolve(process.cwd(), ".ops", "context_vault", `${yyyy}-${mm}-${dd}.jsonl`);
}

function ensureDir(file) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
}

function readLastHash(file) {
  if (!fs.existsSync(file)) return undefined;
  const lines = fs.readFileSync(file, "utf8").trim().split("\n").filter(Boolean);
  if (lines.length === 0) return undefined;
  try {
    const last = JSON.parse(lines[lines.length - 1]);
    return last.record_hash;
  } catch {
    return undefined;
  }
}

function appendEntry() {
  const file = vaultFilePath();
  ensureDir(file);

  const entry = {
    version: "1.0.0",
    id: randomUUID(),
    timestamp: new Date().toISOString(),
    project: getArg("project", "ai-governance"),
    session_id: getArg("session", "manual"),
    source: getArg("source", "assistant"),
    type: getArg("type", "note"),
    summary: getArg("summary", ""),
    details: getArg("details", ""),
    tags: getArg("tags", "")
      .split(",")
      .map((x) => x.trim())
      .filter(Boolean),
    related_paths: getArg("paths", "")
      .split(",")
      .map((x) => x.trim())
      .filter(Boolean),
    trace_id: getArg("trace", ""),
    importance: getArg("importance", "medium")
  };

  if (!entry.summary) {
    console.error("Missing required --summary");
    process.exit(1);
  }

  const prevHash = readLastHash(file);
  if (prevHash) entry.prev_hash = prevHash;

  const recordHash = sha256Hex(entry);
  entry.record_hash = recordHash;

  fs.appendFileSync(file, `${JSON.stringify(entry)}\n`, "utf8");
  console.log(JSON.stringify({ ok: true, file, id: entry.id, record_hash: recordHash }));
}

function recentEntries() {
  const file = vaultFilePath();
  if (!fs.existsSync(file)) {
    console.log("[]");
    return;
  }

  const limit = Number(getArg("limit", "10"));
  const lines = fs.readFileSync(file, "utf8").trim().split("\n").filter(Boolean);
  const out = lines.slice(-limit).map((line) => {
    try {
      return JSON.parse(line);
    } catch {
      return null;
    }
  }).filter(Boolean);

  console.log(JSON.stringify(out, null, 2));
}

const cmd = process.argv[2];

if (cmd === "append") {
  appendEntry();
} else if (cmd === "recent") {
  recentEntries();
} else {
  console.log("Usage:");
  console.log("  node tools/context_vault.js append --summary \"...\" [--project thedivineparadox] [--type insight]");
  console.log("  node tools/context_vault.js recent --limit 10");
}
