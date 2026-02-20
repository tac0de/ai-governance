#!/usr/bin/env node

const fs = require("fs");

const reportPath = ".ops/natural_ops_report.md";
const tracePath = ".ops/agent_pair_trace.json";

fs.mkdirSync(".ops", { recursive: true });

if (!fs.existsSync(tracePath)) {
  fs.writeFileSync(
    reportPath,
    [
      "# Natural Ops Report",
      "",
      "- trace: not generated",
      "- reason: autonomy step failed before agent pair run",
      "",
    ].join("\n")
  );
  process.exit(0);
}

const trace = JSON.parse(fs.readFileSync(tracePath, "utf8"));
const planner = (trace.turns || []).filter((x) => x.sender === "planner");
const executor = (trace.turns || []).filter((x) => x.sender === "executor");

const lines = [
  "# Natural Ops Report",
  "",
  `- created_at: ${new Date().toISOString()}`,
  `- realtime: ${trace.realtime}`,
  `- model: ${trace.model}`,
  `- planner_messages: ${planner.length}`,
  `- executor_messages: ${executor.length}`,
  "",
  "## Last planner message",
  planner.length ? planner[planner.length - 1].text : "n/a",
  "",
  "## Last executor message",
  executor.length ? executor[executor.length - 1].text : "n/a",
  "",
];

fs.writeFileSync(reportPath, lines.join("\n"));
