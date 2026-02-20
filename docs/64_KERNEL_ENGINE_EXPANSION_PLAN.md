# Kernel Engine Expansion Plan

## Overview
Comprehensive expansion of the Kernel Engine game platform with new game mechanics, social features, and Firebase-backed cloud persistence.

---

## Phase 1: Game Mechanics Expansion

### 1.1 Skill Tree System
```
mermaid
graph TD
    A[Root: Core] --> B[Passive Branch]
    A --> C[Active Branch]  
    A --> D[Utility Branch]
    
    B --> B1[Stat Boost]
    B --> B2[Combo Master]
    B1 --> B3[Legendary Potential]
    
    C --> C1[Quick Draw]
    C --> C2[Chain Reaction]
    
    D --> D1[Treasure Hunter]
    D --> D2[Daily Boost]
```

**Data Model:**
```typescript
interface Skill {
  id: string;
  name: string;
  description: string;
  branch: 'passive' | 'active' | 'utility';
  tier: 1 | 2 | 3;
  prerequisites: string[];
  cost: number; // skill points
  effect: SkillEffect;
}

interface SkillEffect {
  type: 'stat_multiply' | 'unlock_ability' | 'passive_trigger';
  params: Record<string, number>;
}

interface UserSkill {
  userId: string;
  skillId: string;
  unlockedAt: string;
  currentLevel: number;
}
```

### 1.2 Quest System
```
mermaid
stateDiagram-v2
    [*] --> Available
    Available --> InProgress: Start Quest
    InProgress --> Completed: Meet Requirements
    Completed --> Claimed: Collect Rewards
    Claimed --> [*]
    
    Daily: Reset at midnight
    Weekly: Reset on Monday
    Achievement: One-time unlock
```

**Quest Types:**
- **Daily Quests**: Generate X abilities, Like Y abilities, Save Z abilities
- **Weekly Quests**: Maintain streak, Generate rare abilities, Reach combo milestones
- **Achievement Quests**: Unlock all skills in a branch, Reach total generated threshold

### 1.3 Inventory System
```
mermaid
classDiagram
    Item <|-- Equipment
    Item <|-- Consumable
    Item <|-- Material
    
    Equipment --o Slot
    Consumable --o Effect
    Material --o Recipe
    
    class Item {
        +id: string
        +name: string
        +rarity: common|rare|epic|legendary
        +description: string
    }
    
    class Equipment {
        +slot: head|body|weapon|accessory
        +stats: StatModifier[]
    }
```

### 1.4 Crafting System
```
mermaid
graph LR
    M1[Material 1] --> R[Recipe]
    M2[Material 2] --> R
    M3[Material 3] --> R
    R --> Result[Ability/Item]
    R --> Bonus[Bonus Chance]
```

**Crafting Rules:**
- 3 materials → 1 result
- Matching rarity increases success rate
- Failed crafts return 50% materials
- Legendary requires all legendary materials

---

## Phase 2: Social/Multiplayer Features

### 2.1 Leaderboards
```
mermaid
erDiagram
    USER ||--o| LEADERBOARD_ENTRY : has
    LEADERBOARD_ENTRY {
        string userId
        int rank
        int score
        string period // daily|weekly|all
    }
```

**Types:**
- Global (all players)
- Friends (player connections)
- Weekly reset for competition

### 2.2 Ability Sharing
- Export ability as shareable link
- Public gallery of community abilities
- Like/bookmark community abilities

### 2.3 Trading System
```
mermaid
sequenceDiagram
    User A->>Market: List Ability
    Market->>User B: Show Listing
    User B->>Market: Make Offer
    Market->>User A: Accept/Reject
    alt Accepted
        Market->>User A: Receive Currency
        Market->>User B: Receive Ability
    else Rejected
        Market->>User B: Return Offer
    end
```

---

## Phase 3: Backend Persistence (Firebase)

