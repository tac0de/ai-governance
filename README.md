# ai-governance

`ai-governance` is a governance-first repository with a deterministic v0 runtime module.

## Repository Layout
- `constitution/`: single source of normative rules
  - JSON schemas (`plan`, `result`, `evidence`, `audit`)
  - fixed `reason_code` catalog
  - deterministic test vectors
- `hub/`: TypeScript (Node 20+) runtime
  - `validate`: validate `plan.json`
  - `run`: execute single-action plan and emit `result.json` + `evidence.json`
  - `audit`: deterministic PASS/REJECT with fixed `reason_code`

## v0 Principles
- Deterministic audit result for equivalent inputs.
- Schema-first validation.
- Single-action execution in v0.
- `local_exec` supported; `container_run` allowed in schema but rejected by audit policy in v0.

## Quick Start
```bash
cd hub
npm install
npm run build

# validate
node dist/index.js validate --plan ../constitution/cases/pass/case001.plan.json

# run
node dist/index.js run --plan ../constitution/cases/pass/case001.plan.json --outdir ../out/case001

# audit
node dist/index.js audit \
  --plan ../constitution/cases/pass/case001.plan.json \
  --result ../out/case001/result.json \
  --evidence ../out/case001/evidence.json \
  --out ../out/case001/audit.json
```

## Security Baseline
- Do not commit `.env` or secrets.
- Use `.env.example` as template only.
- Run with minimum privilege and deterministic evidence output.
