# Personal Gallery Auto Push Workflow

## Purpose
Run low-risk automatic updates on `tac0de/personal-art-gallery` with direct push enabled, while enforcing a strict daily push budget.

## Workflow
- Reusable file in ai-governance: `.github/workflows/reusable-personal-gallery-auto-push.yml`
- Caller wrapper in target repo: `.github/workflows/personal-gallery-auto-push.yml`
- Trigger ownership: target repo wrapper owns schedule (`cron: 47 */6 * * *`) + manual run
- Target branch: `main`
- Daily limit: `AUTO_PUSH_DAILY_LIMIT` (default `2`, UTC day)

## Behavior
1. Read/create state issue: `[gallery-autopush] personal-art-gallery auto push state`
2. If daily budget remains:
   - clone target repo with `REPO_ACCESS_TOKEN`
   - run `ai-governance/tools/personal_gallery_autofix.js` from reusable workflow
   - commit and push directly when changes exist
3. If budget is exhausted:
   - stop pushing for the day
   - post one macro-direction comment for next cycle

## Low-risk patch scope
- `index.html`: add idempotent SEO/social meta block
- `style.css`: add `:focus-visible` and reduced-motion guard

## Required secret
- `REPO_ACCESS_TOKEN` with write access to `tac0de/personal-art-gallery`
