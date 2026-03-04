const copy = {
  en: {
    eyebrow: "Governance Architecture",
    title: "One Contract Layer for Independent AI Services",
    subtitle: "Services execute locally, while governance keeps boundaries, deterministic checks, and release gates readable.",
    hierarchyTitle: "Architecture In 3 Layers",
    hierarchyCoreTitle: "1) Core Concept",
    hierarchyCore: [
      "One small governance kernel",
      "Deterministic verdict path",
      "Human release authority stays explicit"
    ],
    hierarchySubTitle: "2) Core Surfaces",
    hierarchySub: [
      "Registry: service boundaries and release rules",
      "Schema: deterministic contract structure",
      "Policy: external execution boundary"
    ],
    hierarchyFlowTitle: "3) Real Application Flow",
    hierarchyFlow: [
      "Service work enters a temporary link",
      "The service runs locally and emits monitoring artifacts",
      "Governance returns proceed, hold, or human gate"
    ],
    languageLabel: "Language",
    whatTitle: "What It Is",
    what: [
      "A central contract kernel shared across independent services",
      "A deterministic validation path for schema, trace, and release gates",
      "A continuous monitoring layer for service hygiene"
    ],
    howTitle: "How It Works",
    how: [
      "Registries define linked-service and external interface boundaries",
      "Validation scripts enforce repository contracts in CI",
      "Temporary-link scans and monitoring checks decide whether release can proceed"
    ],
    whyTitle: "Why It Is Useful",
    why: [
      "Execution stays inside each service",
      "Same evidence leads to the same verdict",
      "Humans can inspect the rules without reading product code"
    ],
    flowTitle: "Code Flow Overview",
    flow: [
      "Input enters the temporary-link path",
      "Schema and DTP contracts are validated by scripts",
      "Monitoring snapshots classify service hygiene",
      "Release outputs: proceed / hold / human gate"
    ],
    demoTitle: "Interactive Governance Simulator",
    demoButton: "Refresh",
    demoNote: "Change inputs to experiment. Press Refresh to reset the run state and restart from the balanced preset.",
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
    recommendationProceed: "Recommendation: release can proceed under the automated gate. Keep the trace attached.",
    recommendationHuman: "Recommendation: pause and request human approval with the evidence summary.",
    recommendationBlock: "Recommendation: block release now. Restore the deterministic path before retry.",
    deltaPrefix: "Compared with previous run:",
    deltaNone: "no meaningful change",
    traceRuleDetFail: "dtp_contract failed -> immediate block",
    traceRuleHighRisk: "release risk escalated -> human gate required",
    traceRuleExternal: "external interface detected -> review warning added",
    traceRulePii: "sensitive data path detected -> data sensitivity warning",
    traceRuleProceed: "all mandatory checks passed -> proceed candidate",
    traceRuleHuman: "no hard fail, but high-risk path -> await_human_approval",
    traceRuleBlock: "at least one hard fail exists -> block candidate",
    quickstartTitle: "Governance Quickstart (3 steps)",
    quickstartStep1: "Define service + external interface scope in registry first.",
    quickstartStep2: "Attach schema contracts, DTP refs, and monitoring artifacts.",
    quickstartStep3: "Wire CI validation and keep the release gate explicit.",
    footer: "Human release ownership remains the final authority."
  },
  ko: {
    eyebrow: "거버넌스 아키텍처",
    title: "독립 AI 서비스를 위한 단일 계약 계층",
    subtitle: "실행은 각 서비스가 맡고, 거버넌스는 경계, 결정적 검증, 릴리스 게이트를 읽기 쉽게 유지합니다.",
    hierarchyTitle: "3단 구조로 보는 아키텍처",
    hierarchyCoreTitle: "1) 핵심 개념",
    hierarchyCore: [
      "작고 단단한 거버넌스 커널",
      "결정적 판정 경로",
      "최종 릴리스 권한은 인간에게 명시적으로 남음"
    ],
    hierarchySubTitle: "2) 핵심 표면",
    hierarchySub: [
      "Registry: 서비스 경계와 릴리스 규칙",
      "Schema: 결정적 계약 구조",
      "Policy: 외부 실행 경계"
    ],
    hierarchyFlowTitle: "3) 실제 적용 흐름",
    hierarchyFlow: [
      "서비스 작업이 temporary link로 진입",
      "서비스가 로컬 실행 후 모니터링 산출물을 남김",
      "거버넌스가 진행, 보류, 인간 게이트를 반환"
    ],
    languageLabel: "언어",
    whatTitle: "무엇인가",
    what: [
      "독립 서비스가 공유하는 중앙 계약 커널",
      "스키마, trace, release gate를 위한 결정적 검증 경로",
      "서비스 위생 상태를 위한 지속 모니터링 계층"
    ],
    howTitle: "어떻게 동작하나",
    how: [
      "레지스트리가 linked service와 외부 인터페이스 경계를 정의",
      "검증 스크립트가 CI에서 저장소 계약을 강제",
      "temporary-link 스캔과 모니터링 검사가 release 가능 여부를 판정"
    ],
    whyTitle: "왜 유용한가",
    why: [
      "실행은 각 서비스 내부에 남음",
      "같은 증거는 같은 판정으로 이어짐",
      "제품 코드 없이도 사람이 규칙을 읽을 수 있음"
    ],
    flowTitle: "코드 흐름 개요",
    flow: [
      "입력이 temporary-link 경로로 들어옴",
      "스크립트가 스키마와 DTP 계약을 검증",
      "모니터링 스냅샷이 서비스 위생 상태를 분류",
      "릴리스 출력: 진행 / 보류 / 인간 게이트"
    ],
    demoTitle: "거버넌스 시뮬레이터",
    demoButton: "새로고침",
    demoNote: "입력을 바꿔 실험해 보세요. 새로고침을 누르면 balanced preset 기준으로 다시 시작합니다.",
    presetLabel: "빠른 프리셋",
    presetSafe: "안전한 릴리스",
    presetBalanced: "균형",
    presetRisky: "위험한 푸시",
    cockpitTitle: "결정 코크핏",
    riskMeterLabel: "위험 노출도",
    gateTitle: "거버넌스 게이트",
    checksTitle: "계약 검사",
    traceTitle: "시나리오 트레이스",
    evaluatedLabel: "마지막 평가:",
    runCountLabel: "실행 수:",
    inputScenario: "시나리오",
    inputRisk: "선언된 위험 등급",
    inputPii: "민감한 사용자 데이터 포함",
    inputExternal: "외부 런타임 의존",
    inputDeterministic: "결정적 trace 경로 유지",
    decisionLabel: "결정:",
    recommendationProceed: "권고: 자동 게이트 범위이므로 진행 가능합니다. trace를 유지하세요.",
    recommendationHuman: "권고: 증거 요약과 함께 인간 승인 요청으로 전환하세요.",
    recommendationBlock: "권고: 지금 릴리스를 차단하세요. 결정적 경로를 복구한 뒤 다시 시도하세요.",
    deltaPrefix: "이전 실행 대비:",
    deltaNone: "의미 있는 변화 없음",
    traceRuleDetFail: "dtp_contract 실패 -> 즉시 차단",
    traceRuleHighRisk: "릴리스 위험 상승 -> 인간 게이트 필요",
    traceRuleExternal: "외부 인터페이스 감지 -> 검토 경고 추가",
    traceRulePii: "민감 데이터 경로 감지 -> 데이터 민감도 경고",
    traceRuleProceed: "필수 검증 통과 -> 진행 후보",
    traceRuleHuman: "하드 실패는 없지만 고위험 경로 -> 인간 승인 대기",
    traceRuleBlock: "하드 실패 존재 -> 차단 후보",
    quickstartTitle: "Governance Quickstart (3 steps)",
    quickstartStep1: "서비스/외부 인터페이스 범위를 먼저 고정하세요.",
    quickstartStep2: "스키마 계약, DTP 참조, 모니터링 산출물을 연결하세요.",
    quickstartStep3: "CI 검증을 붙이고 릴리스 게이트를 명시적으로 유지하세요.",
    footer: "최종 릴리스 권한은 인간 운영자에게 남습니다."
  }
};

