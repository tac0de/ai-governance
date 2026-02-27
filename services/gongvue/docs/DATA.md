# DATA

## Data Contract Surface
- Objective text: `tmp/pm_objective_*.txt`
- Intent artifact: `tmp/*.intent.local.json`
- MCP request: `traces/governance/mcp-request-*.json`
- Trace records: `traces/bridge/*`

## Evidence Policy
- 모든 증빙 참조는 repo-relative path + `sha256`를 사용한다.
- wall-clock/random/network 의존은 verdict 경로에 포함하지 않는다.

## Retention Notes
- 장기 운영 로그는 `obsidian-mcp`로 이관하고, 코어에는 최소 trace만 남긴다.
- 임시 결과물은 `tmp/` hygiene 규칙을 따른다.
