#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

function parseArgs(argv) {
  const args = {
    repo: ".",
    outJson: "",
  };

  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (token === "--repo") args.repo = argv[++i] || ".";
    else if (token === "--out-json") args.outJson = argv[++i] || "";
    else if (token === "--help" || token === "-h") args.help = true;
    else throw new Error(`Unknown argument: ${token}`);
  }

  return args;
}

function readIfExists(filePath) {
  if (!fs.existsSync(filePath)) return null;
  return fs.readFileSync(filePath, "utf8");
}

function writeIfChanged(filePath, nextContent) {
  const prev = readIfExists(filePath);
  if (prev === null) return false;
  if (prev === nextContent) return false;
  fs.writeFileSync(filePath, nextContent, "utf8");
  return true;
}

function injectBeforeHeadClose(html, block) {
  if (html.includes("ai-governance:auto-seo-v1:start")) return { content: html, touched: false };
  const closeHead = html.match(/<\/head>/i);
  if (!closeHead) return { content: html, touched: false };
  const next = html.replace(/<\/head>/i, `${block}\n</head>`);
  return { content: next, touched: true };
}

function appendIfMissing(css, block) {
  if (css.includes("ai-governance:auto-a11y-v1:start")) return { content: css, touched: false };
  const separator = css.endsWith("\n") ? "" : "\n";
  return { content: `${css}${separator}\n${block}\n`, touched: true };
}

function injectSeoV2(html) {
  if (html.includes("ai-governance:auto-seo-v2:start")) return { content: html, touched: false };
  const closeHead = html.match(/<\/head>/i);
  if (!closeHead) return { content: html, touched: false };
  const block = [
    "  <!-- ai-governance:auto-seo-v2:start -->",
    '  <meta name="theme-color" content="#111827">',
    '  <meta name="color-scheme" content="dark light">',
    "  <!-- ai-governance:auto-seo-v2:end -->",
  ].join("\n");
  return { content: html.replace(/<\/head>/i, `${block}\n</head>`), touched: true };
}

function appendA11yV2(css) {
  if (css.includes("ai-governance:auto-a11y-v2:start")) return { content: css, touched: false };
  const block = [
    "/* ai-governance:auto-a11y-v2:start */",
    "button,",
    "a,",
    "input,",
    "select,",
    "textarea {",
    "  touch-action: manipulation;",
    "}",
    "/* ai-governance:auto-a11y-v2:end */",
  ].join("\n");
  const separator = css.endsWith("\n") ? "" : "\n";
  return { content: `${css}${separator}\n${block}\n`, touched: true };
}

function run() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    console.log("Usage: node tools/personal_gallery_autofix.js --repo <path> [--out-json <path>]");
    process.exit(0);
  }

  const repoRoot = path.resolve(args.repo);
  const indexPath = path.join(repoRoot, "index.html");
  const stylePath = path.join(repoRoot, "style.css");

  const changes = [];

  const indexContent = readIfExists(indexPath);
  if (indexContent !== null) {
    const seoBlock = [
      "  <!-- ai-governance:auto-seo-v1:start -->",
      '  <meta name="description" content="Personal art gallery with curated originals, story-driven flow, and multilingual support.">',
      '  <meta name="robots" content="index,follow">',
      '  <meta property="og:type" content="website">',
      '  <meta property="og:title" content="Personal Art Gallery">',
      '  <meta property="og:description" content="Curated originals with mission-based engagement loop and auto locale support.">',
      '  <meta name="twitter:card" content="summary_large_image">',
      "  <!-- ai-governance:auto-seo-v1:end -->",
    ].join("\n");

    const seoInjected = injectBeforeHeadClose(indexContent, seoBlock);
    if (seoInjected.touched && writeIfChanged(indexPath, seoInjected.content)) {
      changes.push({
        file: "index.html",
        change: "seo_hardening",
        detail: "Added idempotent SEO/social meta block in <head>.",
      });
    }

    const indexAfterV1 = readIfExists(indexPath);
    if (indexAfterV1 !== null) {
      const seoV2Injected = injectSeoV2(indexAfterV1);
      if (seoV2Injected.touched && writeIfChanged(indexPath, seoV2Injected.content)) {
        changes.push({
          file: "index.html",
          change: "seo_hardening_v2",
          detail: "Added theme-color and color-scheme meta block.",
        });
      }
    }
  }

  const styleContent = readIfExists(stylePath);
  if (styleContent !== null) {
    const a11yBlock = [
      "/* ai-governance:auto-a11y-v1:start */",
      ":focus-visible {",
      "  outline: 3px solid #0ea5e9;",
      "  outline-offset: 2px;",
      "}",
      "",
      "@media (prefers-reduced-motion: reduce) {",
      "  *,",
      "  *::before,",
      "  *::after {",
      "    animation-duration: 0.01ms !important;",
      "    animation-iteration-count: 1 !important;",
      "    transition-duration: 0.01ms !important;",
      "    scroll-behavior: auto !important;",
      "  }",
      "}",
      "/* ai-governance:auto-a11y-v1:end */",
    ].join("\n");

    const a11yInjected = appendIfMissing(styleContent, a11yBlock);
    if (a11yInjected.touched && writeIfChanged(stylePath, a11yInjected.content)) {
      changes.push({
        file: "style.css",
        change: "a11y_hardening",
        detail: "Added focus-visible and reduced-motion guard block.",
      });
    }

    const styleAfterV1 = readIfExists(stylePath);
    if (styleAfterV1 !== null) {
      const a11yV2Injected = appendA11yV2(styleAfterV1);
      if (a11yV2Injected.touched && writeIfChanged(stylePath, a11yV2Injected.content)) {
        changes.push({
          file: "style.css",
          change: "a11y_hardening_v2",
          detail: "Added mobile interaction touch-action normalization.",
        });
      }
    }
  }

  const result = {
    generated_at: new Date().toISOString(),
    repo: repoRoot,
    changed: changes.length > 0,
    changes,
    macro_direction_if_budget_exhausted: [
      "Freeze auto-push for the rest of UTC day and collect user behavior signals.",
      "Prioritize one UX flow to validate tomorrow (navigation, locale switch, mission loop).",
      "Queue only low-risk hardening patches for next cycle.",
    ],
  };

  if (args.outJson) {
    const outPath = path.resolve(args.outJson);
    fs.mkdirSync(path.dirname(outPath), { recursive: true });
    fs.writeFileSync(outPath, JSON.stringify(result, null, 2), "utf8");
  }

  process.stdout.write(`${JSON.stringify(result)}\n`);
}

run();