const scenarioLabel = {
  ui_copy: "ui_copy",
  new_api_capability: "new_api_capability",
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
    scenario: "new_api_capability",
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
    const normalized = String(code).slice(0, 2).toLowerCase();
    if (supported.includes(normalized)) return normalized;
  }
  return "en";
}

function fillList(id, values) {
  const list = document.getElementById(id);
  if (!list) return;
  list.innerHTML = "";
  values.forEach((value) => {
    const item = document.createElement("li");
    item.textContent = value;
    list.appendChild(item);
  });
}

function setText(lang) {
  const selected = copy[lang] || copy.en;
  document.documentElement.lang = lang;

  document.querySelectorAll("[data-i18n]").forEach((node) => {
    const key = node.getAttribute("data-i18n");
    if (key && selected[key]) node.textContent = selected[key];
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
  return [...new Uint8Array(hash)].map((byte) => byte.toString(16).padStart(2, "0")).join("");
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

function buildDecision(state) {
  const checks = [
    { name: "boundary_contract", status: "pass" },
    { name: "schema_contract", status: "pass" },
    { name: "monitoring_contract", status: state.external ? "warn" : "pass" }
  ];

  checks.push({
    name: "dtp_contract",
    status: state.deterministic ? "pass" : "fail"
  });

  if (state.pii) {
    checks.push({ name: "data_sensitivity_gate", status: "warn" });
  }

  let approvalTier = state.risk;
  let humanGateRequired = state.risk === "high";

  if (state.pii || state.scenario === "prod_secret" || state.scenario === "policy_change") {
    approvalTier = "high";
    humanGateRequired = true;
  }

  const hasFail = checks.some((check) => check.status === "fail");
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
  const external = state.external ? 10 : 0;
  const deterministicPenalty = state.deterministic ? 0 : 22;
  const highApproval = result.approvalTier === "high" ? 6 : 0;
  return Math.max(0, Math.min(100, base + pii + external + deterministicPenalty + highApproval));
}

function renderStatusList(targetId, rows) {
  const list = document.getElementById(targetId);
  if (!list) return;
  list.innerHTML = "";

  rows.forEach((row) => {
    const item = document.createElement("li");
    item.className = "status-item";

    const label = document.createElement("span");
    label.textContent = row.label;

    const tag = document.createElement("span");
    tag.className = `status-tag ${row.status}`;
    tag.textContent = row.status;

    item.appendChild(label);
    item.appendChild(tag);
    list.appendChild(item);
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
    pill.textContent = result.decision === "block"
      ? "BLOCK"
      : result.decision === "await_human_approval"
        ? "HUMAN GATE"
        : "PROCEED";
  }

  const gateRows = [
    { label: "intake-scan", status: "done" },
    { label: "pre-exec-scan", status: "done" },
    { label: "monitoring-sync", status: state.external ? "current" : "done" },
    { label: "review-gate", status: result.humanGateRequired ? "current" : "pending" },
    { label: "release", status: result.decision === "block" ? "blocked" : "pending" }
  ];

  if (result.decision === "proceed") {
    gateRows[3].status = "pending";
    gateRows[4].status = "current";
  }

  renderStatusList("gate-list", gateRows);
  renderStatusList("checks-list", result.checks.map((check) => ({
    label: check.name,
    status: check.status
  })));
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
  const target = document.getElementById("trace-list");
  if (!target) return;
  target.innerHTML = "";

  buildTraceLines(lang, state, result).forEach((line) => {
    const item = document.createElement("li");
    item.textContent = line;
    target.appendChild(item);
  });
}

function pulseNode(selector) {
  const node = document.querySelector(selector);
  if (!node) return;
  node.classList.remove("flash");
  void node.offsetWidth;
  node.classList.add("flash");
}

function updateEvaluationMeta(timestamp) {
  evaluationCount += 1;
  const at = document.getElementById("evaluated-at");
  const count = document.getElementById("run-count");
  if (at) at.textContent = timestamp;
  if (count) count.textContent = String(evaluationCount);
  pulseNode(".eval-meta");
}

function resetRunState() {
  evaluationCount = 0;
  previousSnapshot = null;
  const count = document.getElementById("run-count");
  const at = document.getElementById("evaluated-at");
  if (count) count.textContent = "0";
  if (at) at.textContent = "-";
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
  document.querySelectorAll(".preset-btn").forEach((button) => {
    button.classList.toggle("active", button.dataset.preset === name);
  });
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
    version: "v0.7",
    checked_at_utc: new Date().toISOString(),
    governance_path: "temporary_link_kernel",
    scenario: scenarioLabel[state.scenario] || state.scenario,
    input: state,
    approval_tier: result.approvalTier,
    human_gate_required: result.humanGateRequired,
    decision: result.decision,
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
  pulseNode(".demo-card");
  updateEvaluationMeta(payload.checked_at_utc);

  const output = document.getElementById("demo-output");
  if (output) output.textContent = JSON.stringify(payload, null, 2);
  pulseNode("#demo-output");

  previousSnapshot = payload;
}

(function init() {
  const initialLang = detectDefaultLanguage();
  const select = document.getElementById("lang-select");
  if (select) select.value = initialLang;

  setText(initialLang);
  applyPreset("balanced");
  setPresetActive("balanced");
  runDemo(initialLang);

  if (select) {
    select.addEventListener("change", (event) => {
      const lang = event.target.value;
      localStorage.setItem("showcase_lang", lang);
      setText(lang);
      runDemo(lang);
    });
  }

  const runButton = document.getElementById("run-demo");
  if (runButton) {
    runButton.addEventListener("click", () => {
      const lang = select ? select.value : initialLang;
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
      const lang = select ? select.value : initialLang;
      runDemo(lang);
    });
  });

  document.querySelectorAll(".preset-btn").forEach((button) => {
    button.addEventListener("click", () => {
      applyPreset(button.dataset.preset);
      const lang = select ? select.value : initialLang;
      runDemo(lang);
    });
  });
})();
