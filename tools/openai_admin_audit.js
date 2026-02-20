#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

function parseArgs(argv) {
  const args = {
    apiBase: "https://api.openai.com/v1",
    outJson: ".ops/openai_admin_audit_report.json",
    outMd: ".ops/openai_admin_audit_report.md",
    strict: process.env.OPENAI_ADMIN_AUDIT_STRICT === "true",
  };

  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (token === "--api-base") args.apiBase = argv[++i] || args.apiBase;
    else if (token === "--out-json") args.outJson = argv[++i] || args.outJson;
    else if (token === "--out-md") args.outMd = argv[++i] || args.outMd;
    else if (token === "--strict") args.strict = true;
    else if (token === "--help" || token === "-h") args.help = true;
    else throw new Error(`Unknown argument: ${token}`);
  }

  return args;
}

function usage() {
  return [
    "Usage:",
    "  node tools/openai_admin_audit.js [--api-base <url>] [--out-json <path>] [--out-md <path>] [--strict]",
    "",
    "Environment:",
    "  OPENAI_ADMIN_API_KEY      required",
    "  OPENAI_ADMIN_AUDIT_STRICT optional (true|false)",
  ].join("\n");
}

function ensureDir(filePath) {
  fs.mkdirSync(path.dirname(path.resolve(filePath)), { recursive: true });
}

function writeFile(filePath, content) {
  ensureDir(filePath);
  fs.writeFileSync(path.resolve(filePath), content);
}

function statusLabel(ok) {
  return ok ? "ok" : "error";
}

function firstLine(text) {
  return String(text || "").split("\n")[0].trim();
}

