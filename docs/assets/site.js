const docElement = document.documentElement;
const gsapReady = typeof window.gsap !== "undefined";
const prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
const finePointer = window.matchMedia("(pointer: fine)").matches;

const signalCanvas = document.getElementById("signal-field");
const heroBoard = document.getElementById("hero-board");
const closePill = document.getElementById("close-pill");
const nextPill = document.getElementById("next-pill");
const closeBasis = document.getElementById("close-basis");
const metricVersion = document.getElementById("metric-version");
const metricTiers = document.getElementById("metric-tiers");
const metricDebt = document.getElementById("metric-debt");
const metricSpecialists = document.getElementById("metric-specialists");
const solutionTierGrid = document.getElementById("solution-tier-grid");
const debtConsole = document.getElementById("debt-console");
const debtDecisionStates = document.getElementById("debt-decision-states");
const specialistBoard = document.getElementById("specialist-board");
const specialistRole = document.getElementById("specialist-role");
const monitoringFields = document.getElementById("monitoring-fields");
const monitoringReceipts = document.getElementById("monitoring-receipts");
const upgradeLoopGrid = document.getElementById("upgrade-loop-grid");
const promptRegistry = document.getElementById("prompt-registry");
const simTierControls = document.getElementById("sim-tier-controls");
const simPostureControls = document.getElementById("sim-posture-controls");
const simTierSummary = document.getElementById("sim-tier-summary");
const simRuntimeSummary = document.getElementById("sim-runtime-summary");
const simSpecialistSummary = document.getElementById("sim-specialist-summary");
const heroTitle = document.querySelector(".hero-title");

const surfaceState = {
  solution: null,
  debt: null,
  specialist: null,
  monitoring: null,
  loop: null,
  registry: null,
  proposal: null
};

const simulatorState = {
  tierId: "tier-2",
  posture: "remediate"
};

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function animateMetric(element, target) {
  if (!element) {
    return;
  }

  const isNumeric = typeof target === "number";
  if (!isNumeric || prefersReducedMotion) {
    element.textContent = String(target);
    return;
  }

  const currentValue = Number.parseInt(element.textContent || "", 10);
  const startValue = Number.isFinite(currentValue) ? currentValue : target;
  if (startValue === target) {
    element.textContent = `${target}`;
    return;
  }

  const state = { value: startValue };
  if (gsapReady) {
    window.gsap.to(state, {
      value: target,
      duration: 1.1,
      ease: "power2.out",
      onUpdate: () => {
        element.textContent = `${Math.round(state.value)}`;
      }
    });
    return;
  }

  const start = performance.now();
  const duration = 1100;

  function tick(now) {
    const progress = Math.min((now - start) / duration, 1);
    const eased = 1 - Math.pow(1 - progress, 3);
    element.textContent = `${Math.round(startValue + (target - startValue) * eased)}`;
    if (progress < 1) {
      requestAnimationFrame(tick);
    }
  }

  requestAnimationFrame(tick);
}

function renderSolutionPackaging(surface) {
  if (!solutionTierGrid || !surface) {
    return;
  }

  solutionTierGrid.innerHTML = surface.tiers.map((tier) => `
    <article class="panel-card" data-tier-id="${escapeHtml(tier.tier_id)}">
      <p class="panel-label">${escapeHtml(tier.tier_id)} / ${escapeHtml(tier.label)}</p>
      <p class="panel-copy">
        ${escapeHtml(tier.link_mode)}<br>
        inputs ${escapeHtml(tier.input_count)} · outputs ${escapeHtml(tier.output_count)} · receipts ${escapeHtml(tier.receipt_count)}
      </p>
      <div class="status-stack">
        ${tier.handoff_conditions.map((condition) => `<span class="status-chip status-chip-block">${escapeHtml(condition)}</span>`).join("")}
      </div>
    </article>
  `).join("");

  animateMetric(metricTiers, surface.tiers.length);
  updateSelectionHighlights();
}

function renderDebtSurface(surface) {
  if (!surface) {
    return;
  }

  if (debtConsole) {
    debtConsole.innerHTML = surface.debt_classes.map((debt) => `
      <article class="panel-card ${debt.impact === "critical" || debt.impact === "high" ? "panel-card-danger" : ""}">
        <p class="panel-label">${escapeHtml(debt.debt_id)} / ${escapeHtml(debt.impact)}</p>
        <p class="panel-copy">${escapeHtml(debt.title)}</p>
        <div class="status-stack">
          <span class="status-chip">signals ${escapeHtml(debt.signal_count)}</span>
          <span class="status-chip">mitigations ${escapeHtml(debt.mitigation_count)}</span>
        </div>
      </article>
    `).join("");
  }

  if (debtDecisionStates) {
    debtDecisionStates.innerHTML = surface.decision_states.map((state) => `<span class="status-chip">${escapeHtml(state)}</span>`).join("");
  }

  animateMetric(metricDebt, surface.debt_classes.length);
}

