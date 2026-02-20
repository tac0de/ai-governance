import { mkdir } from "node:fs/promises";
import { resolve } from "node:path";
import { auditFiles } from "./auditor.js";
import { runPlan } from "./executor.js";
import type { Plan } from "./types.js";
import { readJsonFile, validateJsonBySchema } from "./validate.js";

function getArg(flag: string): string | undefined {
  const idx = process.argv.indexOf(flag);
  return idx >= 0 ? process.argv[idx + 1] : undefined;
}

function printUsage(): void {
  console.log("Usage:");
  console.log("  node dist/index.js validate --plan <plan.json>");
  console.log("  node dist/index.js run --plan <plan.json> --outdir <out/>");
  console.log("  node dist/index.js audit --plan <plan.json> --result <result.json> --evidence <evidence.json> --out <audit.json>");
}

async function main(): Promise<number> {
  const command = process.argv[2];
  if (!command) {
    printUsage();
    return 1;
  }

  if (command === "validate") {
    const planPath = getArg("--plan");
    if (!planPath) {
      printUsage();
      return 1;
    }
    const plan = await readJsonFile<Plan>(planPath);
    const violations = await validateJsonBySchema("plan", plan);
    if (violations.length > 0) {
      console.error("REJECT HUNBUP_PLAN_SCHEMA_INVALID");
      console.error(JSON.stringify(violations, null, 2));
      return 1;
    }
    console.log("PASS");
    return 0;
  }

  if (command === "run") {
    const planPath = getArg("--plan");
    const outDir = getArg("--outdir");
    if (!planPath || !outDir) {
      printUsage();
      return 1;
    }

    await mkdir(outDir, { recursive: true });
    const exec = await runPlan(planPath, outDir);
    if (exec.violations.length > 0) {
      const violation = exec.violations[0];
      console.error(`REJECT ${violation.code}`);
      console.error(JSON.stringify(exec.violations, null, 2));
      return 1;
    }
    console.log("PASS");
    return 0;
  }

  if (command === "audit") {
    const planPath = getArg("--plan");
    const resultPath = getArg("--result");
    const evidencePath = getArg("--evidence");
    const outPath = getArg("--out");
    if (!planPath || !resultPath || !evidencePath || !outPath) {
      printUsage();
      return 1;
    }

    await mkdir(resolve(outPath, ".."), { recursive: true });
    const audit = await auditFiles(planPath, resultPath, evidencePath, outPath);
    if (audit.status === "REJECT") {
      console.error(`REJECT ${audit.reason_code}`);
      return 1;
    }
    console.log("PASS");
    return 0;
  }

  printUsage();
  return 1;
}

main()
  .then((code) => {
    process.exit(code);
  })
  .catch((error) => {
    console.error(error instanceof Error ? error.message : String(error));
    process.exit(1);
  });
