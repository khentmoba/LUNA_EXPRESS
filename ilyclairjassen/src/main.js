import './shared/styles/tokens.css';
import { Time } from './shared/utils/time';
import { Viewport } from './shared/utils/viewport';
import { initGatekeeper } from './features/auth';
import { initGarden } from './features/garden';
import { initWeatherFeature, onWeatherChange, getIntensity } from './features/weather';
import { initChat } from './features/chat';
import { initDiary } from './features/diary';
import { initMemories } from './features/memories';

/**
 * Eternal Sanctuary — Bootstrap
 * Orchestrates initialization of the modular application.
 */

async function bootstrap() {
  console.log('[Sanctuary] Initializing Eternal Sanctuary v4.0 (Modular)');

  // 1. Init Viewport (panning/inertia)
  const world = document.getElementById('world');
  const viewport = document.getElementById('viewport');
  Viewport.init(world, viewport);

  // 2. Start time display loop
  initTimeDisplay();

  // 3. Auth Gate — launches features on success
  initGatekeeper((userData) => {
    launchFeatures(userData);
  });
}

function launchFeatures(user) {
  console.log(`[Sanctuary] Launching features for: ${user.name}`);

  // Garden (generative canvas ecosystem)
  initGarden('world');

  // Weather (rain simulation + ambient sound)
  initWeatherFeature();

  // Realtime communications (chat, diary, memories)
  initChat(user);
  initDiary(user);
  initMemories(user);

  // Hook weather visibility into the world
  initWeatherUI();

  // Mark app as ready
  document.body.classList.add('app-ready');
}

// ─────────────────────────────────────────────
// Time Display
// ─────────────────────────────────────────────
function initTimeDisplay() {
  const timeDisplay = document.getElementById('timeDisplay');
  if (!timeDisplay) return;

  function update() {
    timeDisplay.textContent = Time.getCycleName() + ' · ' + Time.formatTime();
  }
  update();
  Time.onChange(update);
}

// ─────────────────────────────────────────────
// Weather UI Hooks
// ─────────────────────────────────────────────
function initWeatherUI() {
  const indicator = document.getElementById('weatherIndicator');
  const fog = document.getElementById('fogOverlay');

  onWeatherChange((isRaining, intensity) => {
    if (!indicator) return;
    indicator.textContent = isRaining ? '🌧 Rain' : '☀️ Clear';
    indicator.style.color = isRaining ? 'rgba(180,210,255,0.85)' : 'rgba(200,220,255,0.75)';

    if (fog) {
      fog.style.opacity = isRaining ? String(Math.min(intensity * 0.6, 0.4)) : '0';
    }
  });
}

// ─────────────────────────────────────────────
// Boot
// ─────────────────────────────────────────────
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', bootstrap);
} else {
  bootstrap();
}
