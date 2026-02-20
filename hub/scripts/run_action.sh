#!/usr/bin/env bash
set -euo pipefail

NODE_BIN="$(command -v node)"
if [[ -z "$NODE_BIN" ]]; then
  echo "node not found" >&2
  exit 2
fi

PATH="/usr/bin:/bin:/usr/sbin:/sbin"
export PATH

command_json=""
timeout_sec=""
stdout_path=""
stderr_path=""
env_json=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --command-json)
      command_json="${2:-}"
      shift 2
      ;;
    --timeout-sec)
      timeout_sec="${2:-}"
      shift 2
      ;;
    --stdout)
      stdout_path="${2:-}"
      shift 2
      ;;
    --stderr)
      stderr_path="${2:-}"
      shift 2
      ;;
    --env-json)
      env_json="${2:-}"
      shift 2
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$command_json" || -z "$timeout_sec" || -z "$stdout_path" || -z "$stderr_path" || -z "$env_json" ]]; then
  echo "missing required args" >&2
  exit 2
fi

if ! [[ "$timeout_sec" =~ ^[0-9]+$ ]] || [[ "$timeout_sec" -lt 1 ]]; then
  echo "invalid --timeout-sec: $timeout_sec" >&2
  exit 2
fi

mkdir -p "$(dirname "$stdout_path")" "$(dirname "$stderr_path")"

command_argv=()
while IFS= read -r -d '' item; do
  command_argv+=("$item")
done < <("$NODE_BIN" - "$command_json" <<'NODE'
const fs = require('node:fs');
const path = process.argv[2];
const data = JSON.parse(fs.readFileSync(path, 'utf8'));
if (!Array.isArray(data) || data.length === 0 || data.some((v) => typeof v !== 'string')) {
  process.exit(2);
}
for (const v of data) {
  process.stdout.write(v);
  process.stdout.write('\0');
}
NODE
)

env_pairs=()
while IFS= read -r -d '' item; do
  env_pairs+=("$item")
done < <("$NODE_BIN" - "$env_json" <<'NODE'
const fs = require('node:fs');
const path = process.argv[2];
const data = JSON.parse(fs.readFileSync(path, 'utf8'));
if (!data || typeof data !== 'object' || Array.isArray(data)) {
  process.exit(2);
}
const keys = Object.keys(data).sort();
for (const key of keys) {
  const value = data[key];
  if (typeof value !== 'string') {
    process.exit(2);
  }
  process.stdout.write(`${key}=${value}`);
  process.stdout.write('\0');
}
NODE
)

env_cmd=(env -i "PATH=$PATH")
for pair in "${env_pairs[@]}"; do
  env_cmd+=("$pair")
done

"${env_cmd[@]}" "$NODE_BIN" - "$timeout_sec" "${command_argv[@]}" >"$stdout_path" 2>"$stderr_path" <<'NODE'
const { spawn } = require('node:child_process');

const timeoutSec = Number(process.argv[2]);
const command = process.argv[3];
const args = process.argv.slice(4);

if (!Number.isInteger(timeoutSec) || timeoutSec < 1 || !command) {
  process.exit(2);
}

let timedOut = false;
const child = spawn(command, args, {
  stdio: 'inherit',
  shell: false,
  env: process.env
});

const timer = setTimeout(() => {
  timedOut = true;
  child.kill('SIGKILL');
}, timeoutSec * 1000);

child.on('error', () => {
  clearTimeout(timer);
  process.exit(1);
});

child.on('exit', (code, signal) => {
  clearTimeout(timer);
  if (timedOut) {
    process.exit(124);
  }
  if (signal) {
    process.exit(1);
  }
  process.exit(code ?? 1);
});
NODE
