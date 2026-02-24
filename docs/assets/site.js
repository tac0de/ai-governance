const copy = {
  en: {
    eyebrow: "Governance Architecture",
    title: "One Control Layer for Multi-Agent AI Systems",
    subtitle: "This explains your architecture in plain language: agents can execute, but governance defines boundaries, and humans keep final authority.",
    hierarchyTitle: "Architecture In 3 Layers",
    hierarchyCoreTitle: "1) Core Concept",
    hierarchyCore: [
      "Single governance core for all services",
      "Deterministic verdict path",
      "Human override authority is explicit"
    ],
    hierarchySubTitle: "2) Sub Components",
    hierarchySub: [
      "Registry: allowed service/MCP topology",
      "Schema: contract validity and structure",
      "Policy: risk tiers and approval modes"
    ],
    hierarchyFlowTitle: "3) Real Application Flow",
    hierarchyFlow: [
      "Agent proposes with evidence refs",
      "Governance validates policy + schema + scope",
      "Output is auto proceed or human-gated release"
    ],
    languageLabel: "Language",
    whatTitle: "What It Is",
    what: [
      "A central governance core shared across all services",
      "A deterministic validation path for policy, schema, and trace",
      "A human-gated operating model for high-risk changes"
    ],
    howTitle: "How It Works",
    how: [
      "Registries define allowed services and MCPs",
      "Validation scripts enforce repository contracts in CI",
      "Risk tier decides whether mandatory human approval is required"
    ],
    whyTitle: "Why It Is Innovative",
    why: [
      "Agent-vendor independent: governance survives model/tool replacement",
      "Deterministic-by-design: same evidence, same verdict",
      "Scales trust: non-developers can inspect decision logic"
    ],
    flowTitle: "Code Flow Overview",
    flow: [
      "Input arrives as intent + evidence refs",
      "Schema and policy contracts are validated by scripts",
      "Registry/allowlist gates evaluate service and MCP scope",
      "Risk tier outputs: auto / policy+owner / mandatory human gate"
    ],
    gameTitle: "Governance Maze (Endless)",
    gameNote: "Pacman-style endless mode. Collect evidence nodes, avoid risk agents, and keep climbing your governance level.",
    gameReset: "Start Over",
    gameScoreLabel: "Score",
    gameBestLabel: "Best",
    gameAccuracyLabel: "Accuracy",
    gameLevelLabel: "Level",
    gameXpLabel: "XP",
    gameDailyLabel: "Daily Challenge",
    gameDailyMission: "Collect 120 evidence nodes today",
    gameBadgeLabel: "Badges",
    gameBadgeNovice: "Novice",
    gameBadgeKeeper: "Gate Keeper",
    gameBadgeOracle: "Policy Oracle",
    gameBadgePerfect: "Perfect Day",
    gameFeedbackIdle: "Move with arrow keys or the pad below.",
    gameFeedbackHit: "Risk collision. Score penalty applied.",
    gameFeedbackLevelUp: "Level up. Risk speed increased.",
    demoTitle: "Interactive Governance Simulator",
    demoButton: "Refresh",
    demoNote: "Change inputs to experiment. Press Refresh to reset the run state and start the simulation loop from baseline.",
    presetLabel: "Quick Presets",
    presetSafe: "Safe Launch",
    presetBalanced: "Balanced",
    presetRisky: "Risky Push",
    cockpitTitle: "Decision Cockpit",
    riskMeterLabel: "Risk Exposure",
    gateTitle: "Governance Gates",
    checksTitle: "Contract Checks",
    evaluatedLabel: "Last Evaluated:",
    runCountLabel: "Runs:",
    inputScenario: "Scenario",
    inputRisk: "Declared Risk Tier",
    inputPii: "Contains sensitive user data",
    inputExternal: "Depends on external runtime",
    inputDeterministic: "Deterministic trace path maintained",
    decisionLabel: "Decision:",
    recommendationProceed: "Recommendation: release can proceed under automated gate. Keep trace attached.",
    recommendationHuman: "Recommendation: pause and request human approval with evidence summary.",
    recommendationBlock: "Recommendation: block release now. Fix deterministic path before retry.",
    deltaPrefix: "Compared with previous run:",
    deltaNone: "no meaningful change",
    blogTitle: "Short Essays",
    blogs: [
      {
        title: "What This Design Actually Is",
        body: "This is not just documentation. It is an operating system for decisions. Every service and MCP must pass the same contract checks, so architecture intent stays enforceable, not aspirational."
      },
      {
        title: "Why This Matters Now",
        body: "AI teams are moving fast, but speed without boundaries causes quality drift. Your model keeps speed while preserving control by separating proposal power (agent) from release power (human)."
      },
      {
        title: "How To Understand The Operating Model",
        body: "You do not need code access to read the logic. Follow this order: proposal comes in, governance checks contracts, risk tier decides approval mode, then human gate closes high-risk releases."
      }
    ],
    contactTitle: "Contact",
    contactText: "If you want to collaborate on this governance architecture, email directly.",
    caseTitle: "One Practical Example",
    caseSummary: "In one production path, governance gates prevented a secret/config mismatch from shipping silently. The issue was detected at validation and deployment checkpoints before user-facing impact.",
    caseMetric1Label: "Detected At",
    caseMetric1Value: "Pre-release Gate",
    caseMetric2Label: "Potential Impact",
    caseMetric2Value: "Cross-env drift",
    caseMetric3Label: "Outcome",
    caseMetric3Value: "Blocked before exposure",
    ctaTitle: "Next Actions",
    ctaText: "If this architecture is relevant to your team, take one concrete next step.",
    ctaWhitepaper: "Download Whitepaper",
    ctaDiagram: "Download Diagram",
    footer: "Human System Architect remains final release authority."
  },
  ko: {
    eyebrow: "거버넌스 아키텍처",
    title: "멀티 에이전트 AI를 위한 단일 통제 계층",
    subtitle: "에이전트는 실행할 수 있지만, 거버넌스가 경계를 정하고 최종 권한은 인간이 유지한다는 구조를 쉬운 언어로 설명합니다.",
    hierarchyTitle: "3단 구조로 보는 아키텍처",
    hierarchyCoreTitle: "1) 핵심 개념",
    hierarchyCore: [
      "모든 서비스를 관통하는 단일 거버넌스 코어",
      "결정적 판정 경로(같은 증거=같은 결과)",
      "인간 오버라이드 권한을 명시적으로 유지"
    ],
    hierarchySubTitle: "2) 하위 구성요소",
    hierarchySub: [
      "Registry: 허용 서비스/MCP 토폴로지",
      "Schema: 계약 구조와 유효성",
      "Policy: 리스크 등급과 승인 방식"
    ],
    hierarchyFlowTitle: "3) 실제 적용 흐름",
    hierarchyFlow: [
      "에이전트가 증거 참조와 함께 변경 제안",
      "거버넌스가 정책+스키마+범위를 검증",
      "자동 진행 또는 인간 승인 대기 판정 출력"
    ],
    languageLabel: "언어",
    whatTitle: "무엇인가",
    what: [
      "모든 서비스가 공유하는 중앙 거버넌스 코어",
      "정책/스키마/트레이스를 결정적으로 검증하는 경로",
      "고위험 변경에 대해 인간 게이트를 강제하는 운영 모델"
    ],
    howTitle: "어떻게 동작하나",
    how: [
      "레지스트리로 허용 서비스/MCP 범위를 정의",
      "검증 스크립트가 CI에서 저장소 계약을 강제",
      "리스크 등급이 인간 승인 의무 여부를 결정"
    ],
    whyTitle: "무엇이 혁신적인가",
    why: [
      "에이전트 벤더 독립성: 모델/툴 교체에도 거버넌스 유지",
      "결정성 중심 설계: 같은 증거면 같은 판정",
      "신뢰 확장: 비개발자도 의사결정 로직을 해석 가능"
    ],
    flowTitle: "코드 플로우 개요",
    flow: [
      "intent + evidence refs 입력",
      "스키마/정책 계약을 스크립트로 검증",
      "레지스트리/allowlist 게이트로 범위 판정",
      "리스크 계층 결과 출력: 자동 / 정책+오너 / 인간 필수"
    ],
    gameTitle: "거버넌스 미로 (무한모드)",
    gameNote: "팩맨 스타일 무한모드입니다. 증거 노드를 모으고 리스크 에이전트를 피하면서 레벨을 올리세요.",
    gameReset: "처음부터",
    gameScoreLabel: "점수",
    gameBestLabel: "최고 연속",
    gameAccuracyLabel: "정확도",
    gameLevelLabel: "레벨",
    gameXpLabel: "XP",
    gameDailyLabel: "오늘의 미션",
    gameDailyMission: "오늘 증거 노드 120개 수집",
    gameBadgeLabel: "배지",
    gameBadgeNovice: "입문자",
    gameBadgeKeeper: "게이트 키퍼",
    gameBadgeOracle: "정책 오라클",
    gameBadgePerfect: "퍼펙트 데이",
    gameFeedbackIdle: "키보드 화살표 또는 아래 패드로 이동하세요.",
    gameFeedbackHit: "리스크 충돌. 점수가 감점되었습니다.",
    gameFeedbackLevelUp: "레벨업. 리스크 속도가 증가합니다.",
    demoTitle: "거버넌스 시뮬레이터",
    demoButton: "새로고침",
    demoNote: "입력을 바꿔 실험하고, 새로고침 버튼으로 런 상태를 초기화해 기준점부터 다시 시작할 수 있습니다.",
    presetLabel: "빠른 프리셋",
    presetSafe: "안전 배포",
    presetBalanced: "균형",
    presetRisky: "고위험 푸시",
    cockpitTitle: "Decision Cockpit",
    riskMeterLabel: "리스크 노출도",
    gateTitle: "거버넌스 게이트",
    checksTitle: "계약 검증 상태",
    evaluatedLabel: "최근 평가:",
    runCountLabel: "실행 횟수:",
    inputScenario: "시나리오",
    inputRisk: "선언 리스크 등급",
    inputPii: "민감 사용자 데이터 포함",
    inputExternal: "외부 런타임 의존",
    inputDeterministic: "결정적 트레이스 경로 유지",
    decisionLabel: "판정:",
    recommendationProceed: "권고: 자동 승인 범위이므로 진행 가능합니다. 트레이스 연결은 유지하세요.",
    recommendationHuman: "권고: 증거 요약과 함께 인간 승인 요청 후 진행하세요.",
    recommendationBlock: "권고: 지금은 배포 차단. 결정성 경로부터 복구 후 재평가하세요.",
    deltaPrefix: "직전 실행 대비:",
    deltaNone: "의미 있는 변화 없음",
    blogTitle: "짧은 설명 글",
    blogs: [
      {
        title: "이 설계의 본질",
        body: "이 구조는 단순 문서가 아니라 의사결정 운영체계입니다. 모든 서비스와 MCP가 동일 계약 검증을 통과해야 하므로, 아키텍처 의도가 실제로 강제됩니다."
      },
      {
        title: "지금 왜 필요한가",
        body: "AI 개발은 빠르지만 경계가 없으면 품질이 무너집니다. 이 모델은 속도를 유지하면서 권한을 분리합니다. 에이전트는 제안하고 인간은 릴리스를 승인합니다."
      },
      {
        title: "코드 없이 이해하는 운영 흐름",
        body: "코드 열람이 없어도 의사결정 흐름은 읽을 수 있습니다. 제안 입력 -> 거버넌스 계약 검증 -> 리스크 등급 판정 -> 고위험 인간 승인 순서로 보면 됩니다."
      }
    ],
    contactTitle: "연락",
    contactText: "이 거버넌스 아키텍처 협업은 이메일로 직접 연락주세요.",
    caseTitle: "실전 사례 1개",
    caseSummary: "실제 운영 경로에서 시크릿/환경 불일치가 발생했을 때, 거버넌스 게이트가 배포 전 단계에서 이를 감지해 사용자 영향 전에 차단했습니다.",
    caseMetric1Label: "감지 시점",
    caseMetric1Value: "배포 전 게이트",
    caseMetric2Label: "잠재 리스크",
    caseMetric2Value: "환경 간 설정 드리프트",
    caseMetric3Label: "결과",
    caseMetric3Value: "노출 전 차단",
    ctaTitle: "다음 액션",
    ctaText: "이 구조가 팀에 필요하다면, 아래에서 바로 다음 단계를 선택하세요.",
    ctaWhitepaper: "화이트페이퍼 다운로드",
    ctaDiagram: "아키텍처 다이어그램 다운로드",
    footer: "최종 릴리스 권한은 Human System Architect에게 있습니다."
  }
};

