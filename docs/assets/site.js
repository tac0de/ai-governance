const scopeSelect = document.getElementById("scope-select");
const approvalToggle = document.getElementById("approval-toggle");
const reflectionToggle = document.getElementById("reflection-toggle");
const decisionPill = document.getElementById("decision-pill");
const decisionPanel = document.getElementById("decision-panel");
const decisionTitle = document.getElementById("decision-title");
const decisionBody = document.getElementById("decision-body");
const decisionPoints = document.getElementById("decision-points");
const stateBand = document.getElementById("state-band");
const demoStage = document.getElementById("demo-stage");
const hero = document.querySelector(".hero");
const heroLens = document.querySelector(".hero-lens");
const heroVisual = document.querySelector(".hero-visual");
const trailPathGlow = document.getElementById("trail-path-glow");
const trailNodes = document.querySelectorAll(".trail-node");
const verdictNodes = document.querySelectorAll(".verdict-node");
const heroCore = document.querySelector(".hero-core");
const heroNodeList = document.querySelectorAll(".hero-node");
const promptRegistry = document.getElementById("prompt-registry");
const upgradeLoop = document.getElementById("upgrade-loop");
const upgradeProposal = document.getElementById("upgrade-proposal");

const gsapReady = typeof window.gsap !== "undefined" && typeof window.ScrollTrigger !== "undefined";
const prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

if (gsapReady) {
  window.gsap.registerPlugin(window.ScrollTrigger);
}

function pointList(items) {
  decisionPoints.innerHTML = "";
  items.forEach((item) => {
    const li = document.createElement("li");
    li.textContent = item;
    decisionPoints.appendChild(li);
  });
}

function tintVerdictNodes(state) {
  verdictNodes.forEach((node, index) => {
    node.style.color = state === "proceed"
      ? "rgb(140, 230, 194)"
      : state === "review"
        ? "rgb(244, 204, 117)"
        : "rgb(255, 140, 133)";
    node.style.background = state === "proceed"
      ? `rgba(140, 230, 194, ${0.06 + index * 0.02})`
      : state === "review"
        ? `rgba(244, 204, 117, ${0.06 + index * 0.02})`
        : `rgba(255, 140, 133, ${0.06 + index * 0.02})`;
  });
}

function animateDecision(state) {
  tintVerdictNodes(state);

  if (!gsapReady || prefersReducedMotion) {
    return;
  }

  const tintScale = state === "block" ? 1.1 : state === "review" ? 1.04 : 1;
  const trailTravel = state === "proceed" ? 0 : state === "review" ? 42 : 78;
  const trailOpacity = state === "block" ? 0.94 : state === "review" ? 0.82 : 0.68;
  const nodeColor = state === "proceed" ? "#87e2cb" : state === "review" ? "#f4cc75" : "#ff8c85";

  window.gsap.killTweensOf([decisionPanel, decisionPill, stateBand, trailPathGlow, trailNodes, verdictNodes, heroCore, heroNodeList]);
  window.gsap.fromTo(
    decisionPanel,
    { y: 18, autoAlpha: 0.84 },
    { y: 0, autoAlpha: 1, duration: 0.48, ease: "power3.out" }
  );
  window.gsap.fromTo(
    decisionPill,
    { y: 10, scale: 0.92, autoAlpha: 0.8 },
    { y: 0, scale: 1, autoAlpha: 1, duration: 0.42, ease: "back.out(1.7)" }
  );
  window.gsap.fromTo(
    stateBand,
    { scaleX: 0.74, opacity: 0.18 },
    { scaleX: tintScale, opacity: 0.56, duration: 0.62, ease: "power2.out" }
  );
  if (trailPathGlow) {
    window.gsap.fromTo(
      trailPathGlow,
      { strokeDashoffset: trailTravel + 120, opacity: 0.18 },
      { strokeDashoffset: trailTravel, opacity: trailOpacity, duration: 0.76, ease: "power2.out" }
    );
  }
  if (trailNodes.length) {
    window.gsap.fromTo(
      trailNodes,
      { scale: 0.82, autoAlpha: 0.54 },
      { scale: 1, autoAlpha: 1, duration: 0.36, stagger: 0.06, ease: "back.out(1.5)" }
    );
  }
  if (heroCore) {
    window.gsap.fromTo(heroCore, { boxShadow: "0 0 90px rgba(138, 164, 255, 0.2)" }, {
      boxShadow: `0 0 130px ${nodeColor}55`,
      duration: 0.62,
      ease: "power2.out"
    });
  }
  if (heroNodeList.length) {
    window.gsap.to(heroNodeList, {
      backgroundColor: nodeColor,
      boxShadow: `0 0 20px ${nodeColor}`,
      duration: 0.44,
      stagger: 0.04,
      ease: "power2.out"
    });
  }
  window.gsap.fromTo(
    verdictNodes,
    { y: 8, autoAlpha: 0.52 },
    { y: 0, autoAlpha: 1, duration: 0.3, stagger: 0.05, ease: "power2.out" }
  );
  window.gsap.fromTo(
    decisionPoints.children,
    { y: 12, autoAlpha: 0 },
    { y: 0, autoAlpha: 1, stagger: 0.05, duration: 0.32, delay: 0.12, ease: "power2.out" }
  );
}

