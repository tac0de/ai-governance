import type { Event, EventType } from '../types/event.types';

export type ValidationResult =
  | { valid: true; event: Event }
  | { valid: false; reason: string };

const VALID_TYPES: EventType[] = [
  'WORLD_NEWS_POST',
  'QUEST_ISSUE',
  'NPC_STATE_TRANSITION',
  'ECONOMY_ADJUST',
  'ITEM_DROP_TABLE_ADJUST',
];

export function validateEvent(input: unknown): ValidationResult {
  if (input === null || typeof input !== 'object') {
    return { valid: false, reason: 'input is not an object' };
  }

  const anyInput = input as Record<string, unknown>;

  if (!('type' in anyInput)) {
    return { valid: false, reason: "missing 'type' field" };
  }

  if (!('params' in anyInput)) {
    return { valid: false, reason: "missing 'params' field" };
  }

  const t = anyInput['type'];
  if (typeof t !== 'string') {
    return { valid: false, reason: "'type' is not a string" };
  }

  if (!VALID_TYPES.includes(t as EventType)) {
    return { valid: false, reason: `unknown event type: ${t}` };
  }

  // Minimal: do not validate params shape beyond presence
  return { valid: true, event: input as Event };
}

export default validateEvent;
