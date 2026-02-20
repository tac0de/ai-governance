// Quests module placeholder

export interface Quest {
  id: string;
  title?: string;
  description?: string;
}

export function createQuest(id: string, title?: string): Quest {
  return { id, title };
}

export default Quest;
