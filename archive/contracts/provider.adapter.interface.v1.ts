export const PROVIDER_ADAPTER_CONTRACT_VERSION = "1.0.0";

export type ModelId = string;
export type CapabilityTier = "cheap" | "standard" | "premium";

export type RequestMode = "sync" | "stream";

export type NormalizedFailureCode =
  | "TIMEOUT"
  | "RATE_LIMITED"
  | "AUTH"
  | "INVALID_REQUEST"
  | "CONTEXT_OVERFLOW"
  | "UPSTREAM_UNAVAILABLE"
  | "UNKNOWN";

export interface NormalizedUsage {
  inputTokens: number;
  outputTokens: number;
  totalTokens: number;
}

export interface PromptSpec {
  // Core logic passes structured instructions/data only.
  // Model-specific prompt formatting must be done inside adapter implementation.
  system: string;
  instruction: string;
  contextBlocks?: string[];
}

export interface NormalizedRequest {
  requestId: string;
  modelTier: CapabilityTier;
  model: ModelId;
  mode: RequestMode;
  prompt: PromptSpec;
  limits: {
    maxInputTokens: number;
    maxOutputTokens: number;
    timeoutMs: number;
  };
  stream?: {
    enabled: boolean;
    maxChunkChars?: number;
  };
  context?: Record<string, unknown>;
}

export interface NormalizedStreamChunk {
  requestId: string;
  index: number;
  textDelta: string;
  done: boolean;
}

export interface NormalizedSuccess {
  ok: true;
  requestId: string;
  text: string;
  usage: NormalizedUsage;
  finishReason: "stop" | "length";
  raw?: unknown;
}

export interface NormalizedFailure {
  ok: false;
  requestId: string;
  code: NormalizedFailureCode;
  retryable: boolean;
  message: string;
  raw?: unknown;
}

export type NormalizedResult = NormalizedSuccess | NormalizedFailure;

export interface ProviderAdapterMetadata {
  name: string;
  version: string;
  supportsStreaming: boolean;
}

export interface ProviderAdapter {
  readonly meta: ProviderAdapterMetadata;

  // Must normalize token/context/timeout semantics regardless of model/provider.
  generate(request: NormalizedRequest): Promise<NormalizedResult>;

  // Optional streaming path; chunk/result schema must stay provider-agnostic.
  stream?(
    request: NormalizedRequest,
    onChunk: (chunk: NormalizedStreamChunk) => void
  ): Promise<NormalizedResult>;
}
