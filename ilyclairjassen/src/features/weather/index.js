import { initWeather, onWeatherChange, getIntensity } from './engine';
import { WeatherAudio } from './audio';

/**
 * Weather Feature
 * Manages rain, fog, and ambient sounds.
 */

let soundMode = 'off'; // 'off' | 'wind' | 'rain'
let soundBtn = null;

export function initWeatherFeature() {
  initWeather();
  setupSoundToggle();

  // Auto-init audio on first interaction
  const initAudio = () => {
    WeatherAudio.init();
    document.removeEventListener('click', initAudio);
    document.removeEventListener('touchstart', initAudio);
  };
  document.addEventListener('click', initAudio, { once: true });
  document.addEventListener('touchstart', initAudio, { once: true });

  // Handle weather-driven sound changes
  onWeatherChange((isRaining) => {
    if (isRaining && soundMode !== 'off') {
      soundMode = 'rain';
      WeatherAudio.playRain();
      updateSoundButtonUI();
    } else if (!isRaining && soundMode === 'rain') {
      soundMode = 'wind';
      WeatherAudio.playWind();
      updateSoundButtonUI();
    }

    // Fog overlay handling (to be refined in main.js or a separate UI module)
    const fog = document.getElementById('fogOverlay');
    if (fog) fog.style.opacity = isRaining ? '1' : '0';
  });
}

function setupSoundToggle() {
  soundBtn = document.createElement('button');
  soundBtn.id = 'soundBtn';
  soundBtn.textContent = '🔇';
  soundBtn.title = 'Sound: Off';
  soundBtn.style.cssText = 'position:fixed;top:14px;left:14px;z-index:600;background:rgba(0,0,0,0.35);border:1px solid rgba(255,200,140,0.3);border-radius:50%;width:36px;height:36px;font-size:1.1rem;cursor:pointer;backdrop-filter:blur(8px);color:#fff;line-height:1;display:flex;align-items:center;justify-content:center;transition:transform 0.15s,border-color 0.2s;';
  
  soundBtn.addEventListener('click', toggleSound);
  document.body.appendChild(soundBtn);
}

function toggleSound() {
  WeatherAudio.init(); // Ensure initialized

  if (soundMode === 'off') {
    soundMode = 'wind';
    WeatherAudio.playWind();
  } else if (soundMode === 'wind') {
    soundMode = 'rain';
    WeatherAudio.playRain();
  } else {
    soundMode = 'off';
    WeatherAudio.stopAll();
  }

  updateSoundButtonUI();
  if (navigator.vibrate) navigator.vibrate(30);
}

function updateSoundButtonUI() {
  if (!soundBtn) return;
  const icons = { off: '🔇', wind: '🌬', rain: '🌧' };
  const labels = { off: 'Sound: Off', wind: 'Sound: Wind', rain: 'Sound: Rain' };
  
  soundBtn.textContent = icons[soundMode];
  soundBtn.title = labels[soundMode];
}

export { getIntensity, onWeatherChange, WeatherAudio };
export { checkIfRaining } from './engine';
