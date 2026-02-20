#!/usr/bin/env node
import fs from 'node:fs';
import { callLLM, listAdapters } from '../lib/llm/connector.mjs';

function usage() {
  console.log('llm [--provider <name>] [--model <name>] [--input <text> | --file <path>] [--max-tokens <n>]');
}

async function main() {
  const args = process.argv.slice(2);
  if (args.includes('-h') || args.includes('--help') || args.length === 0) {
    usage();
    process.exit(0);
  }

  const parsed = {};
  for (let i = 0; i < args.length; i++) {
    const a = args[i];
    if (a === '--provider') parsed.provider = args[++i];
    else if (a === '--model') parsed.model = args[++i];
    else if (a === '--input') parsed.input = args[++i];
    else if (a === '--file') parsed.file = args[++i];
    else if (a === '--max-tokens') parsed.maxTokens = Number(args[++i]);
    else if (a === '--list-adapters') parsed.list = true;
  }

  if (parsed.list) {
    console.log('adapters:', (await listAdapters()).join(', '));
    process.exit(0);
  }

  if (parsed.file) {
    parsed.input = fs.readFileSync(parsed.file, 'utf8');
  }

  if (!parsed.input) {
    console.error('no input provided');
    usage();
    process.exit(2);
  }

  const out = await callLLM({ provider: parsed.provider, model: parsed.model, input: parsed.input, maxTokens: parsed.maxTokens });
  console.log(JSON.stringify(out, null, 2));
}

main().catch((err) => {
  console.error('llm: unexpected error', err?.message || String(err));
  process.exit(1);
});