function renderDecision() {
  const scope = scopeSelect.value;
  const approved = approvalToggle.checked;
  const reflectionBlocked = reflectionToggle.checked;

  let state = "proceed";
  let title = "Scoped cleanup is release-ready.";
  let body = "The change stays within approved scope and no blocking reflection debt exists.";
  let points = [
    "Link auth is assumed active.",
    "Cleanup stays inside the approved mutation scope.",
    "Release gate sees no blocking reflection debt."
  ];

  if (reflectionBlocked) {
    state = "block";
    title = "Release is blocked by unresolved reflection debt.";
    body = "High-severity reflection actions remain overdue, so production cannot proceed even when approvals exist.";
    points = [
      "Reflection gate is red.",
      "A high-severity overdue action remains open.",
      "Approval receipt alone is not enough."
    ];
  } else if (scope === "runtime" && !approved) {
    state = "block";
    title = "Runtime cleanup cannot proceed.";
    body = "Changes outside governance/ need an active approval receipt, bounded scope, and rollback-linked evidence.";
    points = [
      "Requested scope touches the runtime surface.",
      "Approval receipt is missing.",
      "Release stays blocked."
    ];
  } else if (scope !== "governance-only") {
    state = approved ? "review" : "block";
    title = approved ? "Human review remains required." : "Cleanup scope is not approved.";
    body = approved
      ? "Out-of-governance cleanup is permitted, but the release path still expects explicit human review and audit packaging."
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
  decisionPanel.className = `decision-panel ${state}`;
  stateBand.className = `state-band ${state}`;
  demoStage.className = `demo-stage ${state}`;
  decisionTitle.textContent = title;
  decisionBody.textContent = body;
  pointList(points);
  animateDecision(state);
}

function initHeroPointer() {
  if (!gsapReady || prefersReducedMotion || !hero || !heroLens || !heroVisual) {
    return;
  }

  const moveLensX = window.gsap.quickTo(heroLens, "x", { duration: 0.8, ease: "power3.out" });
  const moveLensY = window.gsap.quickTo(heroLens, "y", { duration: 0.8, ease: "power3.out" });
  const rotateLensX = window.gsap.quickTo(heroLens, "rotationX", { duration: 0.9, ease: "power3.out" });
  const rotateLensY = window.gsap.quickTo(heroLens, "rotationY", { duration: 0.9, ease: "power3.out" });
  const moveVisualY = window.gsap.quickTo(heroVisual, "y", { duration: 1.1, ease: "power3.out" });

  hero.addEventListener("pointermove", (event) => {
    const rect = hero.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const y = event.clientY - rect.top;
    const normalizedX = (x / rect.width - 0.5) * 2;
    const normalizedY = (y / rect.height - 0.5) * 2;

    document.documentElement.style.setProperty("--pointer-x", `${event.clientX}px`);
    document.documentElement.style.setProperty("--pointer-y", `${event.clientY}px`);

    moveLensX(normalizedX * 20);
    moveLensY(normalizedY * 12);
    rotateLensX(normalizedY * -5);
    rotateLensY(normalizedX * 7);
    moveVisualY(normalizedY * -8);
  });

  hero.addEventListener("pointerleave", () => {
    moveLensX(0);
    moveLensY(0);
    rotateLensX(0);
    rotateLensY(0);
    moveVisualY(0);
  });
}

function initAnimations() {
  if (!gsapReady || prefersReducedMotion) {
    return;
  }

  if (trailPathGlow) {
    const trailLength = trailPathGlow.getTotalLength();
    trailPathGlow.style.strokeDasharray = `${trailLength}`;
    trailPathGlow.style.strokeDashoffset = `${trailLength * 0.18}`;
  }

  const intro = window.gsap.timeline({ defaults: { ease: "power3.out" } });

  intro
    .from(".hero .eyebrow", { y: 18, autoAlpha: 0, duration: 0.6 })
    .from(".hero-title-line > span", { yPercent: 118, rotate: 3, autoAlpha: 0, duration: 0.92, stagger: 0.11 }, "-=0.24")
    .from(".hero-copy", { y: 20, autoAlpha: 0, duration: 0.74 }, "-=0.52")
    .from(".hero-actions .button", { y: 16, autoAlpha: 0, duration: 0.52, stagger: 0.08 }, "-=0.48")
    .from(".signal-row span", { y: 12, autoAlpha: 0, duration: 0.45, stagger: 0.05 }, "-=0.42")
    .from(".hero-label", { scale: 0.88, autoAlpha: 0, duration: 0.6, stagger: 0.07 }, "-=0.55")
    .from(".hero-ring, .hero-core, .hero-axis, .hero-beam, .hero-node, .hero-trace", { scale: 0.86, autoAlpha: 0, duration: 0.8, stagger: 0.04 }, "-=0.62");

  window.gsap.to(".ambient-a", { x: 54, y: 28, scale: 1.08, duration: 12, repeat: -1, yoyo: true, ease: "sine.inOut" });
  window.gsap.to(".ambient-b", { x: -34, y: 32, scale: 0.96, duration: 18, repeat: -1, yoyo: true, ease: "sine.inOut" });
  window.gsap.to(".ambient-c", { x: -24, y: -30, duration: 15, repeat: -1, yoyo: true, ease: "sine.inOut" });
  window.gsap.to(".ambient-d", { x: 26, y: -24, scale: 1.14, duration: 13, repeat: -1, yoyo: true, ease: "sine.inOut" });
  window.gsap.to(".ambient-e", { x: -16, y: 18, scale: 1.06, duration: 10, repeat: -1, yoyo: true, ease: "sine.inOut" });
  window.gsap.to(".orbit-a", { rotation: -10, x: 14, y: 10, duration: 22, repeat: -1, yoyo: true, ease: "sine.inOut" });
  window.gsap.to(".orbit-b", { rotation: -16, x: -18, y: 14, duration: 18, repeat: -1, yoyo: true, ease: "sine.inOut" });
  window.gsap.to(".beam-a", { rotation: 18, duration: 14, repeat: -1, yoyo: true, ease: "sine.inOut" });
  window.gsap.to(".beam-b", { rotation: 10, x: 10, duration: 9, repeat: -1, yoyo: true, ease: "sine.inOut" });
  window.gsap.to(".beam-c", { y: -18, duration: 11, repeat: -1, yoyo: true, ease: "sine.inOut" });
  window.gsap.to(".trace-a", { opacity: 0.8, x: 12, duration: 6, repeat: -1, yoyo: true, ease: "sine.inOut" });
  window.gsap.to(".trace-b", { opacity: 0.62, x: -10, duration: 7, repeat: -1, yoyo: true, ease: "sine.inOut" });

  window.gsap.from(".protocol-surface", {
    scrollTrigger: { trigger: ".protocol-surface", start: "top 84%" },
    y: 30,
    autoAlpha: 0,
    duration: 0.84,
    ease: "power3.out"
  });

  window.gsap.from(".closure-card, .dual-card, .prompt-card, .upgrade-card, .proposal-card", {
    scrollTrigger: { trigger: ".closure-surface", start: "top 84%" },
    y: 24,
    autoAlpha: 0,
    duration: 0.56,
    stagger: 0.08,
    ease: "power3.out"
  });

  window.gsap.from(".demo-intro", {
    scrollTrigger: { trigger: ".demo", start: "top 84%" },
    y: 32,
    autoAlpha: 0,
    duration: 0.82,
    ease: "power3.out"
  });

  window.gsap.from(".demo-stage", {
    scrollTrigger: { trigger: ".demo-stage", start: "top 82%" },
    y: 40,
    autoAlpha: 0,
    duration: 0.94,
    ease: "power3.out"
  });

  window.gsap.to(".demo-stage", {
    y: -20,
    ease: "none",
    scrollTrigger: {
      trigger: ".demo-stage",
      start: "top bottom",
      end: "bottom top",
      scrub: 1
    }
  });

  window.gsap.from(".cta-band", {
    scrollTrigger: { trigger: ".cta-band", start: "top 90%" },
    y: 20,
    autoAlpha: 0,
    duration: 0.7,
    ease: "power2.out"
  });
}

function renderPromptRegistry(data) {
  if (!promptRegistry) {
    return;
  }

  promptRegistry.innerHTML = "";
  data.prompts.forEach((prompt) => {
    const card = document.createElement("article");
    card.className = "prompt-card";
    card.innerHTML = `
      <div class="prompt-head">
        <span class="decision-label">${prompt.title}</span>
        <span class="prompt-badge">${prompt.auto_upgrade_on_version_bump ? "auto-upgrade" : "manual"}</span>
      </div>
      <p class="prompt-body">${prompt.purpose}</p>
      <p class="prompt-meta">${prompt.path}</p>
    `;
    promptRegistry.appendChild(card);
  });
}

function renderUpgradeLoop(loop, proposal) {
  if (upgradeLoop) {
    upgradeLoop.innerHTML = `
      <article class="upgrade-card">
        <p class="proof-label">Close Verdict</p>
        <p class="proof-text">v0.7.9 closes on ${loop.current_close_verdict.basis.replaceAll("-", " ")}.</p>
      </article>
      <article class="upgrade-card">
        <p class="proof-label">Next Target</p>
        <p class="proof-text">${loop.next_target_version} becomes the docs evolution release.</p>
      </article>
      <article class="upgrade-card">
        <p class="proof-label">Loop Mode</p>
        <p class="proof-text">${loop.mode.replaceAll("-", " ")} keeps prompts and visuals moving with the version.</p>
      </article>
      <article class="upgrade-card">
        <p class="proof-label">Trigger Events</p>
        <p class="proof-text">${loop.trigger_events.join(" · ")}</p>
      </article>
    `;
  }

  if (upgradeProposal) {
    upgradeProposal.innerHTML = proposal.proposal_items.map((item) => `
      <article class="proposal-card">
        <p class="proof-label">${item.title}</p>
        <p class="proof-text">${item.intent}</p>
      </article>
    `).join("");
  }
}

async function loadDocsSurface() {
  try {
    const [registryResponse, loopResponse, proposalResponse] = await Promise.all([
      fetch("role-prompt-registry.json"),
      fetch("version-upgrade-loop.json"),
      fetch("version-upgrade-proposal.json")
    ]);

    if (!registryResponse.ok || !loopResponse.ok || !proposalResponse.ok) {
      throw new Error("Docs surface fetch failed");
    }

    const registryData = await registryResponse.json();
    const loopData = await loopResponse.json();
    const proposalData = await proposalResponse.json();

    renderPromptRegistry(registryData);
    renderUpgradeLoop(loopData, proposalData);
  } catch (error) {
    if (promptRegistry) {
      promptRegistry.innerHTML = '<article class="prompt-card"><p class="proof-text">Prompt registry unavailable.</p></article>';
    }
    if (upgradeLoop) {
      upgradeLoop.innerHTML = '<article class="upgrade-card"><p class="proof-text">Upgrade loop unavailable.</p></article>';
    }
  }
}

scopeSelect.addEventListener("change", renderDecision);
approvalToggle.addEventListener("change", renderDecision);
reflectionToggle.addEventListener("change", renderDecision);

renderDecision();
loadDocsSurface();
initHeroPointer();
initAnimations();
