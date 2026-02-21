# webgame-ref-mcp

MCP server for collecting web/mobile-web game UI references.

## Scope

- Search references for browser and mobile-web game UX benchmarking.
- Build a compact benchmark sheet from selected URLs.

## Tools

### `search_webgame_references`

Input:

- `query` (string, required)
- `platform` (`web` | `mobile-web` | `both`, default `both`)
- `limit` (1..20, default `8`)
- `include_images` (boolean, default `true`)
- `language` (string, default `en`)

Output:

- list of references with title, url, domain, snippet, platform tag, optional OG image.

### `build_webgame_benchmark_sheet`

Input:

- `urls` (string array, required, max 20)

Output:

- normalized benchmark rows:
  - `title`
  - `description`
  - `og_image`
  - `core_loop_guess`
  - `ftue_complexity`
  - `interaction_density`
  - `mobile_touch_readiness`

### `score_webgame_references`

Input:

- `items` (array, required)
  - each item: `title`, `url`, optional `domain`, `snippet`, `platform_tag`, `og_image`
- `weights` (object, optional)
  - `hook`, `interaction`, `mobile`, `monetization`, `novelty`

Output:

- scored and ranked rows:
  - `composite_score` (0..100)
  - `score_breakdown` (`hook`, `interaction`, `mobile`, `monetization`, `novelty`)
  - `why` (human-readable reasons)
  - `provenance` (`source_url`, `analyzed_at_utc`, `reference_notes`)
  - `recommended_for_step`
    - `ftue_0_60s`
    - `session_loop_depth`
  - `light_spend_testing`

### `vision_review_webgame_images`

Input:

- `image_urls` (array, required, max 8)
- `context` (string, optional)
- `model` (string, optional)

Output:

- per-image vision review rows:
  - `silhouette_score`
  - `readability_score`
  - `motion_score`
  - `mood_coherence_score`
  - `overall_score`
  - `findings`
  - `high_priority_fixes`

Environment:

- Requires `OPENAI_API_KEY`.
- Optional model override via `OPENAI_VISION_MODEL`.
- Default vision model baseline: `gpt-5-nano`.
- Explicit higher-model override is allowed (`gpt-5-mini`, `gpt-5`, etc.). Baseline is not a hard block.

### `audit_model_policy_drift`

Input:

- `root_path` (string, optional)
- `baseline_model` (string, optional, default `gpt-5-nano`)
- `forbidden_models` (string array, optional, default `["gpt-4.1-mini"]`)

Output:

- `violations` rows with:
  - `file_path`
  - `line`
  - `model`
  - `excerpt`

### `audit_market_launch_readiness`

Input:

- `project_root` (string, optional, default current directory)

Output:

- `overall_score` (0..100)
- `launch_decision` (`GO` | `GO_WITH_GATES` | `NO_GO`)
- `criteria` rows:
  - `key`
  - `title`
  - `status`
  - `score`
  - `evidence`
  - `impact`
  - `next_check`
- `critical_blockers`

## Run

From repository root:

```bash
go run ./control-plane/go/cmd/webgame-ref-mcp
```

Or build first:

```bash
go build -o out/webgame-ref-mcp ./control-plane/go/cmd/webgame-ref-mcp
./out/webgame-ref-mcp
```

## Example MCP Client Registration

```json
{
  "mcpServers": {
    "webgame-reference": {
      "command": "go",
      "args": [
        "run",
        "./control-plane/go/cmd/webgame-ref-mcp"
      ],
      "cwd": "/Users/wonyoung_choi/ai-governance"
    }
  }
}
```
