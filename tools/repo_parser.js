#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

function parseArgs(argv) {
  const args = {
    path: ".",
    repo: "",
    branch: "",
    localOnly: false,
    strict: false,
    outJson: ".ops/repo_parse_report.json",
    outMd: ".ops/repo_parse_report.md",
  };

  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (token === "--path") args.path = argv[++i] || ".";
    else if (token === "--repo") args.repo = argv[++i] || "";
    else if (token === "--branch") args.branch = argv[++i] || "";
    else if (token === "--out-json") args.outJson = argv[++i] || args.outJson;
    else if (token === "--out-md") args.outMd = argv[++i] || args.outMd;
    else if (token === "--local-only") args.localOnly = true;
    else if (token === "--strict") args.strict = true;
    else if (token === "--help" || token === "-h") args.help = true;
    else throw new Error(`Unknown argument: ${token}`);
  }

  return args;
}

function run(cmd, cmdArgs, cwd, optional = false) {
  const out = spawnSync(cmd, cmdArgs, {
    cwd,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  });

  if (out.error) {
    if (optional) return { ok: false, code: 1, stdout: "", stderr: String(out.error.message || out.error) };
    throw out.error;
  }

  const result = {
    ok: out.status === 0,
    code: out.status || 0,
    stdout: String(out.stdout || "").trim(),
    stderr: String(out.stderr || "").trim(),
  };

  if (!result.ok && !optional) {
    throw new Error(`${cmd} ${cmdArgs.join(" ")} failed: ${result.stderr || `exit ${result.code}`}`);
  }
  return result;
}

function parseGitHubRepo(remoteUrl) {
  const url = String(remoteUrl || "").trim();
  const ssh = url.match(/^git@github\.com:([^/]+)\/(.+?)(?:\.git)?$/i);
  if (ssh) return `${ssh[1]}/${ssh[2]}`;

  const https = url.match(/^https?:\/\/github\.com\/([^/]+)\/(.+?)(?:\.git)?$/i);
  if (https) return `${https[1]}/${https[2]}`;

  return "";
}

function firstLine(text) {
  return String(text || "").split("\n")[0].trim();
}

function classifySurface(filePath) {
  const p = String(filePath || "").toLowerCase();
  const uiPattern =
    /(^|\/)(app|pages|components|ui|styles?|theme|layout|public|assets)(\/|$)|\.(css|scss|sass|less|svg|png|jpg|jpeg|webp)$/i;
  const uxPattern =
    /(^|\/)(routes?|navigation|nav|flow|state|hooks?|forms?|auth|checkout|onboarding|interaction|a11y|accessibility|api|services?)(\/|$)/i;

  return {
    ui: uiPattern.test(p),
    ux: uxPattern.test(p),
  };
}

function buildRecommendations(uiChanged, uxChanged) {
  const options = [
    {
      code: "A",
      title: "Quick monitor mode",
      description: "Keep release as-is and monitor next 24h feedback only.",
    },
    {
      code: "B",
      title: "UI visual check",
      description: "Run screenshot diff and adjust layout/visual hierarchy if drift exists.",
    },
    {
      code: "C",
      title: "UX flow review",
      description: "Review key task flow before next publish (navigation/form/interaction).",
    },
  ];

  let recommended = "A";
  if (uxChanged) recommended = "C";
  else if (uiChanged) recommended = "B";

  return { options, recommended };
}

