import type { LocalExecAction, ReasonCode } from "./types.js";

export const ALLOWED_LOCAL_COMMAND_IDS = ["ECHO", "RUN_NODE_VERSION"] as const;
export const SAFE_ENV_KEY_REGEX = /^SAFE_[A-Z0-9_]+$/;

export class PolicyError extends Error {
  public readonly code: ReasonCode;
  public readonly path: string;

  constructor(code: ReasonCode, path: string, message: string) {
    super(message);
    this.code = code;
    this.path = path;
  }
}

export function ensureSafeEnv(env: Record<string, string>, actionPath: string): void {
  for (const key of Object.keys(env).sort()) {
    if (!SAFE_ENV_KEY_REGEX.test(key)) {
      throw new PolicyError(
        "HUNBUP_ENV_KEY_NOT_ALLOWED",
        `${actionPath}/env/${key}`,
        `Environment key is not allowlisted: ${key}`
      );
    }
  }
}

export function resolveLocalCommand(action: LocalExecAction, actionPath: string): string[] {
  const commandId = action.command_id;
  if (!ALLOWED_LOCAL_COMMAND_IDS.includes(commandId as (typeof ALLOWED_LOCAL_COMMAND_IDS)[number])) {
    throw new PolicyError(
      "HUNBUP_COMMAND_ID_NOT_ALLOWED",
      `${actionPath}/command_id`,
      `Command ID is not allowlisted: ${commandId}`
    );
  }

  if (commandId === "ECHO") {
    return ["/bin/echo", ...action.args];
  }

  return ["node", "--version", ...action.args];
}
