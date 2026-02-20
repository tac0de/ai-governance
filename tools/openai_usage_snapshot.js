#!/usr/bin/env node

function parseArgs(argv) {
  const args = {
    apiBase: "https://api.openai.com/v1",
    windowDays: 7,
  };
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (token === "--api-base") args.apiBase = argv[++i] || args.apiBase;
    else if (token === "--window-days") args.windowDays = Number(argv[++i] || args.windowDays);
    else if (token === "--help" || token === "-h") args.help = true;
    else throw new Error(`Unknown argument: ${token}`);
  }
  return args;
}

async function getJson(url, key) {
  const res = await fetch(url, {
    headers: {
      Authorization: `Bearer ${key}`,
      "Content-Type": "application/json",
    },
  });
  const raw = await res.text();
  let data = null;
  try {
    data = raw ? JSON.parse(raw) : null;
  } catch {
    data = null;
  }
  return { ok: res.ok, status: res.status, data, raw };
}

function tsNow() {
  return Math.floor(Date.now() / 1000);
}

function summarizeCosts(resp) {
  if (!resp.ok || !resp.data) {
    return { ok: false, error: `costs endpoint failed (${resp.status})` };
  }
  const buckets = Array.isArray(resp.data.data) ? resp.data.data : [];
  let total = 0;
  for (const b of buckets) {
    const amount = Number(
      b?.amount?.value ??
        b?.results?.[0]?.amount?.value ??
        0
    );
    total += Number.isFinite(amount) ? amount : 0;
  }
  return { ok: true, window_cost_usd: Number(total.toFixed(6)), buckets: buckets.length };
}

function summarizeCompletions(resp) {
  if (!resp.ok || !resp.data) {
    return { ok: false, error: `usage/completions endpoint failed (${resp.status})` };
  }
  const rows = Array.isArray(resp.data.data) ? resp.data.data : [];
  let input = 0;
  let output = 0;
  for (const r of rows) {
    input += Number(r?.n_input_tokens ?? r?.input_tokens ?? 0) || 0;
    output += Number(r?.n_output_tokens ?? r?.output_tokens ?? 0) || 0;
  }
  return { ok: true, input_tokens: input, output_tokens: output, rows: rows.length };
}

function toMarkdown(report) {
  return [
    "# OpenAI Weekly Usage Snapshot",
    "",
    `- generated_at: ${report.generated_at}`,
    `- window_days: ${report.window_days}`,
    "",
    "## Costs",
    report.costs.ok
      ? `- cost_usd_window: ${report.costs.window_cost_usd}`
      : `- unavailable: ${report.costs.error}`,
    "",
    "## Tokens",
    report.completions.ok
      ? `- input_tokens: ${report.completions.input_tokens}\n- output_tokens: ${report.completions.output_tokens}`
      : `- unavailable: ${report.completions.error}`,
    "",
    "## Note",
    "- If cost/token values are unavailable, check admin key scope and organization billing endpoints.",
    "",
  ].join("\n");
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    console.log("Usage: node tools/openai_usage_snapshot.js [--window-days 7]");
    process.exit(0);
  }
  const key = process.env.OPENAI_ADMIN_API_KEY || process.env.OPENAI_API_KEY;
  if (!key) throw new Error("Missing OPENAI_ADMIN_API_KEY or OPENAI_API_KEY");

  const end = tsNow();
  const start = end - args.windowDays * 86400;
  const base = args.apiBase.replace(/\/$/, "");

  const costsResp = await getJson(`${base}/organization/costs?start_time=${start}&end_time=${end}`, key);
  const compResp = await getJson(`${base}/organization/usage/completions?start_time=${start}&end_time=${end}`, key);

  const report = {
    generated_at: new Date().toISOString(),
    window_days: args.windowDays,
    costs: summarizeCosts(costsResp),
    completions: summarizeCompletions(compResp),
  };

  process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);
  process.stderr.write(`${toMarkdown(report)}\n`);
}

main().catch((err) => {
  console.error(err.message || String(err));
  process.exit(1);
});
