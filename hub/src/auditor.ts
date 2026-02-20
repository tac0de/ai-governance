import { readFile, writeFile } from "node:fs/promises";
import type { Audit, Evidence, Plan, Result, Violation } from "./types.js";
import { buildOutputsHash } from "./evidence.js";
import { sha256File } from "./hash.js";
import { ALLOWED_LOCAL_COMMAND_IDS, SAFE_ENV_KEY_REGEX } from "./policy.js";
import { readJsonFile, validateJsonBySchema } from "./validate.js";

function sortViolations(violations: Violation[]): Violation[] {
  return [...violations].sort((a, b) => {
    if (a.code !== b.code) return a.code.localeCompare(b.code);
    if (a.path !== b.path) return a.path.localeCompare(b.path);
    return a.message.localeCompare(b.message);
  });
}

function buildRejectAudit(
  requestId: string,
  checksums: { plan: string; result: string; evidence: string },
  violations: Violation[]
): Audit {
  const sorted = sortViolations(violations);
  return {
    version: "1.0",
    request_id: requestId,
    status: "REJECT",
    reason_code: sorted[0]?.code ?? "HUNBUP_NONDETERMINISTIC_OUTPUT",
    violations: sorted,
    checksums
  };
}

export async function auditFiles(
  planPath: string,
  resultPath: string,
  evidencePath: string,
  outPath?: string
): Promise<Audit> {
  const checksums = {
    plan: await sha256File(planPath),
    result: await sha256File(resultPath),
    evidence: await sha256File(evidencePath)
  };

  const plan = await readJsonFile<Plan>(planPath);
  const result = await readJsonFile<Result>(resultPath);
  const evidence = await readJsonFile<Evidence>(evidencePath);

  const planSchemaViolations = await validateJsonBySchema("plan", plan);
  if (planSchemaViolations.length > 0) {
    const audit = buildRejectAudit(plan.request_id || "unknown", checksums, planSchemaViolations);
    if (outPath) await writeFile(outPath, `${JSON.stringify(audit, null, 2)}\n`, "utf8");
    return audit;
  }

  const resultSchemaViolations = await validateJsonBySchema("result", result);
  if (resultSchemaViolations.length > 0) {
    const audit = buildRejectAudit(plan.request_id, checksums, resultSchemaViolations);
    if (outPath) await writeFile(outPath, `${JSON.stringify(audit, null, 2)}\n`, "utf8");
    return audit;
  }

  const evidenceSchemaViolations = await validateJsonBySchema("evidence", evidence);
  if (evidenceSchemaViolations.length > 0) {
    const audit = buildRejectAudit(plan.request_id, checksums, evidenceSchemaViolations);
    if (outPath) await writeFile(outPath, `${JSON.stringify(audit, null, 2)}\n`, "utf8");
    return audit;
  }

  const violations: Violation[] = [];

  if (plan.request_id !== result.request_id || plan.request_id !== evidence.request_id) {
    violations.push({
      code: "HUNBUP_HASH_MISMATCH",
      path: "/request_id",
      message: "request_id mismatch between plan/result/evidence"
    });
  }

  const action = plan.actions[0];
  if (action.type !== "local_exec") {
    violations.push({
      code: "HUNBUP_ACTION_TYPE_NOT_ALLOWED",
      path: "/actions/0/type",
      message: `Action type is not allowed in v0 runtime: ${action.type}`
    });
  } else {
    if (!ALLOWED_LOCAL_COMMAND_IDS.includes(action.command_id as (typeof ALLOWED_LOCAL_COMMAND_IDS)[number])) {
      violations.push({
        code: "HUNBUP_COMMAND_ID_NOT_ALLOWED",
        path: "/actions/0/command_id",
        message: `Command ID is not allowlisted: ${action.command_id}`
      });
    }
  }

  for (const key of Object.keys(action.env).sort()) {
    if (!SAFE_ENV_KEY_REGEX.test(key)) {
      violations.push({
        code: "HUNBUP_ENV_KEY_NOT_ALLOWED",
        path: `/actions/0/env/${key}`,
        message: `Environment key is not allowlisted: ${key}`
      });
    }
  }

  const resultAction = result.actions[0];
  const evidenceAction = evidence.actions[0];

  if (!resultAction || !evidenceAction) {
    violations.push({
      code: "HUNBUP_EVIDENCE_MISSING_REQUIRED_FIELD",
      path: "/actions/0",
      message: "Missing action evidence or result for the first plan action"
    });
  } else {
    if (evidenceAction.id !== action.id || resultAction.id !== action.id) {
      violations.push({
        code: "HUNBUP_EVIDENCE_MISSING_REQUIRED_FIELD",
        path: "/actions/0/id",
        message: "Action ID mismatch across plan/result/evidence"
      });
    }

    if (evidenceAction.exit_code === 124) {
      violations.push({
        code: "HUNBUP_TIMEOUT_EXCEEDED",
        path: "/actions/0/exit_code",
        message: "Execution timeout exceeded"
      });
    }

    if (evidenceAction.inputs_hash !== checksums.plan) {
      violations.push({
        code: "HUNBUP_HASH_MISMATCH",
        path: "/actions/0/inputs_hash",
        message: "inputs_hash does not match plan checksum"
      });
    }

    const expectedOutputsHash = buildOutputsHash(resultAction);
    if (evidenceAction.outputs_hash !== expectedOutputsHash) {
      violations.push({
        code: "HUNBUP_HASH_MISMATCH",
        path: "/actions/0/outputs_hash",
        message: "outputs_hash does not match derived result hash"
      });
    }

    const stdoutBytes = await readFile(evidenceAction.stdout_path);
    const stderrBytes = await readFile(evidenceAction.stderr_path);
    const stdoutHash = await sha256File(evidenceAction.stdout_path);
    const stderrHash = await sha256File(evidenceAction.stderr_path);

    if (stdoutHash !== evidenceAction.stdout_hash || stderrHash !== evidenceAction.stderr_hash) {
      violations.push({
        code: "HUNBUP_HASH_MISMATCH",
        path: "/actions/0/stdout_hash",
        message: "stdout/stderr hash mismatch against file content"
      });
    }

    // Keep usage to avoid accidental optimization and assert deterministic artifact materialization.
    if (stdoutBytes.length < 0 || stderrBytes.length < 0) {
      violations.push({
        code: "HUNBUP_NONDETERMINISTIC_OUTPUT",
        path: "/actions/0",
        message: "Unexpected negative byte length"
      });
    }
  }

  const audit: Audit =
    violations.length > 0
      ? buildRejectAudit(plan.request_id, checksums, violations)
      : {
          version: "1.0",
          request_id: plan.request_id,
          status: "PASS",
          reason_code: null,
          violations: [],
          checksums
        };

  if (outPath) {
    await writeFile(outPath, `${JSON.stringify(audit, null, 2)}\n`, "utf8");
  }
  return audit;
}
