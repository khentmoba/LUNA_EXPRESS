/**
 * Math and Color Utilities for Garden
 */

/**
 * Linear interpolation between two RGB arrays.
 * @param {Array<number>} a - Start color [r, g, b]
 * @param {Array<number>} b - End color [r, g, b]
 * @param {number} t - Interpolation factor (0-1)
 * @returns {Array<number>} Interpolated color [r, g, b]
 */
export function lerpC(a, b, t) {
  return [
    a[0] + (b[0] - a[0]) * t | 0,
    a[1] + (b[1] - a[1]) * t | 0,
    a[2] + (b[2] - a[2]) * t | 0
  ];
}

/**
 * Converts an RGB array to a CSS rgb string.
 * @param {Array<number>} c - Color [r, g, b]
 * @returns {string} CSS rgb string
 */
export function rgb(c) {
  return `rgb(${c[0]},${c[1]},${c[2]})`;
}

/**
 * Calculates sky colors based on day time factor.
 * @param {number} t - Time factor (0-1)
 * @returns {Object} Sky configuration including top, bot, star opacity, sun, and moon positions.
 */
export function getSky(t) {
  if (t < 0.22) {
    const p = t / 0.22;
    return {
      top: lerpC([8, 4, 22], [255, 160, 110], p),
      bot: lerpC([18, 10, 40], [255, 210, 170], p),
      starA: 1 - p * 0.8,
      sun: null,
      moon: { x: 0.76, y: 0.14 + p * 0.06 }
    };
  }
  if (t < 0.36) {
    const p = (t - 0.22) / 0.14;
    return {
      top: lerpC([255, 160, 110], [255, 178, 128], p),
      bot: lerpC([255, 210, 170], [255, 222, 182], p),
      starA: 0.2 - p * 0.2,
      sun: { x: 0.08 + p * 0.22, y: 0.7 - p * 0.48 },
      moon: null
    };
  }
  if (t < 0.64) {
    const p = (t - 0.36) / 0.28;
    return {
      top: lerpC([255, 178, 128], [255, 168, 118], p),
      bot: lerpC([255, 222, 182], [255, 212, 172], p),
      starA: 0,
      sun: { x: 0.3 + p * 0.28, y: 0.22 - 0.04 * p },
      moon: null
    };
  }
  if (t < 0.78) {
    const p = (t - 0.64) / 0.14;
    return {
      top: lerpC([255, 168, 118], [45, 28, 75], p),
      bot: lerpC([255, 212, 172], [255, 100, 65], p),
      starA: p * 0.7,
      sun: { x: 0.58 + p * 0.22, y: 0.18 + p * 0.52 },
      moon: null
    };
  }
  const p = (t - 0.78) / 0.22;
  return {
    top: lerpC([45, 28, 75], [8, 4, 22], p),
    bot: lerpC([255, 100, 65], [18, 10, 40], p),
    starA: 0.7 + p * 0.3,
    sun: null,
    moon: { x: 0.76, y: 0.32 - p * 0.18 }
  };
}
