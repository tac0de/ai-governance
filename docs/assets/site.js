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

function animateDecision(state) {
  if (!gsapReady || prefersReducedMotion) {
    return;
  }

  const tintScale = state === "block" ? 1.08 : 1;
  const trailTravel = state === "proceed" ? 0 : state === "review" ? 36 : 72;
  const trailOpacity = state === "block" ? 0.92 : state === "review" ? 0.78 : 0.66;

  window.gsap.killTweensOf([decisionPanel, decisionPill, stateBand, trailPathGlow, trailNodes]);
  window.gsap.fromTo(
    decisionPanel,
    { y: 20, autoAlpha: 0.82 },
    { y: 0, autoAlpha: 1, duration: 0.48, ease: "power3.out" }
  );
  window.gsap.fromTo(
    decisionPill,
    { y: 10, scale: 0.92, autoAlpha: 0.8 },
    { y: 0, scale: 1, autoAlpha: 1, duration: 0.42, ease: "back.out(1.7)" }
  );
  window.gsap.fromTo(
    stateBand,
    { scaleX: 0.74, opacity: 0.16 },
    { scaleX: tintScale, opacity: 0.5, duration: 0.58, ease: "power2.out" }
  );
  if (trailPathGlow) {
    window.gsap.fromTo(
      trailPathGlow,
      { strokeDashoffset: trailTravel + 120, opacity: 0.18 },
      { strokeDashoffset: trailTravel, opacity: trailOpacity, duration: 0.72, ease: "power2.out" }
    );
  }
  if (trailNodes.length) {
    window.gsap.fromTo(
      trailNodes,
      { scale: 0.82, autoAlpha: 0.5 },
      { scale: 1, autoAlpha: 1, duration: 0.36, stagger: 0.06, ease: "back.out(1.5)" }
    );
  }
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
    "API-key link auth is assumed active.",
    "Cleanup stays inside the approved mutation scope.",
    "Release gate sees no blocking reflection debt."
  ];

  if (reflectionBlocked) {
    state = "block";
    title = "Release is blocked by unresolved reflection debt.";
    body = "High-severity reflection actions remain overdue, so production cannot proceed even when approvals exist.";
    points = [
      "Reflection gate is red.",
      "An overdue high-severity action must be closed or downgraded.",
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
    .from(".hero-ring, .hero-core, .hero-axis, .hero-beam", { scale: 0.86, autoAlpha: 0, duration: 0.8, stagger: 0.06 }, "-=0.62");

  window.gsap.to(".ambient-a", {
    x: 54,
    y: 28,
    scale: 1.08,
    duration: 12,
    repeat: -1,
    yoyo: true,
    ease: "sine.inOut"
  });
  window.gsap.to(".ambient-b", {
    x: -34,
    y: 32,
    scale: 0.96,
    duration: 18,
    repeat: -1,
    yoyo: true,
    ease: "sine.inOut"
  });
  window.gsap.to(".ambient-c", {
    x: -24,
    y: -30,
    duration: 15,
    repeat: -1,
    yoyo: true,
    ease: "sine.inOut"
  });
  window.gsap.to(".ambient-d", {
    x: 26,
    y: -24,
    scale: 1.14,
    duration: 13,
    repeat: -1,
    yoyo: true,
    ease: "sine.inOut"
  });
  window.gsap.to(".orbit-a", {
    rotation: -10,
    x: 14,
    y: 10,
    duration: 22,
    repeat: -1,
    yoyo: true,
    ease: "sine.inOut"
  });
  window.gsap.to(".orbit-b", {
    rotation: -16,
    x: -18,
    y: 14,
    duration: 18,
    repeat: -1,
    yoyo: true,
    ease: "sine.inOut"
  });
  window.gsap.to(".hero-beam.beam-a", {
    rotation: 18,
    duration: 14,
    repeat: -1,
    yoyo: true,
    ease: "sine.inOut"
  });
  window.gsap.to(".hero-beam.beam-b", {
    rotation: 10,
    x: 10,
    duration: 9,
    repeat: -1,
    yoyo: true,
    ease: "sine.inOut"
  });

  window.gsap.utils.toArray(".strip p").forEach((item, index) => {
    window.gsap.from(item, {
      scrollTrigger: {
        trigger: item,
        start: "top 92%"
      },
      y: 24,
      autoAlpha: 0,
      duration: 0.72,
      delay: index * 0.04,
      ease: "power3.out"
    });
  });

  window.gsap.utils.toArray(".proof-line").forEach((line, index) => {
    const direction = index % 2 === 0 ? -1 : 1;
    window.gsap.from(line, {
      scrollTrigger: {
        trigger: line,
        start: "top 88%"
      },
      x: direction * 28,
      autoAlpha: 0,
      duration: 0.82,
      ease: "power3.out"
    });
    window.gsap.to(line, {
      x: direction * 12,
      ease: "none",
      scrollTrigger: {
        trigger: line,
        start: "top bottom",
        end: "bottom top",
        scrub: 1
      }
    });
  });

  window.gsap.from(".demo-intro", {
    scrollTrigger: {
      trigger: ".demo",
      start: "top 84%"
    },
    y: 32,
    autoAlpha: 0,
    duration: 0.82,
    ease: "power3.out"
  });

  window.gsap.from(".demo-stage", {
    scrollTrigger: {
      trigger: ".demo-stage",
      start: "top 84%"
    },
    y: 38,
    autoAlpha: 0,
    duration: 0.92,
    ease: "power3.out"
  });

  window.gsap.to(".demo-stage", {
    "--stage-shift": 1,
    ease: "none",
    scrollTrigger: {
      trigger: ".demo-stage",
      start: "top 80%",
      end: "bottom top",
      scrub: 1.1
    }
  });

  if (trailPathGlow) {
    window.gsap.to(trailPathGlow, {
      strokeDashoffset: 0,
      duration: 4.6,
      repeat: -1,
      yoyo: true,
      ease: "sine.inOut"
    });
  }

  if (trailNodes.length) {
    window.gsap.to(trailNodes, {
      scale: 1.18,
      duration: 1.6,
      stagger: 0.18,
      repeat: -1,
      yoyo: true,
      ease: "sine.inOut",
      transformOrigin: "center center"
    });
  }
}

[scopeSelect, approvalToggle, reflectionToggle].forEach((input) => {
  input.addEventListener("input", renderDecision);
});

renderDecision();
initHeroPointer();
initAnimations();
