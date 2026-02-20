#!/usr/bin/env node

const fs = require("fs");

function loadDotEnv(filePath) {
  if (!fs.existsSync(filePath)) return;
  const lines = fs.readFileSync(filePath, "utf8").split(/\r?\n/);
  for (const rawLine of lines) {
    const line = rawLine.trim();
    if (!line || line.startsWith("#")) continue;
    const idx = line.indexOf("=");
    if (idx <= 0) continue;
    const key = line.slice(0, idx).trim();
    if (!key) continue;
    let value = line.slice(idx + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    if (!Object.prototype.hasOwnProperty.call(process.env, key) || process.env[key] === "") {
      process.env[key] = value;
    }
  }
}

loadDotEnv(".env");

const key = process.env.OPENAI_API_KEY || "";
const realtimeFlag = (process.env.OPENAI_REAL_CALL || "").trim().toLowerCase();
const realtime = (realtimeFlag ? realtimeFlag === "true" : key.length > 0) && key.length > 0;
const model = process.env.OPENAI_MODEL || "gpt-5-nano";
const maxTokens = Number(process.env.OPENAI_MAX_OUTPUT_TOKENS || 120);
const base = process.env.OPENAI_BASE_URL || "https://api.openai.com/v1";

async function callAgent(role, input) {
  if (!realtime) {
    return { role, text: `[mock-${role}] ${input.slice(0, 180)}` };
  }

  const systemPrompt =
    role === "planner"
      ? "You are Planner. Return one concise low-risk improvement idea and a validation check."
      : "You are Executor. Critique the planner output, mention one risk, and propose one safer refinement.";

  const body = {
    model,
    input: [
      { role: "system", content: systemPrompt },
      { role: "user", content: input },
    ],
    max_output_tokens: maxTokens,
  };

  const res = await fetch(`${base}/responses`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${key}`,
    },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const txt = await res.text();
    throw new Error(`OpenAI error ${res.status}: ${txt}`);
  }

  const json = await res.json();
  const text =
    json.output_text ||
    (json.output?.[0]?.content || [])
      .map((c) => c?.text || "")
      .join("") ||
    "";

  return { role, text: text.trim(), response_id: json.id || "" };
}

async function main() {
  const trace = {
    created_at: new Date().toISOString(),
    realtime,
    model,
    turns: [],
  };

  let plannerInput =
    "Context: personal-art-gallery improvement loop. Goal: propose one low-risk next action.";
  for (let turn = 1; turn <= 3; turn += 1) {
    const planner = await callAgent("planner", plannerInput);
    trace.turns.push({ turn, sender: "planner", text: planner.text });

    const executor = await callAgent(
      "executor",
      `Planner output:\n${planner.text}\n\nReturn: one critique + one safer revision.`
    );
    trace.turns.push({ turn, sender: "executor", text: executor.text });

    plannerInput = `Executor feedback:\n${executor.text}\n\nRefine one final next action.`;
  }

  fs.mkdirSync(".ops", { recursive: true });
  fs.writeFileSync(".ops/agent_pair_trace.json", JSON.stringify(trace, null, 2));
  console.log("[agent-pair] trace written:", trace.turns.length, "messages");
}

main().catch((err) => {
  console.error("[agent-pair] failed:", err.message || String(err));
  process.exit(1);
});