function renderSpecialistSurface(surface) {
  if (!surface) {
    return;
  }

  if (specialistRole) {
    specialistRole.textContent = surface.central_role;
  }

  if (specialistBoard) {
    specialistBoard.innerHTML = surface.specialists.map((specialist) => `
      <article class="panel-card" data-mcp-id="${escapeHtml(specialist.mcp_id)}">
        <p class="panel-label">${escapeHtml(specialist.mcp_id)}</p>
        <p class="panel-copy">
          auth ${escapeHtml(specialist.auth_model)}<br>
          scopes ${escapeHtml(specialist.scope_count)} · data ${escapeHtml(specialist.allowed_data_classes.length)}
        </p>
        <div class="status-stack">
          ${specialist.recommended_use_cases.map((item) => `<span class="status-chip">${escapeHtml(item)}</span>`).join("")}
        </div>
      </article>
    `).join("");
  }

  animateMetric(metricSpecialists, surface.specialists.length);
  updateSelectionHighlights();
}

function renderMonitoringSurface(surface) {
  if (!surface) {
    return;
  }

  if (monitoringFields) {
    monitoringFields.innerHTML = surface.required_fields.map((field) => `
      <article class="rail-node">
        <p class="panel-label">${escapeHtml(field.replaceAll("_", " "))}</p>
      </article>
    `).join("");
  }

  if (monitoringReceipts) {
    monitoringReceipts.innerHTML = surface.required_receipts.map((receipt) => `
      <span class="status-chip">${escapeHtml(receipt)}</span>
    `).join("");
  }
}

function renderEvolution(loop, registry, proposal) {
  if (!loop || !registry || !proposal) {
    return;
  }

  if (closePill) {
    closePill.textContent = `${loop.current_close_verdict.version} close-ready`;
  }
  if (nextPill) {
    nextPill.textContent = `next: ${loop.next_target_version}`;
  }
  if (metricVersion) {
    metricVersion.textContent = loop.current_close_verdict.version;
  }
  if (closeBasis) {
    closeBasis.textContent = loop.current_close_verdict.basis.replaceAll("-", " ");
  }

  if (upgradeLoopGrid) {
    upgradeLoopGrid.innerHTML = `
      <article class="panel-card">
        <p class="panel-label">Current close</p>
        <p class="panel-copy">${escapeHtml(loop.current_close_verdict.version)} closes on ${escapeHtml(loop.current_close_verdict.basis.replaceAll("-", " "))}.</p>
      </article>
      <article class="panel-card">
        <p class="panel-label">Next target</p>
        <p class="panel-copy">${escapeHtml(loop.next_target_version)} keeps the docs evolution loop active.</p>
      </article>
      <article class="panel-card">
        <p class="panel-label">Triggers</p>
        <p class="panel-copy">${escapeHtml(loop.trigger_events.join(" · "))}</p>
      </article>
      <article class="panel-card">
        <p class="panel-label">Generated outputs</p>
        <p class="panel-copy">${escapeHtml(loop.generated_outputs.length)} mirrored docs surfaces and proposal assets.</p>
      </article>
    `;
  }

  if (promptRegistry) {
    promptRegistry.innerHTML = registry.prompts.map((prompt) => {
      const proposalMatch = proposal.proposal_items.find((item) => item.prompt_id === prompt.prompt_id);
      return `
        <article class="panel-card">
          <p class="panel-label">${escapeHtml(prompt.prompt_id)}</p>
          <p class="panel-copy">${escapeHtml(proposalMatch ? proposalMatch.intent : prompt.purpose)}</p>
          <div class="status-stack">
            <span class="status-chip">${escapeHtml(prompt.audience)}</span>
            <span class="status-chip">${prompt.auto_upgrade_on_version_bump ? "auto-upgrade" : "manual"}</span>
          </div>
        </article>
      `;
    }).join("");
  }
}

async function fetchJson(path) {
  try {
    const response = await fetch(path);
    if (!response.ok) {
      return null;
    }
    return await response.json();
  } catch (_error) {
    return null;
  }
}