const scenarioLabel = {
  ui_copy: "ui_copy",
  new_mcp: "new_mcp",
  prod_secret: "prod_secret",
  policy_change: "policy_change"
};

const presets = {
  safe: {
    scenario: "ui_copy",
    risk: "low",
    pii: false,
    external: false,
    deterministic: true
  },
  balanced: {
    scenario: "new_mcp",
    risk: "medium",
    pii: false,
    external: true,
    deterministic: true
  },
  risky: {
    scenario: "policy_change",
    risk: "high",
    pii: true,
    external: true,
    deterministic: false
  }
};

let evaluationCount = 0;
let previousSnapshot = null;
const GAME_STORE_KEY = "governance_gate_game_v1";
const TILE = 21;
const MAZE_TEMPLATE = [
  "####################",
  "#........##........#",
  "#.####.#.##.#.####.#",
  "#o####.#.##.#.####o#",
  "#..................#",
  "#.####.######.####.#",
  "#......##..##......#",
  "######.##..##.######",
  "#........P.........#",
  "######.##..##.######",
  "#......##..##......#",
  "#.####.######.####.#",
  "#..................#",
  "#o####.#.##.#.####o#",
  "#........##........#",
  "####################"
];
const gameState = {
  score: 0,
  speed: 140,
  running: false,
  loopHandle: null,
  pendingDir: "left",
  currentDir: "left",
  map: [],
  pelletsTotal: 0,
  pelletsLeft: 0,
  player: { x: 1, y: 1 },
  ghosts: [],
  progress: {
    bestScore: 0,
    collisions: 0,
    pelletsCollected: 0,
    level: 1,
    xp: 0,
    dailyDate: "",
    dailyCollected: 0
  }
};
const DIRS = {
  up: { x: 0, y: -1 },
  down: { x: 0, y: 1 },
  left: { x: -1, y: 0 },
  right: { x: 1, y: 0 }
};

