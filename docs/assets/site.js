const copy = {
  en: {
    eyebrow: "Governance Architecture",
    title: "One Control Layer for Multi-Agent AI Systems",
    subtitle: "This explains your architecture in plain language: agents can execute, but governance defines boundaries, and humans keep final authority.",
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
      "1) Input arrives as intent + evidence refs",
      "2) Schema and policy contracts are validated by scripts",
      "3) Registry/allowlist gates evaluate service and MCP scope",
      "4) Risk tier outputs: auto / policy+owner / mandatory human gate"
    ],
    demoTitle: "Interactive Governance Simulator",
    demoButton: "Evaluate Decision",
    demoNote: "Change inputs and run. You can see how risk, determinism, and external dependency change the governance verdict.",
    inputScenario: "Scenario",
    inputRisk: "Declared Risk Tier",
    inputPii: "Contains sensitive user data",
    inputExternal: "Depends on external runtime",
    inputDeterministic: "Deterministic trace path maintained",
    decisionLabel: "Decision:",
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
        title: "How To Read The Codebase",
        body: "Start from control/registry for allowed topology, then schemas/ for contracts, then scripts/validate_all.sh for enforcement logic, then services/* and mcps/* for concrete artifacts."
      }
    ],
    contactTitle: "Contact",
    contactText: "If you want to collaborate on this governance architecture, email directly.",
    footer: "Human System Architect remains final release authority."
  },
  ko: {
    eyebrow: "거버넌스 아키텍처",
    title: "멀티 에이전트 AI를 위한 단일 통제 계층",
    subtitle: "에이전트는 실행할 수 있지만, 거버넌스가 경계를 정하고 최종 권한은 인간이 유지한다는 구조를 쉬운 언어로 설명합니다.",
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
      "1) intent + evidence refs 입력",
      "2) 스키마/정책 계약을 스크립트로 검증",
      "3) 레지스트리/allowlist 게이트로 범위 판정",
      "4) 리스크 계층 결과 출력: 자동 / 정책+오너 / 인간 필수"
    ],
    demoTitle: "거버넌스 시뮬레이터",
    demoButton: "판정 실행",
    demoNote: "입력을 바꾸고 실행하면 리스크, 결정성, 외부 의존성에 따라 판정이 어떻게 달라지는지 볼 수 있습니다.",
    inputScenario: "시나리오",
    inputRisk: "선언 리스크 등급",
    inputPii: "민감 사용자 데이터 포함",
    inputExternal: "외부 런타임 의존",
    inputDeterministic: "결정적 트레이스 경로 유지",
    decisionLabel: "판정:",
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
        title: "코드를 읽는 순서",
        body: "control/registry에서 전체 토폴로지, schemas/에서 계약, scripts/validate_all.sh에서 강제 로직을 먼저 보고, 그 다음 services/*, mcps/*를 보면 구조가 바로 잡힙니다."
      }
    ],
    contactTitle: "연락",
    contactText: "이 거버넌스 아키텍처 협업은 이메일로 직접 연락주세요.",
    footer: "최종 릴리스 권한은 Human System Architect에게 있습니다."
  },
  ja: {
    eyebrow: "ガバナンスアーキテクチャ",
    title: "マルチエージェントAIの単一統制レイヤー",
    subtitle: "エージェントは実行できても、境界はガバナンスが定義し、最終権限は人間が持つという設計を平易に説明します。",
    languageLabel: "言語",
    whatTitle: "これは何か",
    what: ["中央ガバナンスコア", "決定論的検証パス", "高リスク変更の人間ゲート"],
    howTitle: "どう動くか",
    how: ["レジストリで範囲定義", "CIで契約検証", "リスク階層で承認方式決定"],
    whyTitle: "なぜ革新的か",
    why: ["ベンダー非依存", "同一証拠なら同一判定", "非開発者にも説明可能"],
    flowTitle: "コードフロー概要",
    flow: ["1) intent入力", "2) 契約検証", "3) 範囲ゲート判定", "4) 承認方式出力"],
    demoTitle: "ガバナンスシミュレーター",
    demoButton: "判定を実行",
    demoNote: "入力条件を変えて判定結果の変化を確認できます。",
    inputScenario: "シナリオ",
    inputRisk: "宣言リスク",
    inputPii: "機微データを含む",
    inputExternal: "外部ランタイム依存",
    inputDeterministic: "決定論的トレース維持",
    decisionLabel: "判定:",
    blogTitle: "短い解説",
    blogs: [
      { title: "この設計の本質", body: "文書ではなく意思決定OSです。" },
      { title: "今なぜ必要か", body: "速度と統制を両立するためです。" },
      { title: "コードの読み方", body: "registry → schema → validateスクリプト → service/mcp の順で読むと把握しやすいです。" }
    ],
    contactTitle: "連絡",
    contactText: "協業はメールでご連絡ください。",
    footer: "最終リリース権限はHuman System Architectにあります。"
  },
  zh: {
    eyebrow: "治理架构",
    title: "多智能体AI的统一控制层",
    subtitle: "本页用通俗语言说明：智能体可以执行，但边界由治理定义，最终权力在人工。",
    languageLabel: "语言",
    whatTitle: "它是什么",
    what: ["中央治理核心", "确定性验证路径", "高风险人工闸门"],
    howTitle: "如何运作",
    how: ["注册表定义范围", "CI执行契约校验", "风险等级决定审批方式"],
    whyTitle: "创新点",
    why: ["供应商无关", "同证据同结论", "非开发者也能理解"],
    flowTitle: "代码流程概览",
    flow: ["1) 输入intent", "2) 契约校验", "3) 范围门禁", "4) 输出审批模式"],
    demoTitle: "治理模拟器",
    demoButton: "执行判定",
    demoNote: "修改输入后可观察治理结论如何变化。",
    inputScenario: "场景",
    inputRisk: "声明风险等级",
    inputPii: "包含敏感数据",
    inputExternal: "依赖外部运行时",
    inputDeterministic: "保持确定性追踪",
    decisionLabel: "结论:",
    blogTitle: "短文",
    blogs: [
      { title: "设计本质", body: "这不是文档，而是决策操作系统。" },
      { title: "为什么需要", body: "要在速度与控制之间取得平衡。" },
      { title: "如何读代码", body: "建议顺序：registry → schema → validate脚本 → service/mcp。" }
    ],
    contactTitle: "联系",
    contactText: "欢迎通过邮箱直接联系协作。",
    footer: "最终发布权限由 Human System Architect 持有。"
  }
};

const scenarioLabel = {
  ui_copy: "ui_copy",
  new_mcp: "new_mcp",
  prod_secret: "prod_secret",
  policy_change: "policy_change"
};

function detectDefaultLanguage() {
  const supported = ["en", "ko", "ja", "zh"];
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
  fillBlog(lang);
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

async function runDemo(lang) {
  const state = {
    scenario: document.getElementById("scenario-input").value,
    risk: document.getElementById("risk-input").value,
    pii: document.getElementById("pii-input").checked,
    external: document.getElementById("external-input").checked,
    deterministic: document.getElementById("deterministic-input").checked
  };

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

  const output = document.getElementById("demo-output");
  if (output) output.textContent = JSON.stringify(payload, null, 2);
}

(function init() {
  const selected = detectDefaultLanguage();
  const select = document.getElementById("lang-select");
  if (select) select.value = selected;

  setText(selected);
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
})();
