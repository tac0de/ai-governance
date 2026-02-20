export const PROVIDER_CONTRACT_VERSION = "1.0.0";

export type ModelId = string;

export interface ProviderMetadata {
  name: string;
  version: string;
  supportsStreaming: boolean;
  supportsEmbeddings?: boolean;
}

export interface GenerateOptions {
  model: ModelId;
  input: string;
  temperature?: number;
  maxTokens?: number;
  topP?: number;
  user?: string;
  context?: Record<string, unknown>;
}

export interface TokenUsage {
  prompt: number;
  completion: number;
  total: number;
}

export interface GenerateResult {
  output: string;
  finishReason: "stop" | "length" | "error";
  usage: TokenUsage;
  raw?: unknown;
}

export interface StreamChunk {
  index: number;
  delta: string;
  done: boolean;
  finishReason?: "stop" | "length" | "error";
  raw?: unknown;
}

export interface EmbeddingResult {
  vectors: number[][];
  model: ModelId;
  usage?: TokenUsage;
  raw?: unknown;
}

export interface Provider {
  readonly meta: ProviderMetadata;
  generate(options: GenerateOptions): Promise<GenerateResult>;
  stream?(
    options: GenerateOptions,
    onChunk: (chunk: StreamChunk) => void
  ): Promise<GenerateResult>;
  embeddings?(input: string[], model: ModelId): Promise<EmbeddingResult>;
}