async function loadSurfaceData() {
  const [
    solutionSurface,
    debtSurface,
    specialistSurface,
    monitoringSurface,
    promptRegistrySurface,
    upgradeLoopSurface,
    upgradeProposalSurface
  ] = await Promise.all([
    fetchJson("solution-packaging-surface.json"),
    fetchJson("cognitive-debt-surface.json"),
    fetchJson("specialist-mcp-surface.json"),
    fetchJson("monitoring-link-surface.json"),
    fetchJson("role-prompt-registry.json"),
    fetchJson("version-upgrade-loop.json"),
    fetchJson("version-upgrade-proposal.json")
  ]);

  surfaceState.solution = solutionSurface;
  surfaceState.debt = debtSurface;
  surfaceState.specialist = specialistSurface;
  surfaceState.monitoring = monitoringSurface;
  surfaceState.registry = promptRegistrySurface;
  surfaceState.loop = upgradeLoopSurface;
  surfaceState.proposal = upgradeProposalSurface;

  renderSolutionPackaging(solutionSurface);
  renderDebtSurface(debtSurface);
  renderSpecialistSurface(specialistSurface);
  renderMonitoringSurface(monitoringSurface);
  renderEvolution(upgradeLoopSurface, promptRegistrySurface, upgradeProposalSurface);
  renderSimulator();
}

function initReveal() {
  const sections = document.querySelectorAll("[data-reveal]");
  if (!sections.length) {
    return;
  }

  if (prefersReducedMotion) {
    sections.forEach((section) => section.classList.add("is-visible"));
    return;
  }

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) {
        return;
      }

      entry.target.classList.add("is-visible");

      if (gsapReady) {
        window.gsap.fromTo(entry.target, { y: 28, opacity: 0 }, {
          y: 0,
          opacity: 1,
          duration: 0.85,
          ease: "power3.out"
        });
      }

      observer.unobserve(entry.target);
    });
  }, { threshold: 0.18 });

  sections.forEach((section) => observer.observe(section));
}

function initHeroTilt() {
  if (!heroBoard || prefersReducedMotion || !finePointer) {
    return;
  }

  let rafId = 0;
  let nextX = 0;
  let nextY = 0;

  function applyTilt() {
    docElement.style.setProperty("--hero-x", `${nextX.toFixed(2)}`);
    docElement.style.setProperty("--hero-y", `${nextY.toFixed(2)}`);
    rafId = 0;
  }

  heroBoard.addEventListener("pointermove", (event) => {
    const rect = heroBoard.getBoundingClientRect();
    const x = ((event.clientX - rect.left) / rect.width - 0.5) * 10;
    const y = ((event.clientY - rect.top) / rect.height - 0.5) * -8;
    nextX = x;
    nextY = y;
    if (!rafId) {
      rafId = requestAnimationFrame(applyTilt);
    }
  });

  heroBoard.addEventListener("pointerleave", () => {
    nextX = 0;
    nextY = 0;
    if (!rafId) {
      rafId = requestAnimationFrame(applyTilt);
    }
  });
}

function pickSpecialistIds() {
  const tierId = simulatorState.tierId;
  const posture = simulatorState.posture;

  if (tierId === "tier-1") {
    return posture === "defer"
      ? ["governance-api", "note-context"]
      : ["governance-api"];
  }

  if (tierId === "tier-2") {
    if (posture === "accept") {
      return ["governance-api", "ui-ux"];
    }
    if (posture === "defer") {
      return ["governance-api", "frontend-perf"];
    }
    return ["governance-api", "ui-ux", "frontend-perf"];
  }

  if (posture === "accept") {
    return ["governance-api", "security-review", "frontend-perf"];
  }
  if (posture === "defer") {
    return ["governance-api", "security-review"];
  }
  return ["governance-api", "security-review", "frontend-perf", "ui-ux"];
}

function updateSelectionHighlights() {
  document.querySelectorAll("[data-tier-id]").forEach((card) => {
    card.classList.toggle("is-selected", card.dataset.tierId === simulatorState.tierId);
  });

  const selectedSpecialists = new Set(pickSpecialistIds());
  document.querySelectorAll("[data-mcp-id]").forEach((card) => {
    card.classList.toggle("is-selected", selectedSpecialists.has(card.dataset.mcpId));
  });

  if (simTierControls) {
    simTierControls.querySelectorAll("[data-tier]").forEach((button) => {
      button.classList.toggle("is-selected", button.dataset.tier === simulatorState.tierId);
    });
  }

  if (simPostureControls) {
    simPostureControls.querySelectorAll("[data-posture]").forEach((button) => {
      button.classList.toggle("is-selected", button.dataset.posture === simulatorState.posture);
    });
  }
}

