const copy = {
  en: {
    eyebrow: "Governance Architecture",
    title: "One Control Layer for Multi-Agent AI Systems",
    subtitle: "This site explains the architecture in plain language. Policy, approval, trace, and service boundaries are controlled by one deterministic governance core.",
    languageLabel: "Language",
    whatTitle: "What It Is",
    what: [
      "A central rule system that all services must follow",
      "A structure for both developers and non-developers to make safe decisions",
      "A way to keep AI execution reproducible, reviewable, and auditable"
    ],
    howTitle: "How It Works",
    how: [
      "Policies and schemas define what is allowed",
      "Services and MCPs are registered and validated by CI",
      "High-risk changes require explicit human approval"
    ],
    whyTitle: "Why It Matters",
    why: [
      "Prevents hidden behavior drift between services",
      "Keeps authority clear: AI proposes, human approves",
      "Makes incident response faster with deterministic traces"
    ],
    flowTitle: "4-Step Operating Flow",
    flow: [
      "1) Agent proposes change with evidence",
      "2) Governance validates policy and schema contracts",
      "3) Risk tier determines whether human gate is mandatory",
      "4) Approved change is deployed with trace linkage"
    ],
    demoTitle: "Live Demo: Decision Preview",
    demoButton: "Generate Preview",
    demoNote: "Creates a simple governance decision preview so anyone can understand what is checked before release.",
    contactTitle: "Contact",
    contactText: "For collaboration, reach out by email.",
    footer: "Human System Architect remains final release authority."
  },
  ko: {
    eyebrow: "거버넌스 아키텍처",
    title: "멀티 에이전트 AI를 위한 단일 통제 계층",
    subtitle: "이 사이트는 아키텍처를 쉬운 언어로 설명합니다. 정책, 승인, 트레이스, 서비스 경계는 하나의 결정적 거버넌스 코어로 통제됩니다.",
    languageLabel: "언어",
    whatTitle: "무엇인가",
    what: [
      "모든 서비스가 반드시 따르는 중앙 규칙 체계",
      "개발자/비개발자 모두가 안전하게 의사결정하도록 돕는 구조",
      "AI 실행을 재현 가능·검토 가능·감사 가능하게 만드는 방식"
    ],
    howTitle: "어떻게 동작하나",
    how: [
      "정책과 스키마가 허용 범위를 정의",
      "서비스와 MCP를 레지스트리에 등록하고 CI에서 검증",
      "고위험 변경은 명시적 인간 승인 필수"
    ],
    whyTitle: "왜 중요한가",
    why: [
      "서비스 간 숨은 동작 드리프트를 방지",
      "권한 구조를 명확화: AI는 제안, 인간은 승인",
      "결정적 트레이스로 장애 대응 속도 향상"
    ],
    flowTitle: "운영 4단계",
    flow: [
      "1) 에이전트가 증거와 함께 변경 제안",
      "2) 거버넌스가 정책/스키마 계약 검증",
      "3) 리스크 등급으로 인간 게이트 필요 여부 결정",
      "4) 승인 후 트레이스 연계 배포"
    ],
    demoTitle: "라이브 데모: 의사결정 미리보기",
    demoButton: "미리보기 생성",
    demoNote: "릴리스 전에 무엇을 검증하는지 누구나 이해할 수 있도록 간단한 거버넌스 결정을 생성합니다.",
    contactTitle: "연락",
    contactText: "협업 문의는 이메일로 연락주세요.",
    footer: "최종 릴리스 권한은 Human System Architect에게 있습니다."
  },
  ja: {
    eyebrow: "ガバナンスアーキテクチャ",
    title: "マルチエージェントAIのための単一統制レイヤー",
    subtitle: "このサイトはアーキテクチャを平易な言葉で説明します。ポリシー、承認、トレース、サービス境界は1つの決定論的ガバナンスコアで統制されます。",
    languageLabel: "言語",
    whatTitle: "これは何か",
    what: [
      "すべてのサービスが従う中央ルール体系",
      "開発者/非開発者の双方が安全に判断できる運用構造",
      "AI実行を再現可能・検証可能・監査可能にする仕組み"
    ],
    howTitle: "どう動くか",
    how: [
      "ポリシーとスキーマが許可範囲を定義",
      "サービスとMCPをレジストリ登録しCIで検証",
      "高リスク変更は明示的な人間承認が必須"
    ],
    whyTitle: "なぜ重要か",
    why: [
      "サービス間の隠れた挙動ドリフトを防止",
      "権限を明確化: AIは提案、人間は承認",
      "決定論的トレースでインシデント対応を高速化"
    ],
    flowTitle: "運用フロー（4ステップ）",
    flow: [
      "1) エージェントが証拠付きで変更提案",
      "2) ガバナンスがポリシー/スキーマ契約を検証",
      "3) リスク階層で人間ゲート必須かを判定",
      "4) 承認後、トレース連携でデプロイ"
    ],
    demoTitle: "ライブデモ: 判定プレビュー",
    demoButton: "プレビュー生成",
    demoNote: "リリース前に何を検証するかを誰でも理解できるよう、簡易ガバナンス判定を生成します。",
    contactTitle: "連絡先",
    contactText: "協業の連絡はメールでお願いします。",
    footer: "最終リリース権限はHuman System Architectにあります。"
  },
  zh: {
    eyebrow: "治理架构",
    title: "面向多智能体AI的统一控制层",
    subtitle: "本网站用通俗语言解释该架构。策略、审批、追踪和服务边界由同一个确定性治理核心统一控制。",
    languageLabel: "语言",
    whatTitle: "它是什么",
    what: [
      "所有服务必须遵循的中央规则系统",
      "让开发者与非开发者都能安全决策的结构",
      "使AI执行可复现、可审查、可审计的方法"
    ],
    howTitle: "如何运作",
    how: [
      "策略与Schema定义允许范围",
      "服务与MCP进入注册表并由CI验证",
      "高风险变更必须经过明确人工审批"
    ],
    whyTitle: "为什么重要",
    why: [
      "防止服务间隐藏行为漂移",
      "明确权限关系：AI提议，人类批准",
      "借助确定性追踪加速故障响应"
    ],
    flowTitle: "4步运行流程",
    flow: [
      "1) 智能体提交带证据的变更提议",
      "2) 治理层校验策略/Schema契约",
      "3) 根据风险等级判断是否必须人工闸门",
      "4) 批准后按追踪链路发布"
    ],
    demoTitle: "实时演示：决策预览",
    demoButton: "生成预览",
    demoNote: "生成简化治理决策预览，让任何人都能理解发布前检查项。",
    contactTitle: "联系",
    contactText: "合作沟通请通过邮箱联系。",
    footer: "最终发布权限由 Human System Architect 持有。"
  }
};

