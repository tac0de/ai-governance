import type { EvidenceAction, ResultAction } from "./types.js";
import { sha256Json } from "./hash.js";

export function summarizeOutput(text: string): string {
  const clean = text.replace(/\r\n/g, "\n").trim();
  if (!clean) return "";
  return clean.length > 240 ? `${clean.slice(0, 240)}...` : clean;
}

export function buildOutputsHash(resultAction: ResultAction): string {
  return sha256Json({
    id: resultAction.id,
    status: resultAction.status,
    artifacts: resultAction.artifacts
  });
}

export function normalizeEvidenceAction(action: EvidenceAction): EvidenceAction {
  return {
    ...action,
    command: [...action.command],
    sanitized_env: Object.fromEntries(Object.entries(action.sanitized_env).sort(([a], [b]) => a.localeCompare(b)))
  };
}