function renderSimulator() {
  if (!surfaceState.solution || !surfaceState.specialist) {
    updateSelectionHighlights();
    return;
  }

  const selectedTier = surfaceState.solution.tiers.find((tier) => tier.tier_id === simulatorState.tierId) || surfaceState.solution.tiers[0];
  const selectedSpecialistIds = pickSpecialistIds();
  const specialistLabels = selectedSpecialistIds.map((id) => {
    const specialist = surfaceState.specialist.specialists.find((item) => item.mcp_id === id);
    return specialist ? specialist.mcp_id : id;
  });

  if (simTierSummary) {
    simTierSummary.textContent = `${selectedTier.tier_id} keeps ${selectedTier.link_mode.replaceAll("-", " ")} active. ${selectedTier.handoff_conditions[0]}`;
  }

  if (simRuntimeSummary) {
    const runtimeCopy = selectedTier.tier_id === "tier-1"
      ? "Execution stays light: scan, summarize, hand off. The service keeps full delivery ownership."
      : selectedTier.tier_id === "tier-2"
        ? "Execution stays service-local, but the service now owes a governed kernel, structured plan draft, and gate posture."
        : "Execution remains service-local, but ongoing monitoring link receipts, owner route, and cadence become part of the promise.";
    const postureCopy = simulatorState.posture === "accept"
      ? "The buyer is willing to carry some debt, so the routing stays narrower."
      : simulatorState.posture === "defer"
        ? "The buyer is intentionally carrying debt, so review intensity rises while implementation stays selective."
        : "The buyer wants debt reduced now, so composition broadens toward UX, perf, and security review where appropriate.";
    simRuntimeSummary.textContent = `${runtimeCopy} ${postureCopy}`;
  }

  if (simSpecialistSummary) {
    simSpecialistSummary.innerHTML = specialistLabels.map((label) => `<span class="status-chip">${escapeHtml(label)}</span>`).join("");
  }

  updateSelectionHighlights();
}

function bindSimulatorControls() {
  if (simTierControls) {
    simTierControls.addEventListener("click", (event) => {
      const button = event.target.closest("[data-tier]");
      if (!button) {
        return;
      }
      simulatorState.tierId = button.dataset.tier;
      renderSimulator();
    });
  }

  if (simPostureControls) {
    simPostureControls.addEventListener("click", (event) => {
      const button = event.target.closest("[data-posture]");
      if (!button) {
        return;
      }
      simulatorState.posture = button.dataset.posture;
      renderSimulator();
    });
  }
}

function triggerShiftPulse() {
  if (prefersReducedMotion) {
    return;
  }

  [heroTitle, heroBoard].forEach((element) => {
    if (!element) {
      return;
    }
    element.classList.remove("is-shifting");
    void element.offsetWidth;
    element.classList.add("is-shifting");
    window.setTimeout(() => {
      element.classList.remove("is-shifting");
    }, 260);
  });
}

function initShiftPulse() {
  if (prefersReducedMotion) {
    return;
  }

  const scheduleNext = () => {
    const delay = 4200 + Math.random() * 2600;
    window.setTimeout(() => {
      triggerShiftPulse();
      scheduleNext();
    }, delay);
  };

  if (heroBoard) {
    heroBoard.addEventListener("pointerenter", triggerShiftPulse);
  }
  if (heroTitle) {
    heroTitle.addEventListener("pointerenter", triggerShiftPulse);
  }

  scheduleNext();
}

