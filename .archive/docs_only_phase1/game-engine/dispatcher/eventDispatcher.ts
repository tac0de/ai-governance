import { Event } from '../types/event.types';
import { assertNever } from './assertNever';
import { validateEvent } from './eventValidator';

// Retry orchestration configuration and local in-memory guards.
export type RetryPolicy = 'immediate' | 'exponential-backoff' | 'requeue';

let RETRY_POLICY: RetryPolicy = 'exponential-backoff';
let MAX_RETRY = 3;
let BASE_DELAY_MS = 10;

export function configureRetry(opts: Partial<{ policy: RetryPolicy; maxRetry: number; baseDelayMs: number }>) {
  if (opts.policy) RETRY_POLICY = opts.policy;
  if (typeof opts.maxRetry === 'number') MAX_RETRY = opts.maxRetry;
  if (typeof opts.baseDelayMs === 'number') BASE_DELAY_MS = opts.baseDelayMs;
}

const processingKeys = new Set<string>();

function sleep(ms: number) {
  return new Promise((res) => setTimeout(res, ms));
}

export type DispatchStatus = 'OK' | 'RETRY' | 'ERROR';

export interface DispatchResult {
  status: DispatchStatus;
  handler?: string;
  result?: unknown;
  error?: string;
  meta?: {
    receivedAt: string;
    eventType?: string;
    retryCount?: number;
    maxRetry?: number;
  };
}

async function handleWorldNewsPost(e: Extract<Event, { type: 'WORLD_NEWS_POST' }>) {
  return { stub: true, topic: e.params.headline };
}

async function handleQuestIssue(e: Extract<Event, { type: 'QUEST_ISSUE' }>) {
  return { stub: true, questId: e.params.questId };
}

async function handleNPCStateTransition(e: Extract<Event, { type: 'NPC_STATE_TRANSITION' }>) {
  return { stub: true, npcId: e.params.npcId, from: e.params.from_state, to: e.params.to_state };
}

async function handleEconomyAdjust(e: Extract<Event, { type: 'ECONOMY_ADJUST' }>) {
  // If delta is zero, signal a transient condition requiring a retry.
  if (e.params.delta === 0) {
    return { status: 'RETRY' as const };
  }

  return { stub: true, delta: e.params.delta, currency: e.params.currency };
}

async function handleItemDropTableAdjust(e: Extract<Event, { type: 'ITEM_DROP_TABLE_ADJUST' }>) {
  return { stub: true, itemId: e.params.itemId, drop_rate: e.params.drop_rate };
}

export async function dispatchEvent(event: Event): Promise<DispatchResult> {
  switch (event.type) {
    case 'WORLD_NEWS_POST':
      return { status: 'OK', handler: 'handleWorldNewsPost', result: await handleWorldNewsPost(event) };
    case 'QUEST_ISSUE':
      return { status: 'OK', handler: 'handleQuestIssue', result: await handleQuestIssue(event) };
    case 'NPC_STATE_TRANSITION':
      return { status: 'OK', handler: 'handleNPCStateTransition', result: await handleNPCStateTransition(event) };
    case 'ECONOMY_ADJUST': {
      const handlerResult = await handleEconomyAdjust(event);
      // If the handler explicitly requests a retry, propagate that status.
      if (handlerResult && typeof handlerResult === 'object' && (handlerResult as any).status === 'RETRY') {
        return { status: 'RETRY', handler: 'handleEconomyAdjust' };
      }
      return { status: 'OK', handler: 'handleEconomyAdjust', result: handlerResult };
    }
    case 'ITEM_DROP_TABLE_ADJUST':
      return { status: 'OK', handler: 'handleItemDropTableAdjust', result: await handleItemDropTableAdjust(event) };
    default:
      return assertNever(event);
  }
}

export default dispatchEvent;

/**
 * Incoming runtime wrapper that validates unknown input before dispatching.
 * Does not modify `dispatchEvent` which remains pure Event -> DispatchResult.
 */
export async function dispatchIncoming(input: unknown): Promise<DispatchResult> {
  const receivedAt = new Date().toISOString();
  const v = validateEvent(input);
  if (!v.valid) {
    return { status: 'ERROR', error: v.reason, meta: { receivedAt } };
  }

  const idKey = (v.event && (v.event as any).idempotency_key) || JSON.stringify(v.event);
  if (processingKeys.has(idKey)) {
    return { status: 'ERROR', error: 'reentry blocked', meta: { receivedAt, eventType: v.event.type } };
  }

  processingKeys.add(idKey);
  try {
    let attempt = 0;
    while (true) {
      attempt += 1;
      const res = await dispatchEvent(v.event);
      if (res.status !== 'RETRY') {
        return { ...res, meta: { receivedAt, eventType: v.event.type, retryCount: attempt - 1, maxRetry: MAX_RETRY } };
      }

      // res.status === 'RETRY'
      if (attempt >= MAX_RETRY) {
        return { status: 'RETRY', handler: res.handler, error: 'max retries exceeded', meta: { receivedAt, eventType: v.event.type, retryCount: attempt, maxRetry: MAX_RETRY } };
      }

      // Determine delay strategy
      if (RETRY_POLICY === 'immediate') {
        // immediate loop continue
      } else if (RETRY_POLICY === 'exponential-backoff') {
        const delay = BASE_DELAY_MS * Math.pow(2, attempt - 1);
        if (delay > 0) await sleep(delay);
      } else if (RETRY_POLICY === 'requeue') {
        // For now, requeue behaves like immediate but marks intent to requeue.
      }
      // continue to next attempt
    }
  } finally {
    processingKeys.delete(idKey);
  }
}

