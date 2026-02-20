// B-tier event schema: strict event types for the game engine

export interface EventBase {
  idempotency_key: string;
  created_at: string; // ISO string
}

export interface WorldNewsPostEvent extends EventBase {
  type: 'WORLD_NEWS_POST';
  params: {
    headline: string;
    body: string;
    tags?: string[];
    locale?: string;
  };
}

export interface QuestIssueEvent extends EventBase {
  type: 'QUEST_ISSUE';
  params: {
    questId: string;
    issuerId?: string;
    description: string;
    difficulty?: 'EASY' | 'MEDIUM' | 'HARD';
    expires_at?: string; // ISO
  };
}

export interface NPCStateTransitionEvent extends EventBase {
  type: 'NPC_STATE_TRANSITION';
  params: {
    npcId: string;
    from_state: string;
    to_state: string;
    reason?: string;
    metadata?: Record<string, unknown>;
  };
}

export interface EconomyAdjustEvent extends EventBase {
  type: 'ECONOMY_ADJUST';
  params: {
    currency: string;
    delta: number;
    target: 'GLOBAL' | 'REGION' | 'MARKET' | 'PLAYER_SPECIFIC';
    region?: string;
    reason?: string;
  };
}

export interface ItemDropTableAdjustEvent extends EventBase {
  type: 'ITEM_DROP_TABLE_ADJUST';
  params: {
    itemId: string;
    drop_rate: number; // 0.0 - 1.0
    region?: string;
    effective_from?: string; // ISO
    notes?: string;
  };
}

export type Event =
  | WorldNewsPostEvent
  | QuestIssueEvent
  | NPCStateTransitionEvent
  | EconomyAdjustEvent
  | ItemDropTableAdjustEvent;

export type EventType = Event['type'];

export interface EventProposal {
  event: Event;
  proposal_source?: string;
  confidence?: number;
}

export default Event;