function getLocalSnapshot(repoPath) {
  const resolvedPath = path.resolve(repoPath);
  const inRepo = run("git", ["rev-parse", "--is-inside-work-tree"], resolvedPath, true);
  if (!inRepo.ok || inRepo.stdout !== "true") {
    throw new Error(`Not a git repository: ${resolvedPath}`);
  }

  const topLevel = run("git", ["rev-parse", "--show-toplevel"], resolvedPath).stdout;
  const branch = run("git", ["rev-parse", "--abbrev-ref", "HEAD"], resolvedPath, true).stdout || "detached";
  const headSha = run("git", ["rev-parse", "HEAD"], resolvedPath).stdout;
  const headShort = run("git", ["rev-parse", "--short", "HEAD"], resolvedPath).stdout;
  const headMeta = run("git", ["show", "-s", "--format=%cI%n%s", "HEAD"], resolvedPath).stdout.split("\n");
  const commitDate = headMeta[0] || "";
  const commitMessage = firstLine(headMeta.slice(1).join("\n"));

  const statusLines = run("git", ["status", "--porcelain"], resolvedPath).stdout
    .split("\n")
    .map((line) => line.trimEnd())
    .filter(Boolean);
  const changedFiles = statusLines.length;
  const untrackedFiles = statusLines.filter((line) => line.startsWith("??")).length;
  const stagedFiles = statusLines.filter((line) => !line.startsWith("??") && line[0] !== " ").length;

  const remoteRaw = run("git", ["remote", "-v"], resolvedPath, true).stdout;
  const remoteMap = {};
  for (const row of remoteRaw.split("\n").map((v) => v.trim()).filter(Boolean)) {
    const m = row.match(/^([^\s]+)\s+([^\s]+)\s+\((fetch|push)\)$/);
    if (!m) continue;
    const name = m[1];
    const url = m[2];
    const kind = m[3];
    if (!remoteMap[name]) remoteMap[name] = {};
    remoteMap[name][kind] = url;
  }

  const originFetch = remoteMap.origin ? remoteMap.origin.fetch || "" : "";
  const parsedRepo = parseGitHubRepo(originFetch);

  return {
    path: topLevel,
    name: path.basename(topLevel),
    branch,
    head_sha: headSha,
    head_short: headShort,
    head_commit_date: commitDate,
    head_commit_message: commitMessage,
    working_tree: {
      changed_files: changedFiles,
      staged_files: stagedFiles,
      untracked_files: untrackedFiles,
      clean: changedFiles === 0,
    },
    remotes: remoteMap,
    inferred_github_repo: parsedRepo,
  };
}

function ghApi(ghArgs, cwd, optional = false) {
  return run("gh", ["api", ...ghArgs], cwd, optional);
}

function getRemoteSnapshot(repoFullName, preferredBranch, cwd, strictMode) {
  const hasGh = run("gh", ["--version"], cwd, true);
  if (!hasGh.ok) {
    const message = "gh CLI is not available";
    if (strictMode) throw new Error(message);
    return { ok: false, error: message };
  }

  const repoResp = ghApi([`repos/${repoFullName}`], cwd, !strictMode);
  if (!repoResp.ok) {
    const message = `Cannot read remote repo metadata: ${repoResp.stderr || repoResp.stdout}`;
    if (strictMode) throw new Error(message);
    return { ok: false, error: message };
  }
  const repoData = JSON.parse(repoResp.stdout);
  const defaultBranch = repoData.default_branch || "main";
  const targetBranch = preferredBranch || defaultBranch;

  const commitResp = ghApi([`repos/${repoFullName}/commits/${targetBranch}`], cwd, !strictMode);
  if (!commitResp.ok) {
    const message = `Cannot read branch head commit: ${commitResp.stderr || commitResp.stdout}`;
    if (strictMode) throw new Error(message);
    return {
      ok: false,
      error: message,
      repo: {
        full_name: repoData.full_name || repoFullName,
        private: Boolean(repoData.private),
        default_branch: defaultBranch,
      },
    };
  }

  const commitData = JSON.parse(commitResp.stdout);
  const files = Array.isArray(commitData.files)
    ? commitData.files.map((f) => ({
        path: String(f.filename || ""),
        status: String(f.status || "modified"),
        additions: Number(f.additions || 0),
        deletions: Number(f.deletions || 0),
      }))
    : [];

  let uiTouches = 0;
  let uxTouches = 0;
  for (const file of files) {
    const c = classifySurface(file.path);
    if (c.ui) uiTouches += 1;
    if (c.ux) uxTouches += 1;
  }

  const uiChanged = uiTouches > 0;
  const uxChanged = uxTouches > 0;
  const recommendations = buildRecommendations(uiChanged, uxChanged);

  return {
    ok: true,
    repo: {
      full_name: repoData.full_name || repoFullName,
      private: Boolean(repoData.private),
      default_branch: defaultBranch,
      target_branch: targetBranch,
      html_url: repoData.html_url || "",
    },
    latest_commit: {
      sha: String(commitData.sha || ""),
      short_sha: String(commitData.sha || "").slice(0, 7),
      date: commitData?.commit?.author?.date || commitData?.commit?.committer?.date || "",
      message: firstLine(commitData?.commit?.message),
      author: commitData?.author?.login || commitData?.commit?.author?.name || "unknown",
    },
    file_changes: files,
    ui_ux_summary: {
      ui_change_detected: uiChanged,
      ui_touch_count: uiTouches,
      ux_flow_change_detected: uxChanged,
      ux_touch_count: uxTouches,
    },
    recommendations,
  };
}

function writeFileSafe(targetPath, content) {
  const abs = path.resolve(targetPath);
  fs.mkdirSync(path.dirname(abs), { recursive: true });
  fs.writeFileSync(abs, content);
}