function todayUtcKey() {
  return new Date().toISOString().slice(0, 10);
}

function resetDailyIfNeeded() {
  const today = todayUtcKey();
  if (gameState.progress.dailyDate !== today) {
    gameState.progress.dailyDate = today;
    gameState.progress.dailyCollected = 0;
  }
}

function loadGameProgress() {
  try {
    const raw = localStorage.getItem(GAME_STORE_KEY);
    if (!raw) return;
    const parsed = JSON.parse(raw);
    if (!parsed || typeof parsed !== "object") return;
    gameState.progress.bestScore = Math.max(0, Number(parsed.bestScore || 0));
    gameState.progress.collisions = Math.max(0, Number(parsed.collisions || 0));
    gameState.progress.pelletsCollected = Math.max(0, Number(parsed.pelletsCollected || 0));
    gameState.progress.level = Math.max(1, Number(parsed.level || 1));
    gameState.progress.xp = Math.max(0, Number(parsed.xp || 0));
    gameState.progress.dailyDate = String(parsed.dailyDate || "");
    gameState.progress.dailyCollected = Math.max(0, Number(parsed.dailyCollected || 0));
  } catch {
    // ignore broken local storage
  }
}

function saveGameProgress() {
  const payload = {
    bestScore: gameState.progress.bestScore,
    collisions: gameState.progress.collisions,
    pelletsCollected: gameState.progress.pelletsCollected,
    level: gameState.progress.level,
    xp: gameState.progress.xp,
    dailyDate: gameState.progress.dailyDate,
    dailyCollected: gameState.progress.dailyCollected
  };
  localStorage.setItem(GAME_STORE_KEY, JSON.stringify(payload));
}

