export type LLMResponse = { provider: string; model: string; text: string; tokens?: number; meta?: any };

export type LLMCallOptions = {
  provider?: string;
  model?: string;
  input: string;
  maxTokens?: number;
  realtime?: boolean;
  extra?: any;
};

// Browser-friendly connector: if `LLM_API_URL` is set at build/runtime, it POSTs there.
// Otherwise it returns a deterministic mock response for client usage.
export async function callLLM(opts: LLMCallOptions): Promise<LLMResponse> {
  const { input, model = 'gpt-5-nano', realtime = false } = opts;
  const apiUrl = (globalThis as any)?.LLM_API_URL || (process && (process.env as any)?.LLM_API_URL) || '';

  if (apiUrl && realtime) {
    try {
      const res = await fetch(apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ model, input, maxTokens: opts.maxTokens || 120, provider: opts.provider }),
      });
      if (!res.ok) throw new Error(`LLM proxy error: ${res.status}`);
      const json = await res.json();
      return json as LLMResponse;
    } catch (err) {
      return { provider: 'error', model, text: `LLM proxy failed: ${String(err)}` };
    }
  }

  // Mock fallback
  return { provider: 'mock', model, text: `mock reply: ${String(input).slice(0, 120)}`, tokens: 0, meta: { mocked: true } };
}