function formatMd(report) {
  const local = report.local;
  const remote = report.remote;
  const lines = [
    "# Repository Parse Report",
    "",
    `- generated_at: ${report.generated_at}`,
    `- mode: ${report.mode}`,
    "",
    "## Local snapshot",
    `- repo_path: ${local.path}`,
    `- repo_name: ${local.name}`,
    `- branch: ${local.branch}`,
    `- head: ${local.head_short}`,
    `- head_date: ${local.head_commit_date || "n/a"}`,
    `- head_message: ${local.head_commit_message || "n/a"}`,
    `- working_tree_clean: ${local.working_tree.clean ? "yes" : "no"}`,
    `- changed_files: ${local.working_tree.changed_files}`,
    `- staged_files: ${local.working_tree.staged_files}`,
    `- untracked_files: ${local.working_tree.untracked_files}`,
    "",
    "## Remote snapshot",
  ];

  if (!remote || !remote.ok) {
    lines.push(`- remote_status: unavailable (${remote && remote.error ? remote.error : "n/a"})`);
  } else {
    lines.push(`- repo: ${remote.repo.full_name}`);
    lines.push(`- branch: ${remote.repo.target_branch}`);
    lines.push(`- latest_commit: ${remote.latest_commit.short_sha}`);
    lines.push(`- latest_commit_date: ${remote.latest_commit.date || "n/a"}`);
    lines.push(`- latest_commit_message: ${remote.latest_commit.message || "n/a"}`);
    lines.push("");
    lines.push("## UI/UX summary");
    lines.push(`- ui_change_detected: ${remote.ui_ux_summary.ui_change_detected ? "yes" : "no"} (${remote.ui_ux_summary.ui_touch_count})`);
    lines.push(
      `- ux_flow_change_detected: ${remote.ui_ux_summary.ux_flow_change_detected ? "yes" : "no"} (${remote.ui_ux_summary.ux_touch_count})`
    );
    lines.push("");
    lines.push("## Recommended actions");
    for (const option of remote.recommendations.options) {
      const mark = option.code === remote.recommendations.recommended ? " (recommended)" : "";
      lines.push(`- ${option.code}${mark}: ${option.title} - ${option.description}`);
    }
  }

  return lines.join("\n");
}

function usage() {
  return [
    "Usage:",
    "  node tools/repo_parser.js [--path <repo_path>] [--repo <owner/name>]",
    "                            [--branch <branch>] [--local-only] [--strict]",
    "                            [--out-json <path>] [--out-md <path>]",
    "",
    "Examples:",
    "  node tools/repo_parser.js",
    "  node tools/repo_parser.js --repo tac0de/personal-art-gallery",
    "  node tools/repo_parser.js --local-only --out-md .ops/local_snapshot.md",
  ].join("\n");
}

function main() {
  let args;
  try {
    args = parseArgs(process.argv.slice(2));
  } catch (error) {
    console.error(`[repo-parser] ${error.message}`);
    console.error(usage());
    process.exit(1);
  }

  if (args.help) {
    console.log(usage());
    process.exit(0);
  }

  const local = getLocalSnapshot(args.path);
  let remoteRepo = args.repo || local.inferred_github_repo;
  let remote = { ok: false, error: "skipped by --local-only" };

  if (!args.localOnly) {
    if (!remoteRepo) {
      const message = "Cannot infer GitHub repo from local origin; pass --repo <owner/name>";
      if (args.strict) throw new Error(message);
      remote = { ok: false, error: message };
    } else {
      remote = getRemoteSnapshot(remoteRepo, args.branch || local.branch, path.resolve(args.path), args.strict);
    }
  }

  const report = {
    generated_at: new Date().toISOString(),
    mode: args.localOnly ? "local_only" : "local_and_remote",
    local,
    remote,
  };

  writeFileSafe(args.outJson, JSON.stringify(report, null, 2));
  writeFileSafe(args.outMd, formatMd(report));

  const recommendation =
    remote && remote.ok && remote.recommendations ? remote.recommendations.recommended : "n/a";
  console.log(
    `[repo-parser] done | repo=${remoteRepo || "n/a"} | remote_ok=${remote && remote.ok ? "yes" : "no"} | recommended=${recommendation}`
  );
  console.log(`[repo-parser] out_json=${path.resolve(args.outJson)}`);
  console.log(`[repo-parser] out_md=${path.resolve(args.outMd)}`);
}

try {
  main();
} catch (error) {
  console.error(`[repo-parser] ERROR: ${error.message}`);
  process.exit(1);
}
