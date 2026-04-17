/**
 * Shared time and date utilities
 */

/**
 * Normalizes 24h progress (0.0 to 1.0)
 */
export function getDayTime() {
  const now = new Date();
  return (now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds()) / 86400;
}

/**
 * Returns a formatted time string (e.g. "10:30 AM")
 */
export function formatTime(date = new Date()) {
  let h = date.getHours();
  const m = date.getMinutes();
  const ampm = h >= 12 ? 'PM' : 'AM';
  h = h % 12 || 12;
  const mStr = m < 10 ? '0' + m : m;
  return `${h}:${mStr} ${ampm}`;
}

/**
 * Returns relative cycle name based on time
 */
export function getCycleName(t = getDayTime()) {
  if (t < 0.2) return 'Night';
  if (t < 0.25) return 'Dawn';
  if (t < 0.7) return 'Day';
  if (t < 0.8) return 'Dusk';
  return 'Night';
}

/**
 * Returns current season index (0-11)
 */
export function getMonth() {
  return new Date().getMonth();
}

/**
 * Time singleton — reactive API used by canvas and weather modules.
 * Polls every 10 seconds. Use Time.onChange(fn) to subscribe.
 */
const _callbacks = [];
let _t = getDayTime();

setInterval(() => {
  _t = getDayTime();
  _callbacks.forEach(fn => fn(_t));
}, 10000);

export const Time = {
  /** Returns current day progress (0.0–1.0) */
  getCycleProgress() { return _t; },
  /** Returns named cycle string */
  getCycleName() { return getCycleName(_t); },
  /** Returns formatted time string */
  formatTime() { return formatTime(); },
  /** Subscribe to time changes */
  onChange(fn) { _callbacks.push(fn); fn(_t); }
};
