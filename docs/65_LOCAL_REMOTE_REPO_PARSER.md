# Local + Remote Repo Parser

## Purpose
Generate one deterministic snapshot that combines:
- local git state (working tree, head commit, remotes)
- remote GitHub state (branch head, changed files, UI/UX surface hints)
- one recommended next action (`A|B|C`)

## Command
```bash
node tools/repo_parser.js
```

## Main options
```bash
node tools/repo_parser.js \
  --path . \
  --repo tac0de/personal-art-gallery \
  --branch main \
  --out-json .ops/repo_parse_report.json \
  --out-md .ops/repo_parse_report.md
```

- `--local-only`: skip remote GitHub lookup.
- `--strict`: fail immediately if remote lookup fails.

## Outputs
- JSON: `.ops/repo_parse_report.json`
- Markdown: `.ops/repo_parse_report.md`

## Requirements
- Local: `git`
- Remote: `gh` CLI auth (`gh auth status`)

## Recommendation logic
- `A`: quick monitor mode (no meaningful UI/UX change)
- `B`: UI visual check recommended when UI touch is detected
- `C`: UX flow review recommended when UX-flow touch is detected
