# Multi-Model Image Governance Contract v0.1

## Objective
- Add centralized governance for model-orchestrated image generation pipelines (SDXL + LoRA composition) without embedding runtime implementation in governance core.

## Operating Model
- Runtime execution: external service repos only.
- Governance core responsibility:
  - model-policy contracts
  - prompt/provenance evidence schema
  - deterministic batch verification and approval routing

## Minimal Capability Set
- `image.route_profile`: choose model/profile by policy tier.
- `image.compose_lora_stack`: validate LoRA stack constraints.
- `image.generate_batch`: produce artifact manifest + hashes.
- `image.verify_policy`: enforce safety/style/license checks.

## Determinism and Quality Controls
- Fixed seed policy by run mode (`strict`, `hybrid`, `creative`).
- Canonical prompt template refs with immutable hash pins.
- Output manifest with artifact hash and model lineage.
- Replay gate for same input/profile producing policy-equivalent verdict.

## Governance Bindings
- Every generation request must include intent id, risk tier, and evidence refs.
- High-tier routes require mandatory human gate.
- Output acceptance requires schema pass + policy pass + artifact integrity pass.
