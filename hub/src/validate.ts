import { readFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { default as Ajv2020 } from "ajv/dist/2020.js";
import type { ErrorObject } from "ajv";
import addFormats from "ajv-formats";
import type { ReasonCode, Violation } from "./types.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const schemaDir = resolve(__dirname, "../../constitution/schemas");

export type SchemaKind = "plan" | "result" | "evidence" | "audit";

const reasonBySchema: Record<SchemaKind, ReasonCode> = {
  plan: "HUNBUP_PLAN_SCHEMA_INVALID",
  result: "HUNBUP_RESULT_SCHEMA_INVALID",
  evidence: "HUNBUP_EVIDENCE_SCHEMA_INVALID",
  audit: "HUNBUP_EVIDENCE_SCHEMA_INVALID"
};

const schemaFileByKind: Record<SchemaKind, string> = {
  plan: "plan.schema.json",
  result: "result.schema.json",
  evidence: "evidence.schema.json",
  audit: "audit.schema.json"
};

type CompiledValidator = ((data: unknown) => boolean) & { errors?: ErrorObject[] | null };
const AjvCtor = Ajv2020 as unknown as new (opts: { allErrors: boolean; strict: boolean }) => {
  compile: (schema: unknown) => CompiledValidator;
};
const addFormatsFn = addFormats as unknown as (ajvInstance: unknown) => void;
const ajv = new AjvCtor({ allErrors: true, strict: false });
addFormatsFn(ajv);
const validatorCache = new Map<SchemaKind, CompiledValidator>();

async function loadSchema(kind: SchemaKind): Promise<unknown> {
  const path = resolve(schemaDir, schemaFileByKind[kind]);
  const raw = await readFile(path, "utf8");
  return JSON.parse(raw);
}

function toViolations(kind: SchemaKind, errors: ErrorObject[] | null | undefined): Violation[] {
  const code = reasonBySchema[kind];
  return [...(errors ?? [])]
    .map((error) => ({
      code,
      path: error.instancePath || "/",
      message: `schema:${error.keyword}`
    }))
    .sort((a, b) => {
      if (a.path !== b.path) return a.path.localeCompare(b.path);
      return a.message.localeCompare(b.message);
    });
}

export async function validateJsonBySchema(kind: SchemaKind, data: unknown): Promise<Violation[]> {
  let validate = validatorCache.get(kind);
  if (!validate) {
    const schema = await loadSchema(kind);
    validate = ajv.compile(schema);
    validatorCache.set(kind, validate);
  }
  const ok = validate(data);
  return ok ? [] : toViolations(kind, validate.errors);
}

export async function readJsonFile<T>(path: string): Promise<T> {
  const raw = await readFile(path, "utf8");
  return JSON.parse(raw) as T;
}