### 3.1 Firestore Schema
```sql
-- New tables for expanded features
CREATE TABLE user_skills (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES app_user(id),
  skill_id TEXT NOT NULL,
  unlocked_at TIMESTAMPTZ DEFAULT NOW(),
  current_level INT DEFAULT 1
);

CREATE TABLE quests (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT CHECK (type IN ('daily', 'weekly', 'achievement')),
  requirements JSONB NOT NULL,
  rewards JSONB NOT NULL,
  is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE user_quest_progress (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES app_user(id),
  quest_id TEXT REFERENCES quests(id),
  progress JSONB DEFAULT '{}',
  status TEXT CHECK (status IN ('available', 'in_progress', 'completed', 'claimed')),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE items (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT CHECK (type IN ('equipment', 'consumable', 'material')),
  rarity TEXT,
  stats JSONB,
  description TEXT
);

CREATE TABLE user_inventory (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES app_user(id),
  item_id TEXT REFERENCES items(id),
  quantity INT DEFAULT 1,
  acquired_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE recipes (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  inputs JSONB NOT NULL,
  output_item_id TEXT REFERENCES items(id),
  output_ability_id TEXT,
  success_rate DECIMAL(3,2)
);

CREATE TABLE trades (
  id TEXT PRIMARY KEY,
  seller_id TEXT REFERENCES app_user(id),
  buyer_id TEXT REFERENCES app_user(id),
  ability_text TEXT,
  price INT,
  status TEXT CHECK (status IN ('open', 'pending', 'completed', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE friendships (
  id TEXT PRIMARY KEY,
  user_a_id TEXT REFERENCES app_user(id),
  user_b_id TEXT REFERENCES app_user(id),
  status TEXT CHECK (status IN ('pending', 'accepted')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 3.2 Firebase Repository Adapter
```typescript
interface FirebaseRepository extends AbilityRepository {
  // Skills
  getSkills(userId: string): Promise<UserSkill[]>;
  unlockSkill(userId: string, skillId: string): Promise<void>;
  
  // Quests
  getQuests(userId: string): Promise<UserQuestProgress[]>;
  updateQuestProgress(userId: string, questId: string, progress: QuestProgress): Promise<void>;
  claimQuestReward(userId: string, questId: string): Promise<void>;
  
  // Inventory
  getInventory(userId: string): Promise<UserInventoryItem[]>;
  addItem(userId: string, itemId: string, quantity: number): Promise<void>;
  removeItem(userId: string, itemId: string, quantity: number): Promise<void>;
  
  // Trading
  listAbility(userId: string, abilityText: string, price: number): Promise<Trade>;
  makeOffer(tradeId: string, buyerId: string): Promise<void>;
  acceptTrade(tradeId: string): Promise<void>;
  
  // Social
  addFriend(userId: string, friendId: string): Promise<void>;
  getFriends(userId: string): Promise<User[]>;
  getLeaderboard(period: 'daily' | 'weekly' | 'all'): Promise<LeaderboardEntry[]>;
  
  // Real-time subscriptions
  subscribeToUser(userId: string, callback: (data: UserProfile) => void): () => void;
}
```

### 3.3 Offline-First Sync
```typescript
interface SyncStrategy {
  // Local-first writes
  queueWrite(collection: string, docId: string, data: any): void;
  
  // Conflict resolution: last-write-wins with timestamp
  resolveConflict(local: any, remote: any): any;
  
  // Sync on reconnect
  syncPending(): Promise<SyncResult>;
}
```

### 3.4 Security Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // User can read/write own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Leaderboards are public read
    match /leaderboards/{period} {
      allow read: if request.auth != null;
      allow write: if false; // Server-only
    }
    
    // Trading is authenticated access
    match /trades/{tradeId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.sellerId 
                 || request.auth.uid == resource.data.buyerId;
    }
  }
}
```

---

## Implementation Order

1. **Schema Updates** - Add new tables to schema.sql
2. **TypeScript Interfaces** - Define all new types
3. **Firebase Adapter** - Implement cloud repository
4. **LocalStorage Enhancement** - Extend existing adapter
5. **Quest System** - Daily/weekly quest logic
6. **Skill Tree** - Unlock and progression logic
7. **Inventory** - Item management
8. **Crafting** - Recipe and combination logic
9. **Social Features** - Friends, leaderboards
10. **Trading** - Marketplace functionality
11. **Migration Scripts** - Import existing user data
