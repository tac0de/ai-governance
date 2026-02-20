import { readFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";
import { auditFiles } from "../src/auditor.js";

const thisFile = fileURLToPath(import.meta.url);
const repoRoot = resolve(dirname(thisFile), "../..");
const cases = [
  { kind: "pass", id: "case001" },
  { kind: "reject", id: "case101" },
  { kind: "reject", id: "case102" }
] as const;

describe("constitution case audits", () => {
  for (const testCase of cases) {
    it(`${testCase.kind}/${testCase.id} matches expected audit`, async () => {
      const base = resolve(repoRoot, "constitution", "cases", testCase.kind, testCase.id);
      const planPath = `${base}.plan.json`;
      const resultPath = `${base}.result.json`;
      const evidencePath = `${base}.evidence.json`;
      const expectedPath = `${base}.expected.audit.json`;

      const expected = JSON.parse(await readFile(expectedPath, "utf8"));
      const actual = await auditFiles(planPath, resultPath, evidencePath);

      expect(actual).toEqual(expected);
    });
  }
});