function detectDefaultLanguage() {
  const supported = ["en", "ko", "ja", "zh"];
  const stored = localStorage.getItem("showcase_lang");
  if (stored && supported.includes(stored)) return stored;

  const browserCandidates = [
    ...(navigator.languages || []),
    navigator.language || "en"
  ];

  for (const code of browserCandidates) {
    const normalized = String(code).slice(0, 2).toLowerCase();
    if (supported.includes(normalized)) return normalized;
  }

  return "en";
}

function fillList(id, values, ordered = false) {
  const list = document.getElementById(id);
  if (!list) return;
  list.innerHTML = "";
  values.forEach((item) => {
    const li = document.createElement("li");
    li.textContent = item;
    list.appendChild(li);
  });

  if (ordered) {
    list.setAttribute("role", "list");
  }
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
  fillList("flow-list", selected.flow, true);
}

async function sha256(text) {
  const bytes = new TextEncoder().encode(text);
  const hash = await crypto.subtle.digest("SHA-256", bytes);
  return [...new Uint8Array(hash)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

async function runDemo(lang) {
  const now = new Date().toISOString();
  const payload = {
    version: "v0.1",
    checked_at_utc: now,
    context: "public-architecture-explainer",
    governance_path: "mandatory_bridge",
    human_gate_required: true,
    approval_tier: "high",
    decision_candidate: "await_human_approval",
    checks: [
      { name: "policy_contract", status: "pass" },
      { name: "schema_contract", status: "pass" },
      { name: "trace_determinism", status: "pass" }
    ],
    owner: "Human System Architect",
    preview_language: lang,
    evidence_refs: []
  };

  const digest = await sha256(JSON.stringify(payload));
  payload.evidence_refs.push({ path: "docs/index.html", sha256: digest });

  const output = document.getElementById("demo-output");
  output.textContent = JSON.stringify(payload, null, 2);
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
})();
