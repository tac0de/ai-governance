import { spawnSync } from "node:child_process";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import type { Evidence, EvidenceAction, LocalExecAction, Plan, Result, ResultAction, Violation } from "./types.js";
import { buildOutputsHash, normalizeEvidenceAction, summarizeOutput } from "./evidence.js";
import { sha256File, sha256Json } from "./hash.js";
import { PolicyError, ensureSafeEnv, resolveLocalCommand } from "./policy.js";
import { readJsonFile, validateJsonBySchema } from "./validate.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const runScriptPath = resolve(__dirname, "../scripts/run_action.sh");

function uidOrNull(): number | null {
  return typeof process.getuid === "function" ? process.getuid() : null;
}

function gidOrNull(): number | null {
  return typeof process.getgid === "function" ? process.getgid() : null;
}

export async function runPlan(planPath: string, outDir: string): Promise<{ result: Result; evidence: Evidence; violations: Violation[] }> {
  const plan = await readJsonFile<Plan>(planPath);
  const planViolations = await validateJsonBySchema("plan", plan);
  if (planViolations.length > 0) {
    return {
      result: {
        version: "1.0",
        request_id: plan.request_id || "unknown",
        actions: []
      },
      evidence: {
        version: "1.0",
        request_id: plan.request_id || "unknown",
        actions: [],
        platform: {
          node: process.version,
          os: process.platform,
          arch: process.arch
        }
      },
      violations: planViolations
    };
  }

  const action = plan.actions[0];
  const actionPath = "/actions/0";
  if (action.type !== "local_exec") {
    return {
      result: {
        version: "1.0",
        request_id: plan.request_id,
        actions: []
      },
      evidence: {
        version: "1.0",
        request_id: plan.request_id,
        actions: [],
        platform: {
          node: process.version,
          os: process.platform,
          arch: process.arch
        }
      },
      violations: [
        {
          code: "HUNBUP_ACTION_TYPE_NOT_ALLOWED",
          path: `${actionPath}/type`,
          message: `Unsupported action type in executor: ${action.type}`
        }
      ]
    };
  }

  const localAction = action as LocalExecAction;
  const logsDir = resolve(outDir, "logs");
  await mkdir(logsDir, { recursive: true });

  let command: string[];
  try {
    ensureSafeEnv(localAction.env, actionPath);
    command = resolveLocalCommand(localAction, actionPath);
  } catch (error) {
    if (error instanceof PolicyError) {
      return {
        result: {
          version: "1.0",
          request_id: plan.request_id,
          actions: []
        },
        evidence: {
          version: "1.0",
          request_id: plan.request_id,
          actions: [],
          platform: {
            node: process.version,
            os: process.platform,
            arch: process.arch
          }
        },
        violations: [
          {
            code: error.code,
            path: error.path,
            message: error.message
          }
        ]
      };
    }
    throw error;
  }

  const commandJsonPath = resolve(outDir, `${localAction.id}.command.json`);
  const envJsonPath = resolve(outDir, `${localAction.id}.env.json`);
  const stdoutPath = resolve(logsDir, `${localAction.id}.stdout.log`);
  const stderrPath = resolve(logsDir, `${localAction.id}.stderr.log`);

  await writeFile(commandJsonPath, JSON.stringify(command), "utf8");
  await writeFile(envJsonPath, JSON.stringify(localAction.env), "utf8");

  const run = spawnSync(
    runScriptPath,
    [
      "--command-json",
      commandJsonPath,
      "--timeout-sec",
      String(localAction.timeout_sec),
      "--stdout",
      stdoutPath,
      "--stderr",
      stderrPath,
      "--env-json",
      envJsonPath
    ],
    {
      cwd: process.cwd(),
      stdio: "inherit"
    }
  );

  const exitCode = run.status ?? 1;
  const stdoutText = await readFile(stdoutPath, "utf8");
  const stderrText = await readFile(stderrPath, "utf8");
  const stdoutHash = await sha256File(stdoutPath);
  const stderrHash = await sha256File(stderrPath);

  const artifacts = [
    { path: stdoutPath, sha256: stdoutHash },
    { path: stderrPath, sha256: stderrHash }
  ];

  const resultAction: ResultAction = {
    id: localAction.id,
    status: exitCode === 0 ? "ok" : "error",
    artifacts,
    stdout_summary: summarizeOutput(stdoutText),
    stderr_summary: summarizeOutput(stderrText)
  };

  const result: Result = {
    version: "1.0",
    request_id: plan.request_id,
    actions: [resultAction]
  };

  const planHash = await sha256File(planPath);
  const runnerHash = await sha256File(runScriptPath);

  const evidenceAction: EvidenceAction = normalizeEvidenceAction({
    id: localAction.id,
    executed_at: new Date().toISOString(),
    runner: `bash-run_action.sh@${runnerHash}`,
    command,
    cwd: process.cwd(),
    uid: uidOrNull(),
    gid: gidOrNull(),
    sanitized_env: localAction.env,
    timeout_sec: localAction.timeout_sec,
    exit_code: exitCode,
    stdout_path: stdoutPath,
    stderr_path: stderrPath,
    stdout_hash: stdoutHash,
    stderr_hash: stderrHash,
    inputs_hash: planHash,
    outputs_hash: buildOutputsHash(resultAction)
  });

  const evidence: Evidence = {
    version: "1.0",
    request_id: plan.request_id,
    actions: [evidenceAction],
    platform: {
      node: process.version,
      os: process.platform,
      arch: process.arch
    }
  };

  await writeFile(resolve(outDir, "result.json"), `${JSON.stringify(result, null, 2)}\n`, "utf8");
  await writeFile(resolve(outDir, "evidence.json"), `${JSON.stringify(evidence, null, 2)}\n`, "utf8");

  return { result, evidence, violations: [] };
}
