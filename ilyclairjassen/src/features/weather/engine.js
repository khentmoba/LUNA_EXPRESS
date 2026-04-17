/**
 * Weather Engine
 * Handles the weather state simulation (rain intensity, fog).
 */

let intensity = 0; // 0=clear, 1=heavy rain
let target = 0;
let isRaining = false;
const callbacks = [];

/**
 * Starts the weather cycle.
 */
export function initWeather() {
  function cycle() {
    const delay = isRaining 
      ? (8000 + Math.random() * 12000) 
      : (15000 + Math.random() * 20000);

    setTimeout(() => {
      isRaining = !isRaining;
      target = isRaining ? 0.4 + Math.random() * 0.5 : 0;
      
      callbacks.forEach(f => f(isRaining, target));
      cycle();
    }, delay);
  }

  cycle();

  // Smooth transition loop
  setInterval(() => {
    intensity += (target - intensity) * 0.04;
  }, 50);
}

/**
 * Retrieves the current weather intensity.
 * @returns {number} Intensity (0 to 1)
 */
export function getIntensity() {
  return intensity;
}

/**
 * Checks if it is currently raining.
 * @returns {boolean} True if raining
 */
export function checkIfRaining() {
  return isRaining;
}

/**
 * Registers a callback for weather changes.
 * @param {Function} callback 
 */
export function onWeatherChange(callback) {
  callbacks.push(callback);
}
