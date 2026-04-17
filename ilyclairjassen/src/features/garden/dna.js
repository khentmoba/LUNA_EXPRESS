/**
 * DNA Growth Panel logic.
 * Handles the procedural growth parameters of the digital flowers.
 */

let curvature = 0.5;
let stemH = 0.6;
let petalCount = 5;
let petalSpread = 0.7;
let phase = 0;
let morphT = 0;

const targets = { 
  curvature: 0.5, 
  stemH: 0.6, 
  petalCount: 5, 
  petalSpread: 0.7 
};

/**
 * Initializes the DNA growth simulation.
 */
export function initDNA() {
  // Update targets periodically
  setInterval(() => {
    targets.curvature = 0.2 + Math.random() * 0.75;
    targets.stemH = 0.3 + Math.random() * 0.65;
    targets.petalCount = 3 + Math.floor(Math.random() * 7);
    targets.petalSpread = 0.3 + Math.random() * 0.7;
    morphT = 0;
  }, 4000);

  // Smooth interpolation loop
  setInterval(() => {
    morphT = Math.min(1, morphT + 0.018);
    const e = morphT < 0.5 ? 2 * morphT * morphT : -1 + (4 - 2 * morphT) * morphT;
    
    curvature += (targets.curvature - curvature) * 0.05 * (1 + e);
    stemH += (targets.stemH - stemH) * 0.05 * (1 + e);
    petalCount += (targets.petalCount - petalCount) * 0.04;
    petalSpread += (targets.petalSpread - petalSpread) * 0.05;
    phase += 0.025;
  }, 16);
}

/**
 * Retrieves current DNA parameters.
 * @returns {Object} DNA state
 */
export function getDNA() {
  return { 
    curvature, 
    stemH, 
    petalCount, 
    petalSpread, 
    phase 
  };
}
