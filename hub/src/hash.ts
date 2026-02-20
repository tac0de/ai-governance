import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";

function stableSort(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map(stableSort);
  }
  if (value && typeof value === "object") {
    const src = value as Record<string, unknown>;
    const out: Record<string, unknown> = {};
    for (const key of Object.keys(src).sort()) {
      out[key] = stableSort(src[key]);
    }
    return out;
  }
  return value;
}

export function stableStringify(value: unknown): string {
  return JSON.stringify(stableSort(value));
}

export function sha256FromBuffer(input: Buffer): string {
  return createHash("sha256").update(input).digest("hex");
}

export function sha256FromString(input: string): string {
  return createHash("sha256").update(input, "utf8").digest("hex");
}

export async function sha256File(path: string): Promise<string> {
  const data = await readFile(path);
  return sha256FromBuffer(data);
}

export function sha256Json(value: unknown): string {
  return sha256FromString(stableStringify(value));
}