function initSignalField() {
  if (!signalCanvas) {
    return;
  }

  const context = signalCanvas.getContext("2d");
  if (!context) {
    return;
  }

  const glyphs = "アイウエオカキクケコサシスセソ0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ$#*+-";
  const columns = [];
  let width = 0;
  let height = 0;
  let animationFrame = 0;
  let lastTime = 0;
  let pointerX = -9999;
  let pointerActive = false;
  let fontSize = 16;

  function resizeCanvas() {
    const ratio = Math.min(window.devicePixelRatio || 1, 1.8);
    width = window.innerWidth;
    height = window.innerHeight;
    signalCanvas.width = Math.floor(width * ratio);
    signalCanvas.height = Math.floor(height * ratio);
    signalCanvas.style.width = `${width}px`;
    signalCanvas.style.height = `${height}px`;
    context.setTransform(ratio, 0, 0, ratio, 0, 0);

    fontSize = width < 760 ? 14 : 16;
    columns.length = 0;
    const count = Math.floor(width / fontSize);
    for (let index = 0; index < count; index += 1) {
      columns.push({
        x: index * fontSize,
        y: Math.random() * height,
        speed: 0.9 + Math.random() * 1.9,
        length: 8 + Math.floor(Math.random() * 16),
        drift: Math.random() * 12
      });
    }
  }

  function drawFrame(delta) {
    context.fillStyle = "rgba(1, 6, 3, 0.2)";
    context.fillRect(0, 0, width, height);

    context.font = `${fontSize}px "IBM Plex Mono"`;
    context.textBaseline = "top";

    columns.forEach((column, index) => {
      column.y += column.speed * delta * 0.06;
      if (column.y > height + column.length * fontSize) {
        column.y = -column.length * fontSize;
      }

      const pointerDistance = Math.abs(pointerX - column.x);
      const pointerBoost = pointerActive ? Math.max(0, 1 - pointerDistance / 160) : 0;

      for (let row = 0; row < column.length; row += 1) {
        const glyph = glyphs[(index + row + Math.floor(column.y / fontSize)) % glyphs.length];
        const y = column.y - row * fontSize;
        if (y < -fontSize || y > height + fontSize) {
          continue;
        }

        const intensity = row === 0 ? 0.95 : Math.max(0.1, 0.42 - row * 0.022) + pointerBoost * 0.2;
        context.fillStyle = row === 0
          ? `rgba(220, 255, 230, ${Math.min(1, intensity + pointerBoost * 0.2)})`
          : `rgba(125, 255, 155, ${Math.min(0.9, intensity)})`;
        context.fillText(glyph, column.x + Math.sin(column.drift + row) * 2, y);
      }

      if (pointerBoost > 0.12) {
        context.strokeStyle = `rgba(125, 255, 155, ${pointerBoost * 0.12})`;
        context.beginPath();
        context.moveTo(column.x + fontSize * 0.5, 0);
        context.lineTo(column.x + fontSize * 0.5, height);
        context.stroke();
      }
    });

    if (pointerActive) {
      const gradient = context.createRadialGradient(pointerX, height * 0.28, 0, pointerX, height * 0.28, 220);
      gradient.addColorStop(0, "rgba(125, 255, 155, 0.12)");
      gradient.addColorStop(1, "rgba(125, 255, 155, 0)");
      context.fillStyle = gradient;
      context.fillRect(pointerX - 240, 0, 480, height);
    }
  }

  function handlePointerMove(event) {
    pointerActive = true;
    pointerX = event.clientX;
  }

  function handlePointerLeave() {
    pointerActive = false;
    pointerX = -9999;
  }

  function drawStaticFrame() {
    context.fillStyle = "rgba(1, 6, 3, 0.96)";
    context.fillRect(0, 0, width, height);
    context.font = `${fontSize}px "IBM Plex Mono"`;
    context.textBaseline = "top";

    columns.forEach((column, index) => {
      for (let row = 0; row < Math.min(column.length, 9); row += 1) {
        const glyph = glyphs[(index + row) % glyphs.length];
        const y = ((index * 11) + row * fontSize * 1.25) % height;
        context.fillStyle = row === 0 ? "rgba(220, 255, 230, 0.9)" : "rgba(125, 255, 155, 0.35)";
        context.fillText(glyph, column.x, y);
      }
    });
  }

  function frame(now) {
    if (document.hidden) {
      animationFrame = requestAnimationFrame(frame);
      return;
    }

    if (!lastTime) {
      lastTime = now;
    }
    const delta = Math.min(now - lastTime, 32);
    lastTime = now;
    drawFrame(delta);
    animationFrame = requestAnimationFrame(frame);
  }

  resizeCanvas();
  if (prefersReducedMotion) {
    drawStaticFrame();
  } else {
    animationFrame = requestAnimationFrame(frame);
  }

  window.addEventListener("resize", resizeCanvas);
  window.addEventListener("pointermove", handlePointerMove, { passive: true });
  window.addEventListener("pointerleave", handlePointerLeave);
  window.addEventListener("beforeunload", () => {
    if (animationFrame) {
      cancelAnimationFrame(animationFrame);
    }
  });
}

initSignalField();
initReveal();
initHeroTilt();
bindSimulatorControls();
initShiftPulse();
loadSurfaceData();
