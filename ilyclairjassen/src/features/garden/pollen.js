/**
 * Pollen / Heatmap logic for Garden.
 */

let points = [];

/**
 * Initializes the pollen simulation.
 */
export function initPollen() {
  // Seed with initial points
  for (let i = 0; i < 60; i++) {
    points.push({
      x: Math.random(),
      y: 0.45 + Math.random() * 0.35,
      heat: 0.3 + Math.random() * 0.7,
      age: Math.random()
    });
  }

  // Animation loop
  setInterval(() => {
    // Add new pollen occasionally
    if (points.length < 80 && Math.random() < 0.3) {
      points.push({
        x: Math.random(),
        y: 0.5 + Math.random() * 0.3,
        heat: 0.8 + Math.random() * 0.2,
        age: 0
      });
    }

    // Update positions and ages
    points.forEach(p => {
      p.age += 0.001;
      p.x += (Math.random() - 0.5) * 0.002;
    });

    // Remove old pollen
    points = points.filter(p => p.age < 1);
  }, 100);
}

/**
 * Retrieves current pollen points.
 * @returns {Array} List of pollen points
 */
export function getPollenPoints() {
  return points;
}