async function getJson(apiBase, endpoint, key) {
  const url = `${apiBase}${endpoint}`;
  const res = await fetch(url, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${key}`,
      "Content-Type": "application/json",
    },
  });

  const raw = await res.text();
  let parsed = null;
  try {
    parsed = raw ? JSON.parse(raw) : null;
  } catch {
    parsed = null;
  }

  if (!res.ok) {
    const message = parsed && parsed.error && parsed.error.message ? parsed.error.message : firstLine(raw);
    return {
      ok: false,
      status: res.status,
      error: message || `HTTP ${res.status}`,
      data: parsed,
    };
  }

  return {
    ok: true,
    status: res.status,
    data: parsed,
  };
}

function summarizeProjects(resp) {
  if (!resp.ok) {
    return {
      ok: false,
      status: resp.status,
      error: resp.error,
      total: 0,
      archived: 0,
    };
  }

  const rows = Array.isArray(resp.data && resp.data.data) ? resp.data.data : [];
  const archived = rows.filter((p) => p && (p.archived === true || p.status === "archived")).length;

  return {
    ok: true,
    status: resp.status,
    total: rows.length,
    archived,
  };
}

function summarizeInvites(resp) {
  if (!resp.ok) {
    return {
      ok: false,
      status: resp.status,
      error: resp.error,
      total: 0,
      accepted: 0,
      pending: 0,
    };
  }

  const rows = Array.isArray(resp.data && resp.data.data) ? resp.data.data : [];
  const accepted = rows.filter((item) => Boolean(item && item.accepted_at)).length;
  const pending = rows.length - accepted;

  return {
    ok: true,
    status: resp.status,
    total: rows.length,
    accepted,
    pending,
  };
}

function summarizeUsers(resp) {
  if (!resp.ok) {
    return {
      ok: false,
      status: resp.status,
      error: resp.error,
      total: 0,
      owners: 0,
      readers: 0,
    };
  }

  const rows = Array.isArray(resp.data && resp.data.data) ? resp.data.data : [];
  let owners = 0;
  let readers = 0;

  for (const row of rows) {
    const role = String((row && row.role) || "").toLowerCase();
    if (role === "owner") owners += 1;
    if (role === "reader") readers += 1;
  }

  return {
    ok: true,
    status: resp.status,
    total: rows.length,
    owners,
    readers,
  };
}

function summarizeAuditLogs(resp) {
  if (!resp.ok) {
    return {
      ok: false,
      status: resp.status,
      error: resp.error,
      total: 0,
      latest_event_type: "n/a",
      latest_event_time: "n/a",
    };
  }

  const rows = Array.isArray(resp.data && resp.data.data) ? resp.data.data : [];
  const latest = rows[0] || {};
  const latestType = String(latest && latest.type ? latest.type : "n/a");
  const latestTime = String(latest && latest.effective_at ? latest.effective_at : "n/a");

  return {
    ok: true,
    status: resp.status,
    total: rows.length,
    latest_event_type: latestType,
    latest_event_time: latestTime,
  };
}

function buildFindings(summary) {
  const findings = [];

  if (!summary.projects.ok) {
    findings.push(`projects endpoint failed (${summary.projects.status}): ${summary.projects.error}`);
  }
  if (!summary.invites.ok) {
    findings.push(`invites endpoint failed (${summary.invites.status}): ${summary.invites.error}`);
  }
  if (!summary.users.ok) {
    findings.push(`users endpoint failed (${summary.users.status}): ${summary.users.error}`);
  }
  if (!summary.audit_logs.ok) {
    findings.push(`audit_logs endpoint failed (${summary.audit_logs.status}): ${summary.audit_logs.error}`);
  }
  if (summary.invites.ok && summary.invites.pending > 0) {
    findings.push(`pending invites detected: ${summary.invites.pending}`);
  }
  if (summary.users.ok && summary.users.owners === 0) {
    findings.push("owner count is zero (check organization RBAC)");
  }

  return findings;
}

function reportStatus(findings) {
  if (!findings.length) return "ok";
  const onlyPending = findings.every((f) => f.startsWith("pending invites detected:"));
  return onlyPending ? "warning" : "error";
}

function toMarkdown(report) {
  const s = report.summary;
  const lines = [
    "# OpenAI Admin Audit Report",
    "",
    `- generated_at: ${report.generated_at}`,
    `- status: ${report.status}`,
    `- api_base: ${report.api_base}`,
    "",
    "## Endpoint summary",
    `- projects: ${statusLabel(s.projects.ok)} (total=${s.projects.total}, archived=${s.projects.archived})`,
    `- invites: ${statusLabel(s.invites.ok)} (total=${s.invites.total}, pending=${s.invites.pending})`,
    `- users: ${statusLabel(s.users.ok)} (total=${s.users.total}, owners=${s.users.owners}, readers=${s.users.readers})`,
    `- audit_logs: ${statusLabel(s.audit_logs.ok)} (events=${s.audit_logs.total}, latest=${s.audit_logs.latest_event_type} @ ${s.audit_logs.latest_event_time})`,
    "",
    "## Findings",
  ];

  if (report.findings.length === 0) {
    lines.push("- none");
  } else {
    for (const finding of report.findings) {
      lines.push(`- ${finding}`);
    }
  }

  lines.push("");
  lines.push("## Next action");
  if (report.status === "ok") {
    lines.push("- Keep this workflow scheduled daily and rotate admin keys per policy.");
  } else if (report.status === "warning") {
    lines.push("- Resolve pending invites or close stale invites.");
  } else {
    lines.push("- Check failed endpoints/RBAC, then re-run workflow_dispatch.");
  }

  return lines.join("\n");
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    console.log(usage());
    return;
  }

  const adminKey = process.env.OPENAI_ADMIN_API_KEY || "";
  if (!adminKey) {
    throw new Error("Missing OPENAI_ADMIN_API_KEY");
  }

  const apiBase = String(args.apiBase || "").replace(/\/+$/, "");

  const [projectsResp, invitesResp, usersResp, auditLogsResp] = await Promise.all([
    getJson(apiBase, "/organization/projects?limit=100", adminKey),
    getJson(apiBase, "/organization/invites?limit=100", adminKey),
    getJson(apiBase, "/organization/users?limit=100", adminKey),
    getJson(apiBase, "/organization/audit_logs?limit=50", adminKey),
  ]);

  const summary = {
    projects: summarizeProjects(projectsResp),
    invites: summarizeInvites(invitesResp),
    users: summarizeUsers(usersResp),
    audit_logs: summarizeAuditLogs(auditLogsResp),
  };

  const findings = buildFindings(summary);
  const status = reportStatus(findings);
  const report = {
    generated_at: new Date().toISOString(),
    status,
    api_base: apiBase,
    summary,
    findings,
  };

  writeFile(args.outJson, JSON.stringify(report, null, 2));
  writeFile(args.outMd, toMarkdown(report));

  console.log(`[openai-admin-audit] status=${status}`);
  console.log(`[openai-admin-audit] out_json=${path.resolve(args.outJson)}`);
  console.log(`[openai-admin-audit] out_md=${path.resolve(args.outMd)}`);

  if (args.strict && status === "error") {
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error(`[openai-admin-audit] ERROR: ${error.message}`);
  process.exit(1);
});
