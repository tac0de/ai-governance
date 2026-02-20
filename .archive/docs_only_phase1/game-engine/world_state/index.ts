// Placeholder types and interfaces for world state management

export interface WorldState {
  id: string;
  description?: string;
}

export function createEmptyWorldState(id: string): WorldState {
  return { id };
}

export default WorldState;
