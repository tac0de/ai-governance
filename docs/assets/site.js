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
      "Registry: allowed service and MCP contracts",
      "Schema: deterministic contract structure",
      "Policy: execution boundary for external MCP use"
    ],
    hierarchyFlowTitle: "3) Real Application Flow",
    hierarchyFlow: [
      "Service work enters a temporary link",
      "Governance validates schema + DTP + scope",
      "Output is release hold or human-gated release"
    ],
    languageLabel: "Language",
    whatTitle: "What It Is",
    what: [
      "A central governance core shared across all services",
      "A deterministic validation path for schema, trace, and release gates",
      "A human-gated operating model for release decisions"
    ],
    howTitle: "How It Works",
    how: [
      "Registries define linked-service and MCP boundaries",
      "Validation scripts enforce repository contracts in CI",
      "Temporary-link scans decide whether release can proceed"
    ],
    whyTitle: "Why It Is Innovative",
    why: [
      "Agent-vendor independent: governance survives model/tool replacement",
      "Deterministic-by-design: same evidence, same verdict",
      "Scales trust: non-developers can inspect decision logic"
    ],
    flowTitle: "Code Flow Overview",
    flow: [
      "Input enters the temporary-link scan path",
      "Schema and DTP contracts are validated by scripts",
      "Registry gates evaluate service and MCP scope",
      "Release outputs: proceed / hold / human gate"
    ],
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
    traceTitle: "Scenario Trace",
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
    traceRuleDetFail: "dtp_contract failed -> immediate block",
    traceRuleHighRisk: "release risk escalated -> human gate required",
    traceRuleExternal: "external dependency detected -> review warning added",
    traceRulePii: "sensitive data path detected -> data sensitivity warning",
    traceRuleProceed: "all mandatory checks passed -> proceed candidate",
    traceRuleHuman: "no hard fail, but high-risk path -> await_human_approval",
    traceRuleBlock: "at least one hard fail exists -> block candidate",
    quickstartTitle: "Governance Quickstart (3 steps)",
    quickstartStep1: "Define service + MCP scope in registry first.",
    quickstartStep2: "Attach schema contracts and deterministic DTP refs.",
    quickstartStep3: "Wire CI validation and keep the release gate explicit.",
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
      "Registry: 허용 서비스와 MCP 계약",
      "Schema: 결정적 계약 구조",
      "Policy: 외부 MCP 실행 경계"
    ],
    hierarchyFlowTitle: "3) 실제 적용 흐름",
    hierarchyFlow: [
      "서비스 작업이 temporary link로 진입",
      "거버넌스가 스키마+DTP+범위를 검증",
      "출력은 릴리스 보류 또는 인간 승인 대기"
    ],
    languageLabel: "언어",
    whatTitle: "무엇인가",
    what: [
      "모든 서비스가 공유하는 중앙 거버넌스 코어",
      "스키마/트레이스/릴리스 게이트를 결정적으로 검증하는 경로",
      "릴리스 판정에 인간 게이트를 강제하는 운영 모델"
    ],
    howTitle: "어떻게 동작하나",
    how: [
      "레지스트리로 linked service와 MCP 경계를 정의",
      "검증 스크립트가 CI에서 저장소 계약을 강제",
      "temporary-link 스캔이 릴리스 가능 여부를 결정"
    ],
    whyTitle: "무엇이 혁신적인가",
    why: [
      "에이전트 벤더 독립성: 모델/툴 교체에도 거버넌스 유지",
      "결정성 중심 설계: 같은 증거면 같은 판정",
      "신뢰 확장: 비개발자도 의사결정 로직을 해석 가능"
    ],
    flowTitle: "코드 플로우 개요",
    flow: [
      "입력이 temporary-link 스캔 경로로 들어감",
      "스키마/DTP 계약을 스크립트로 검증",
      "레지스트리 게이트로 서비스/MCP 범위 판정",
      "릴리스 결과 출력: 진행 / 보류 / 인간 게이트"
    ],
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
    traceTitle: "시나리오 트레이스",
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
    traceRuleDetFail: "dtp_contract 실패 -> 즉시 차단",
    traceRuleHighRisk: "릴리스 리스크 상향 -> 인간 게이트 필요",
    traceRuleExternal: "외부 의존 감지 -> 검토 경고 추가",
    traceRulePii: "민감 데이터 경로 감지 -> 데이터 민감도 경고",
    traceRuleProceed: "필수 검증 통과 -> 진행 후보",
    traceRuleHuman: "하드 실패는 없지만 고위험 경로 -> 인간 승인 대기",
    traceRuleBlock: "하드 실패 존재 -> 차단 후보",
    quickstartTitle: "Governance Quickstart (3 steps)",
    quickstartStep1: "먼저 registry에 서비스/MCP 범위를 고정하세요.",
    quickstartStep2: "스키마 계약과 결정적 DTP 참조를 연결하세요.",
    quickstartStep3: "CI 검증을 붙이고 릴리스 게이트를 명시적으로 유지하세요.",
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
}

async function sha256(text) {
  const bytes = new TextEncoder().encode(text);
  const hash = await crypto.subtle.digest("SHA-256", bytes);
  return [...new Uint8Array(hash)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

function buildDecision(state) {
  const checks = [];
  checks.push({ name: "boundary_contract", status: "pass" });
  checks.push({ name: "schema_contract", status: "pass" });

  if (!state.deterministic) {
    checks.push({ name: "dtp_contract", status: "fail" });
  } else {
    checks.push({ name: "dtp_contract", status: "pass" });
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
    { label: "intake-scan", status: "done" },
    { label: "pre-exec-scan", status: "done" },
    { label: "scope-gate", status: "done" },
    { label: "review-gate", status: result.humanGateRequired ? "current" : "pending" },
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

function buildTraceLines(lang, state, result) {
  const selected = copy[lang] || copy.en;
  const lines = [];

  if (!state.deterministic) lines.push(selected.traceRuleDetFail);
  if (state.external) lines.push(selected.traceRuleExternal);
  if (state.pii) lines.push(selected.traceRulePii);
  if (result.approvalTier === "high") lines.push(selected.traceRuleHighRisk);
  if (result.decision === "block") lines.push(selected.traceRuleBlock);
  if (result.decision === "await_human_approval") lines.push(selected.traceRuleHuman);
  if (result.decision === "proceed") lines.push(selected.traceRuleProceed);

  return lines;
}

function renderTrace(lang, state, result) {
  const lines = buildTraceLines(lang, state, result);
  const target = document.getElementById("trace-list");
  if (!target) return;
  target.innerHTML = "";
  lines.forEach((line) => {
    const li = document.createElement("li");
    li.textContent = line;
    target.appendChild(li);
  });
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
    version: "v0.3",
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
  renderTrace(lang, state, result);
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

  setText(selected);
  applyPreset("balanced");
  setPresetActive("balanced");
  runDemo(selected);

  if (select) {
    select.addEventListener("change", (e) => {
      const lang = e.target.value;
      localStorage.setItem("showcase_lang", lang);
      setText(lang);
      runDemo(lang);
    });
  }

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
