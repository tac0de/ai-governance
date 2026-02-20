export type ReasonCode =
  | "HUNBUP_PLAN_SCHEMA_INVALID"
  | "HUNBUP_RESULT_SCHEMA_INVALID"
  | "HUNBUP_EVIDENCE_SCHEMA_INVALID"
  | "HUNBUP_ACTION_TYPE_NOT_ALLOWED"
  | "HUNBUP_COMMAND_ID_NOT_ALLOWED"
  | "HUNBUP_ENV_KEY_NOT_ALLOWED"
  | "HUNBUP_TIMEOUT_EXCEEDED"
  | "HUNBUP_EVIDENCE_MISSING_REQUIRED_FIELD"
  | "HUNBUP_HASH_MISMATCH"
  | "HUNBUP_NONDETERMINISTIC_OUTPUT";

export interface Violation {
  code: ReasonCode;
  path: string;
  message: string;
}

export type ActionType = "local_exec" | "container_run";

export interface LocalExecAction {
  id: string;
  type: "local_exec";
  command_id: "ECHO" | "RUN_NODE_VERSION" | string;
  args: string[];
  timeout_sec: number;
  env: Record<string, string>;
}

export interface ContainerRunAction {
  id: string;
  type: "container_run";
  image_digest: string;
  entrypoint: string[];
  args: string[];
  timeout_sec: number;
  env: Record<string, string>;
}

export type PlanAction = LocalExecAction | ContainerRunAction;

export interface Plan {
  version: "1.0";
  request_id: string;
  actions: PlanAction[];
}

export interface ResultAction {
  id: string;
  status: "ok" | "error";
  artifacts: Array<{ path: string; sha256: string }>;
  stdout_summary: string;
  stderr_summary: string;
}

export interface Result {
  version: "1.0";
  request_id: string;
  actions: ResultAction[];
}

export interface EvidenceAction {
  id: string;
  executed_at: string;
  runner: string;
  command: string[];
  cwd: string;
  uid: number | null;
  gid: number | null;
  sanitized_env: Record<string, string>;
  timeout_sec: number;
  exit_code: number;
  stdout_path: string;
  stderr_path: string;
  stdout_hash: string;
  stderr_hash: string;
  inputs_hash: string;
  outputs_hash: string;
}

export interface Evidence {
  version: "1.0";
  request_id: string;
  actions: EvidenceAction[];
  platform: {
    node: string;
    os: string;
    arch: string;
  };
}

export interface Audit {
  version: "1.0";
  request_id: string;
  status: "PASS" | "REJECT";
  reason_code: ReasonCode | null;
  violations: Violation[];
  checksums: {
    plan: string;
    result: string;
    evidence: string;
  };
}
