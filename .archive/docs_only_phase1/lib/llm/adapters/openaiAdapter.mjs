import fetch from 'node-fetch';

export async function call({ model, input, maxTokens, realtime }) {
  const key = process.env.OPENAI_API_KEY || process.env.OPENAI_PROD_KEY;
  const base = process.env.OPENAI_BASE_URL || 'https://api.openai.com/v1';

  if (!realtime || !key) {
    return {
      provider: 'openai',
      model,
      text: `[mock] ${input}`,
      tokens: 0,
      meta: { mocked: true },
    };
  }

  const url = `${base}/responses`;
  const body = {
    model,
    input,
    max_output_tokens: maxTokens,
  };

  const res = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${key}`,
    },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const txt = await res.text();
    throw new Error(`OpenAI error: ${res.status} ${txt}`);
  }

  const json = await res.json();
  // Try to pick a sensible text representation from Responses API
  const text = json.output?.[0]?.content?.map((c) => c?.text || '').join('') || json.output_text || '';

  return { provider: 'openai', model, text, tokens: 0, meta: { raw: json } };
}
