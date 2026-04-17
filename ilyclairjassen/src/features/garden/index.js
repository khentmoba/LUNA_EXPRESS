import { initDNA } from './dna';
import { initPollen } from './pollen';
import { initGardenCanvas } from './canvas';

/**
 * Garden Feature Entry Point
 * Orchestrates the canvas, DNA growth, and pollen simulations.
 */

export function initGarden(containerId = 'world') {
  console.log('[Garden] Initializing generative ecosystem...');
  
  initDNA();
  initPollen();
  initGardenCanvas(containerId);
}

export { getDNA } from './dna';
export { getPollenPoints } from './pollen';