function gameBadges(lang) {
  const selected = copy[lang] || copy.en;
  const out = [];
  if (gameState.progress.pelletsCollected >= 300) out.push(selected.gameBadgeNovice);
  if (gameState.progress.bestScore >= 600) out.push(selected.gameBadgeKeeper);
  if (gameState.progress.level >= 4) out.push(selected.gameBadgeOracle);
  if (gameState.progress.dailyCollected >= 120) out.push(selected.gameBadgePerfect);
  return out;
}

function detectDefaultLanguage() {
  const supported = ["en", "ko"];
  const stored = localStorage.getItem("showcase_lang");
  if (stored && supported.includes(stored)) return stored;

  const candidates = [...(navigator.languages || []), navigator.language || "en"];
  for (const code of candidates) {
    const norm = String(code).slice(0, 2).toLowerCase();
    if (supported.includes(norm)) return norm;
  }
  return "en";
}

function fillList(id, values) {
  const list = document.getElementById(id);
  if (!list) return;
  list.innerHTML = "";
  values.forEach((item) => {
    const li = document.createElement("li");
    li.textContent = item;
    list.appendChild(li);
  });
}

function fillBlog(lang) {
  const selected = copy[lang] || copy.en;
  const list = document.getElementById("blog-list");
  if (!list) return;
  list.innerHTML = "";

  selected.blogs.forEach((entry) => {
    const item = document.createElement("article");
    item.className = "blog-item";

    const title = document.createElement("h3");
    title.textContent = entry.title;
    const body = document.createElement("p");
    body.textContent = entry.body;

    item.appendChild(title);
    item.appendChild(body);
    list.appendChild(item);
  });
}

function setText(lang) {
  const selected = copy[lang] || copy.en;
  document.documentElement.lang = lang;

  document.querySelectorAll("[data-i18n]").forEach((node) => {
    const key = node.getAttribute("data-i18n");
    if (!key) return;
    if (selected[key]) node.textContent = selected[key];
  });

  fillList("what-list", selected.what);
  fillList("how-list", selected.how);
  fillList("why-list", selected.why);
  fillList("flow-list", selected.flow);
  fillList("hierarchy-core-list", selected.hierarchyCore);
  fillList("hierarchy-sub-list", selected.hierarchySub);
  fillList("hierarchy-flow-list", selected.hierarchyFlow);
  fillBlog(lang);
  renderGame(lang);
}

