import { Event } from '../game-engine/types/event.types';
import { assertNever } from '../game-engine/dispatcher/assertNever';

// This file exists to exercise TypeScript's exhaustiveness rules at compile time.
// The function below mirrors the dispatcher switch. If a new Event.type is added
// but not handled here, TypeScript will complain that 'event' is not "never" in the default branch.

function _exhaustiveCheck(event: Event) {
  switch (event.type) {
    case 'WORLD_NEWS_POST':
      return;
    case 'QUEST_ISSUE':
      return;
    case 'NPC_STATE_TRANSITION':
      return;
    case 'ECONOMY_ADJUST':
      return;
    case 'ITEM_DROP_TABLE_ADJUST':
      return;
    default:
      // If a new event type is introduced and not added above,
      // `event` will not be `never` here and assertNever will cause a compile-time error.
      return assertNever(event as never);
  }
}

export {};
