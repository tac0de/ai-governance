const scopeSelect = document.getElementById("scope-select");
const approvalToggle = document.getElementById("approval-toggle");
const reflectionToggle = document.getElementById("reflection-toggle");
const decisionPill = document.getElementById("decision-pill");
const decisionTitle = document.getElementById("decision-title");
const decisionBody = document.getElementById("decision-body");
const decisionPoints = document.getElementById("decision-points");

function pointList(items) {
  decisionPoints.innerHTML = "";
  items.forEach((item) => {
    const li = document.createElement("li");
    li.textContent = item;
    decisionPoints.appendChild(li);
  });
}

function renderDecision() {
  const scope = scopeSelect.value;
  const approved = approvalToggle.checked;
  const reflectionBlocked = reflectionToggle.checked;

  let state = "proceed";
  let title = "Scoped cleanup is release-ready.";
  let body = "The change stays within approved scope and no blocking reflection debt exists.";
  let points = [
    "API-key link auth assumed active.",
    "Cleanup stays inside approved scope.",
    "Release gate sees no blocking reflection debt."
  ];

  if (reflectionBlocked) {
    state = "block";
    title = "Release is blocked by unresolved reflection debt.";
    body = "High-severity reflection actions remain overdue, so production cannot proceed.";
    points = [
      "Reflection gate is red.",
      "Overdue high-severity action must be closed or downgraded.",
      "Approval receipt alone is not enough."
    ];
  } else if (scope === "runtime" && !approved) {
    state = "block";
    title = "Runtime cleanup cannot proceed.";
    body = "Changes outside governance/ need an active approval receipt and rollback-linked evidence.";
    points = [
      "Requested scope touches runtime surface.",
      "Approval receipt is missing.",
      "Release stays blocked."
    ];
  } else if (scope !== "governance-only") {
    state = approved ? "review" : "block";
    title = approved ? "Human review remains required." : "Cleanup scope is not approved.";
    body = approved
      ? "Out-of-governance cleanup is permitted, but the release path still expects explicit human review."
      : "Repository-wide scan found an external cleanup target without approval coverage.";
    points = approved
      ? [
          "Approval receipt is active.",
          "Cleanup target extends beyond governance/.",
          "Proceed only after human review."
        ]
      : [
          "Cleanup target extends beyond governance/.",
          "Approval receipt is inactive.",
          "Release remains blocked."
        ];
  }

  decisionPill.textContent = state === "review" ? "human review" : state;
  decisionPill.className = `decision-pill ${state}`;
  decisionTitle.textContent = title;
  decisionBody.textContent = body;
  pointList(points);
}

[scopeSelect, approvalToggle, reflectionToggle].forEach((input) => {
  input.addEventListener("input", renderDecision);
});

renderDecision();