async function sha256(text) {
  const bytes = new TextEncoder().encode(text);
  const hash = await crypto.subtle.digest("SHA-256", bytes);
  return [...new Uint8Array(hash)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

function buildDecision(state) {
  const checks = [];
  checks.push({ name: "policy_contract", status: "pass" });
  checks.push({ name: "schema_contract", status: "pass" });

  if (!state.deterministic) {
    checks.push({ name: "deterministic_trace", status: "fail" });
  } else {
    checks.push({ name: "deterministic_trace", status: "pass" });
  }

  if (state.external) {
    checks.push({ name: "external_dependency_review", status: "warn" });
  }

  if (state.pii) {
    checks.push({ name: "data_sensitivity_gate", status: "warn" });
  }

  let approvalTier = state.risk;
  let humanGateRequired = state.risk === "high";

  if (state.pii || state.scenario === "prod_secret" || state.scenario === "policy_change") {
    approvalTier = "high";
    humanGateRequired = true;
  }

  const hasFail = checks.some((c) => c.status === "fail");
  let decision = "proceed";
  if (hasFail) decision = "block";
  else if (humanGateRequired) decision = "await_human_approval";

  return { checks, approvalTier, humanGateRequired, decision };
}

function summarizeDecision(lang, result) {
  if (lang === "ko") {
    if (result.decision === "block") return "차단: 결정성 경로 위반";
    if (result.decision === "await_human_approval") return "인간 승인 대기: 고위험 변경";
    return "진행 가능: 자동 승인 범위";
  }
  if (result.decision === "block") return "Blocked: deterministic contract failed";
  if (result.decision === "await_human_approval") return "Waiting for human approval: high-risk path";
  return "Proceed: within auto-approval boundary";
}

function recommendationText(lang, decision) {
  const selected = copy[lang] || copy.en;
  if (decision === "block") return selected.recommendationBlock;
  if (decision === "await_human_approval") return selected.recommendationHuman;
  return selected.recommendationProceed;
}

function collectState() {
  return {
    scenario: document.getElementById("scenario-input").value,
    risk: document.getElementById("risk-input").value,
    pii: document.getElementById("pii-input").checked,
    external: document.getElementById("external-input").checked,
    deterministic: document.getElementById("deterministic-input").checked
  };
}

function applyPreset(name) {
  const preset = presets[name];
  if (!preset) return;
  document.getElementById("scenario-input").value = preset.scenario;
  document.getElementById("risk-input").value = preset.risk;
  document.getElementById("pii-input").checked = preset.pii;
  document.getElementById("external-input").checked = preset.external;
  document.getElementById("deterministic-input").checked = preset.deterministic;
}

function setPresetActive(name) {
  document.querySelectorAll(".preset-btn").forEach((btn) => {
    btn.classList.toggle("active", btn.dataset.preset === name);
  });
}

function describeDelta(lang, current, previous) {
  const selected = copy[lang] || copy.en;
  if (!previous) return `${selected.deltaPrefix} ${selected.deltaNone}`;

  const changes = [];
  if (previous.decision !== current.decision) {
    changes.push(`decision ${previous.decision} -> ${current.decision}`);
  }
  if (previous.approval_tier !== current.approval_tier) {
    changes.push(`tier ${previous.approval_tier} -> ${current.approval_tier}`);
  }
  if (previous.human_gate_required !== current.human_gate_required) {
    changes.push(`human_gate ${previous.human_gate_required} -> ${current.human_gate_required}`);
  }
  if (changes.length === 0) return `${selected.deltaPrefix} ${selected.deltaNone}`;
  return `${selected.deltaPrefix} ${changes.join(" | ")}`;
}

function riskScore(state, result) {
  const base = state.risk === "low" ? 26 : state.risk === "medium" ? 54 : 80;
  const pii = state.pii ? 14 : 0;
  const ext = state.external ? 10 : 0;
  const det = state.deterministic ? 0 : 22;
  const high = result.approvalTier === "high" ? 6 : 0;
  return Math.max(0, Math.min(100, base + pii + ext + det + high));
}

function renderStatusList(targetId, rows) {
  const list = document.getElementById(targetId);
  if (!list) return;
  list.innerHTML = "";

  rows.forEach((row) => {
    const li = document.createElement("li");
    li.className = "status-item";

    const label = document.createElement("span");
    label.textContent = row.label;

    const tag = document.createElement("span");
    tag.className = `status-tag ${row.status}`;
    tag.textContent = row.status;

    li.appendChild(label);
    li.appendChild(tag);
    list.appendChild(li);
  });
}

function renderCockpit(lang, state, result) {
  const score = riskScore(state, result);
  const fill = document.getElementById("risk-meter-fill");
  const meterValue = document.getElementById("risk-meter-value");
  if (fill) fill.style.width = `${score}%`;
  if (meterValue) meterValue.textContent = `${score}%`;

  const pill = document.getElementById("verdict-pill");
  if (pill) {
    pill.className = `verdict-pill ${result.decision}`;
    if (lang === "ko") {
      pill.textContent = result.decision === "block"
        ? "BLOCK"
        : result.decision === "await_human_approval"
          ? "HUMAN GATE"
          : "PROCEED";
    } else {
      pill.textContent = result.decision === "block"
        ? "BLOCK"
        : result.decision === "await_human_approval"
          ? "HUMAN GATE"
          : "PROCEED";
    }
  }

  const gateRows = [
    { label: "intake", status: "done" },
    { label: "policy-schema", status: "done" },
    { label: "scope-gate", status: "done" },
    { label: "human-gate", status: result.humanGateRequired ? "current" : "pending" },
    { label: "release", status: result.decision === "block" ? "blocked" : "pending" }
  ];
  if (result.decision === "proceed") {
    gateRows[3].status = "pending";
    gateRows[4].status = "current";
  }
  if (result.decision === "await_human_approval") {
    gateRows[4].status = "pending";
  }

  const checkRows = result.checks.map((c) => ({
    label: c.name,
    status: c.status
  }));

  renderStatusList("gate-list", gateRows);
  renderStatusList("checks-list", checkRows);
}

function pulseDemoCard() {
  const card = document.querySelector(".demo-card");
  if (!card) return;
  card.classList.remove("flash");
  void card.offsetWidth;
  card.classList.add("flash");
}

function pulseOutput() {
  const output = document.getElementById("demo-output");
  if (!output) return;
  output.classList.remove("flash");
  void output.offsetWidth;
  output.classList.add("flash");
}

function updateEvaluationMeta(nowIso) {
  evaluationCount += 1;
  const at = document.getElementById("evaluated-at");
  const count = document.getElementById("run-count");
  const meta = document.querySelector(".eval-meta");
  if (at) at.textContent = nowIso;
  if (count) count.textContent = String(evaluationCount);
  if (meta) {
    meta.classList.remove("flash");
    void meta.offsetWidth;
    meta.classList.add("flash");
  }
}

function resetRunState() {
  evaluationCount = 0;
  previousSnapshot = null;
  const count = document.getElementById("run-count");
  const at = document.getElementById("evaluated-at");
  if (count) count.textContent = "0";
  if (at) at.textContent = "-";
}

function addXp(amount) {
  let leveled = false;
  gameState.progress.xp += amount;
  while (gameState.progress.xp >= 100) {
    leveled = true;
    gameState.progress.level += 1;
    gameState.progress.xp -= 100;
    gameState.speed = Math.max(70, gameState.speed - 4);
  }
  return leveled;
}

function buildMazeState() {
  const map = [];
  let pellets = 0;
  let spawn = { x: 1, y: 1 };
  MAZE_TEMPLATE.forEach((row, y) => {
    const cells = row.split("");
    cells.forEach((cell, x) => {
      if (cell === "." || cell === "o") pellets += 1;
      if (cell === "P") spawn = { x, y };
    });
    map.push(cells);
  });
  gameState.map = map;
  gameState.pelletsTotal = pellets;
  gameState.pelletsLeft = pellets;
  gameState.player = { ...spawn };
  gameState.ghosts = [
    { x: 9, y: 7, dir: "left", color: "#ef4444" },
    { x: 10, y: 7, dir: "right", color: "#22d3ee" },
    { x: 9, y: 8, dir: "up", color: "#f472b6" }
  ];
}

function canMove(x, y) {
  const row = gameState.map[y];
  if (!row) return false;
  const cell = row[x];
  return cell !== "#" && cell !== undefined;
}

function tryMove(entity, dir) {
  const delta = DIRS[dir];
  if (!delta) return false;
  const nx = entity.x + delta.x;
  const ny = entity.y + delta.y;
  if (!canMove(nx, ny)) return false;
  entity.x = nx;
  entity.y = ny;
  return true;
}

function chooseGhostDir(ghost) {
  const dirs = ["up", "down", "left", "right"];
  const valid = dirs.filter((dir) => canMove(ghost.x + DIRS[dir].x, ghost.y + DIRS[dir].y));
  if (valid.length === 0) return ghost.dir;
  const best = valid.sort((a, b) => {
    const da = Math.abs((ghost.x + DIRS[a].x) - gameState.player.x) + Math.abs((ghost.y + DIRS[a].y) - gameState.player.y);
    const db = Math.abs((ghost.x + DIRS[b].x) - gameState.player.x) + Math.abs((ghost.y + DIRS[b].y) - gameState.player.y);
    return da - db;
  });
  if (Math.random() < 0.7) return best[0];
  return valid[Math.floor(Math.random() * valid.length)];
}

function setFeedback(lang, key) {
  const selected = copy[lang] || copy.en;
  const feedback = document.getElementById("game-feedback");
  if (!feedback) return;
  feedback.className = key === "hit" ? "game-feedback wrong" : "game-feedback correct";
  feedback.textContent = key === "hit" ? selected.gameFeedbackHit : selected.gameFeedbackLevelUp;
}

function handleCollision(lang) {
  gameState.progress.collisions += 1;
  gameState.score = Math.max(0, gameState.score - 25);
  gameState.player = { x: 1, y: 8 };
  gameState.ghosts = [
    { x: 9, y: 7, dir: "left", color: "#ef4444" },
    { x: 10, y: 7, dir: "right", color: "#22d3ee" },
    { x: 9, y: 8, dir: "up", color: "#f472b6" }
  ];
  setFeedback(lang, "hit");
}

function drawGame() {
  const canvas = document.getElementById("game-canvas");
  if (!(canvas instanceof HTMLCanvasElement)) return;
  const ctx = canvas.getContext("2d");
  if (!ctx) return;

  ctx.fillStyle = "#0b1020";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  for (let y = 0; y < gameState.map.length; y += 1) {
    for (let x = 0; x < gameState.map[y].length; x += 1) {
      const c = gameState.map[y][x];
      const px = x * TILE;
      const py = y * TILE;
      if (c === "#") {
        ctx.fillStyle = "#1f4fa8";
        ctx.fillRect(px, py, TILE, TILE);
      } else if (c === "." || c === "o") {
        ctx.fillStyle = c === "o" ? "#fde047" : "#bfdbfe";
        const r = c === "o" ? 4 : 2;
        ctx.beginPath();
        ctx.arc(px + TILE / 2, py + TILE / 2, r, 0, Math.PI * 2);
        ctx.fill();
      }
    }
  }

  ctx.fillStyle = "#facc15";
  ctx.beginPath();
  ctx.arc(gameState.player.x * TILE + TILE / 2, gameState.player.y * TILE + TILE / 2, TILE * 0.36, 0, Math.PI * 2);
  ctx.fill();

  gameState.ghosts.forEach((ghost) => {
    ctx.fillStyle = ghost.color;
    ctx.beginPath();
    ctx.arc(ghost.x * TILE + TILE / 2, ghost.y * TILE + TILE / 2, TILE * 0.33, 0, Math.PI * 2);
    ctx.fill();
  });
}

function updateArcade(lang) {
  if (!gameState.running) return;

  if (gameState.pendingDir && tryMove(gameState.player, gameState.pendingDir)) {
    gameState.currentDir = gameState.pendingDir;
  } else {
    tryMove(gameState.player, gameState.currentDir);
  }

  const cell = gameState.map[gameState.player.y][gameState.player.x];
  if (cell === "." || cell === "o") {
    gameState.map[gameState.player.y][gameState.player.x] = " ";
    gameState.pelletsLeft -= 1;
    const gain = cell === "o" ? 20 : 8;
    gameState.score += gain;
    gameState.progress.pelletsCollected += 1;
    gameState.progress.dailyCollected += 1;
    const leveled = addXp(cell === "o" ? 8 : 3);
    if (leveled) {
      runArcadeLoop(lang);
      setFeedback(lang, "levelup");
    }
    gameState.progress.bestScore = Math.max(gameState.progress.bestScore, gameState.score);
  }

  gameState.ghosts.forEach((ghost) => {
    const dir = chooseGhostDir(ghost);
    ghost.dir = dir;
    tryMove(ghost, dir);
  });

  const hit = gameState.ghosts.some((ghost) => ghost.x === gameState.player.x && ghost.y === gameState.player.y);
  if (hit) handleCollision(lang);

  if (gameState.pelletsLeft <= 0) {
    buildMazeState();
    gameState.progress.level += 1;
    gameState.speed = Math.max(65, gameState.speed - 5);
    addXp(25);
    setFeedback(lang, "levelup");
    runArcadeLoop(lang);
  }

  saveGameProgress();
  renderGame(lang);
}

function runArcadeLoop(lang) {
  if (gameState.loopHandle) clearInterval(gameState.loopHandle);
  gameState.loopHandle = setInterval(() => updateArcade(lang), gameState.speed);
}

function renderGame(lang) {
  const selected = copy[lang] || copy.en;
  const score = document.getElementById("game-score");
  const best = document.getElementById("game-best");
  const accuracy = document.getElementById("game-accuracy");
  const level = document.getElementById("game-level");
  const xp = document.getElementById("game-xp");
  const progressFill = document.getElementById("game-progress-fill");
  const dailyFill = document.getElementById("game-daily-fill");
  const dailyText = document.getElementById("game-daily-text");
  const badgeList = document.getElementById("game-badges-list");
  const feedback = document.getElementById("game-feedback");

  const stable = gameState.progress.pelletsCollected + gameState.progress.collisions * 8;
  const accuracyValue = stable > 0
    ? Math.round((gameState.progress.pelletsCollected / stable) * 100)
    : 0;
  const dailyPct = Math.min(100, Math.round((gameState.progress.dailyCollected / 120) * 100));

  if (score) score.textContent = String(gameState.score);
  if (best) best.textContent = String(gameState.progress.bestScore);
  if (accuracy) accuracy.textContent = `${accuracyValue}%`;
  if (level) level.textContent = String(gameState.progress.level);
  if (xp) xp.textContent = `${gameState.progress.xp}/100`;
  if (progressFill) progressFill.style.width = `${Math.min(100, gameState.progress.xp)}%`;
  if (dailyFill) dailyFill.style.width = `${dailyPct}%`;
  if (dailyText) dailyText.textContent = `${selected.gameDailyMission} (${gameState.progress.dailyCollected}/120)`;
  if (badgeList) {
    badgeList.innerHTML = "";
    const badges = gameBadges(lang);
    if (badges.length === 0) {
      const empty = document.createElement("span");
      empty.className = "game-badge empty";
      empty.textContent = "-";
      badgeList.appendChild(empty);
    } else {
      badges.forEach((name) => {
        const chip = document.createElement("span");
        chip.className = "game-badge";
        chip.textContent = name;
        badgeList.appendChild(chip);
      });
    }
  }
  if (feedback && !feedback.textContent) {
    feedback.className = "game-feedback";
    feedback.textContent = selected.gameFeedbackIdle;
  }
  drawGame();
}

function resetGame(lang) {
  gameState.score = 0;
  gameState.speed = 140;
  gameState.pendingDir = "left";
  gameState.currentDir = "left";
  gameState.running = true;
  buildMazeState();
  const feedback = document.getElementById("game-feedback");
  if (feedback) {
    feedback.className = "game-feedback";
    feedback.textContent = "";
  }
  runArcadeLoop(lang);
  renderGame(lang);
}

function presetNameFromState(state) {
  for (const [name, preset] of Object.entries(presets)) {
    if (
      preset.scenario === state.scenario &&
      preset.risk === state.risk &&
      preset.pii === state.pii &&
      preset.external === state.external &&
      preset.deterministic === state.deterministic
    ) {
      return name;
    }
  }
  return "";
}

async function runDemo(lang) {
  const state = collectState();

  const result = buildDecision(state);
  const payload = {
    version: "v0.2",
    checked_at_utc: new Date().toISOString(),
    governance_path: "mandatory_bridge",
    scenario: scenarioLabel[state.scenario] || state.scenario,
    input: state,
    approval_tier: result.approvalTier,
    human_gate_required: result.humanGateRequired,
    decision_candidate: result.decision,
    checks: result.checks,
    evidence_refs: []
  };

  const digest = await sha256(JSON.stringify(payload));
  payload.evidence_refs.push({ path: "docs/assets/site.js", sha256: digest });

  const summary = document.getElementById("decision-summary");
  if (summary) summary.textContent = summarizeDecision(lang, result);
  const recommendation = document.getElementById("recommendation-line");
  if (recommendation) recommendation.textContent = recommendationText(lang, result.decision);
  const delta = document.getElementById("delta-line");
  if (delta) delta.textContent = describeDelta(lang, payload, previousSnapshot);
  renderCockpit(lang, state, result);
  setPresetActive(presetNameFromState(state));
  pulseDemoCard();
  updateEvaluationMeta(payload.checked_at_utc);

  const output = document.getElementById("demo-output");
  if (output) output.textContent = JSON.stringify(payload, null, 2);
  pulseOutput();
  previousSnapshot = payload;
}

(function init() {
  const selected = detectDefaultLanguage();
  const select = document.getElementById("lang-select");
  if (select) select.value = selected;

  loadGameProgress();
  resetDailyIfNeeded();
  saveGameProgress();
  setText(selected);
  resetGame(selected);
  applyPreset("balanced");
  setPresetActive("balanced");
  runDemo(selected);

  if (select) {
    select.addEventListener("change", (e) => {
      const lang = e.target.value;
      localStorage.setItem("showcase_lang", lang);
      setText(lang);
      runArcadeLoop(lang);
      runDemo(lang);
    });
  }

  const gameReset = document.getElementById("game-reset");
  if (gameReset) {
    gameReset.addEventListener("click", () => {
      const lang = select ? select.value : selected;
      resetGame(lang);
    });
  }

  document.querySelectorAll(".arcade-move").forEach((btn) => {
    btn.addEventListener("click", () => {
      const dir = btn.dataset.dir;
      if (dir && DIRS[dir]) gameState.pendingDir = dir;
    });
  });

  window.addEventListener("keydown", (e) => {
    const keyMap = {
      ArrowUp: "up",
      ArrowDown: "down",
      ArrowLeft: "left",
      ArrowRight: "right"
    };
    const dir = keyMap[e.key];
    if (!dir) return;
    e.preventDefault();
    gameState.pendingDir = dir;
  });

  const runButton = document.getElementById("run-demo");
  if (runButton) {
    runButton.addEventListener("click", () => {
      const lang = select ? select.value : selected;
      resetRunState();
      applyPreset("balanced");
      setPresetActive("balanced");
      runDemo(lang);
    });
  }

  ["scenario-input", "risk-input", "pii-input", "external-input", "deterministic-input"].forEach((id) => {
    const node = document.getElementById(id);
    if (!node) return;
    node.addEventListener("change", () => {
      const lang = select ? select.value : selected;
      runDemo(lang);
    });
  });

  document.querySelectorAll(".preset-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      applyPreset(btn.dataset.preset);
      const lang = select ? select.value : selected;
      runDemo(lang);
    });
  });
})();
