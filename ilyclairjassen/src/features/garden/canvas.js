import { PETAL_COLORS, GRASS_COLORS, PEBBLE_COLORS, FLOWER_PETAL_COLORS, FLOWER_PETAL_COLORS_2, EXOTIC_PETAL_COLORS, EXOTIC_PETAL_COLORS_2, COUNTS } from './constants';
import { rgb, getSky } from './utils';
import { getDNA } from './dna';
import { drawLily, drawRose, drawGenericFlower, drawDNAPanelUI } from './flowers';
import { Time } from '../../shared/utils/time';

/**
 * Main Garden Canvas Engine
 * Handles the background rendering, particles, and the procedural garden.
 */

let canvas, ctx;
let width, height;
let frame = 0;

// Pools and arrays
const stars = [];
const rainDrops = [];
const fireflies = [];
const petals = [];
const grass = [];
const pebbles = [];
const dew = [];
const sonicWaves = [];
let flowerDefs = [];

let groundY;
let capsuleX, capsuleY;
let capsulePulse = 0;

/**
 * Initializes the Garden Canvas.
 */
export function initGardenCanvas(containerId) {
  // Use the existing canvas from index.html; fall back to creating one
  canvas = document.getElementById('bgCanvas');
  if (!canvas) {
    const container = document.getElementById(containerId);
    if (!container) return;
    canvas = document.createElement('canvas');
    canvas.id = 'bgCanvas';
    container.appendChild(canvas);
  }
  ctx = canvas.getContext('2d');

  resize();
  window.addEventListener('resize', resize);

  setupScene();
  animate();
}

function resize() {
  const world = document.getElementById('world');
  if (!world) return;
  
  width = world.offsetWidth;
  height = world.offsetHeight;
  canvas.width = width;
  canvas.height = height;

  groundY = height * 0.63;
  capsuleX = width * 0.5;
  capsuleY = height * 0.63;

  // Re-generate some world-space particles on resize if empty
  if (stars.length === 0) setupParticles();
}

function setupScene() {
  setupParticles();
  setupFlowers();
}

function setupParticles() {
  // Stars
  for (let i = 0; i < COUNTS.STARS; i++) {
    stars.push({
      x: Math.random() * width,
      y: Math.random() * height * 0.55,
      r: Math.random() * 1.8 + 0.28,
      ph: Math.random() * 6.28,
      sp: Math.random() * 0.022 + 0.007
    });
  }

  // Rain drops
  for (let i = 0; i < COUNTS.RAIN_DROPS; i++) {
    rainDrops.push({
      x: Math.random() * width * 1.2,
      y: Math.random() * height,
      vy: 8 + Math.random() * 12,
      vx: -1.5 - Math.random() * 2,
      len: 8 + Math.random() * 22,
      alive: true
    });
  }

  // Fireflies
  for (let i = 0; i < COUNTS.FIREFLIES; i++) {
    fireflies.push({
      x: width * 0.25 + Math.random() * width * 0.5,
      y: height * 0.32 + Math.random() * height * 0.32,
      vx: (Math.random() - 0.5) * 0.7,
      vy: (Math.random() - 0.5) * 0.55,
      ax: 0, ay: 0,
      ph: Math.random() * 6.28,
      sp: Math.random() * 0.05 + 0.016,
      r: 3 + Math.random() * 3.5,
      trailX: [], trailY: [],
      attracted: false,
      cluster: i < 18
    });
  }

  // Falling Petals
  for (let i = 0; i < COUNTS.PETALS; i++) {
    petals.push({
      x: Math.random() * width,
      y: -30 - Math.random() * height,
      vy: Math.random() * 0.5 + 0.2,
      vx: (Math.random() - 0.5) * 0.38,
      rot: Math.random() * 6.28,
      rv: (Math.random() - 0.5) * 0.02,
      col: PETAL_COLORS[i % PETAL_COLORS.length],
      sz: Math.random() * 5 + 3.5,
      wob: Math.random() * 6.28
    });
  }

  // Grass
  for (let i = 0; i < COUNTS.GRASS; i++) {
    grass.push({
      x: Math.random() * width,
      h: 12 + Math.random() * 45,
      ph: Math.random() * 6.28,
      sp: Math.random() * 0.024 + 0.009,
      w: 1.5 + Math.random() * 2.2,
      col: GRASS_COLORS[i % GRASS_COLORS.length]
    });
  }

  // Pebbles
  for (let i = 0; i < COUNTS.PEBBLES; i++) {
    pebbles.push({
      x: Math.random() * width,
      r: 2 + Math.random() * 5,
      col: PEBBLE_COLORS[i % PEBBLE_COLORS.length]
    });
  }

  // Dew
  for (let i = 0; i < COUNTS.DEW; i++) {
    dew.push({
      x: width * 0.1 + Math.random() * width * 0.8,
      y: height * 0.55 + Math.random() * height * 0.15,
      r: 1.2 + Math.random() * 2.2,
      ph: Math.random() * 6.28,
      sp: Math.random() * 0.03 + 0.1
    });
  }

  // Sonic waves
  for (let i = 0; i < COUNTS.MAX_SONIC; i++) {
    sonicWaves.push({ alive: false, x: 0, y: 0, r: 0, life: 1, ml: 0.6, freq: 0 });
  }
}

function setupFlowers() {
  // Left side flowers
  for (let i = 0; i < COUNTS.FLOWERS_LEFT; i++) {
    const tp = ['lily', 'daisy', 'lavender'][Math.floor(Math.random() * 3)];
    flowerDefs.push({
      x: width * 0.04 + Math.random() * width * 0.44,
      baseY: groundY,
      h: 45 + Math.random() * 80,
      type: Math.random() < 0.5 ? 'lily' : tp,
      swayPh: Math.random() * 6.28,
      swaySpd: Math.random() * 0.018 + 0.01,
      baseAngle: 3 + Math.random() * 9,
      lean: 0,
      leanDecay: 0.965,
      pc: FLOWER_PETAL_COLORS[Math.floor(Math.random() * FLOWER_PETAL_COLORS.length)],
      pc2: FLOWER_PETAL_COLORS_2[Math.floor(Math.random() * FLOWER_PETAL_COLORS_2.length)],
      sz: 0.7 + Math.random() * 0.6,
      side: 'left',
      stage: 0.4 + Math.random() * 0.6,
      isCluster: false
    });
  }

  // Center cluster (Lily)
  for (let i = 0; i < COUNTS.FLOWERS_CENTER; i++) {
    const angle = (i / 12) * Math.PI * 2;
    const dist = 25 + Math.random() * 55;
    flowerDefs.push({
      x: width * 0.5 + Math.cos(angle) * dist,
      baseY: groundY,
      h: 55 + Math.random() * 70,
      type: 'lily',
      swayPh: Math.random() * 6.28,
      swaySpd: Math.random() * 0.016 + 0.009,
      baseAngle: (Math.random() - 0.5) * 5,
      lean: 0,
      leanDecay: 0.97,
      pc: '#fff0f3',
      pc2: '#ffccd8',
      sz: 0.85 + Math.random() * 0.45,
      side: 'center',
      stage: 0.6 + Math.random() * 0.4,
      isCluster: true
    });
  }

  // Right side flowers
  for (let i = 0; i < COUNTS.FLOWERS_RIGHT; i++) {
    const tp = ['rose', 'tulip', 'sunflower'][Math.floor(Math.random() * 3)];
    flowerDefs.push({
      x: width * 0.52 + Math.random() * width * 0.44,
      baseY: groundY,
      h: 45 + Math.random() * 80,
      type: Math.random() < 0.45 ? 'rose' : tp,
      swayPh: Math.random() * 6.28,
      swaySpd: Math.random() * 0.018 + 0.01,
      baseAngle: -(3 + Math.random() * 9),
      lean: 0,
      leanDecay: 0.965,
      pc: EXOTIC_PETAL_COLORS[Math.floor(Math.random() * EXOTIC_PETAL_COLORS.length)],
      pc2: EXOTIC_PETAL_COLORS_2[Math.floor(Math.random() * EXOTIC_PETAL_COLORS_2.length)],
      sz: 0.7 + Math.random() * 0.6,
      side: 'right',
      stage: 0.4 + Math.random() * 0.6,
      isCluster: false
    });
  }

  // Global handle for other features to interact
  window._flowerDefs = flowerDefs;
}

function animate() {
  frame++;
  draw();
  requestAnimationFrame(animate);
}

function draw() {
  ctx.clearRect(0, 0, width, height);

  const dayT = Time.getCycleProgress();
  const sky = getSky(dayT);
  const rainI = 0; // Will be hooked to Weather feature later

  // 1. SKY
  const sg = ctx.createLinearGradient(0, 0, 0, height * 0.6);
  sg.addColorStop(0, rgb(sky.top));
  sg.addColorStop(1, rgb(sky.bot));
  ctx.fillStyle = sg;
  ctx.fillRect(0, 0, width, height * 0.6);

  // 2. STARS
  const sa = Math.max(0, sky.starA);
  stars.forEach(s => {
    const opacity = sa * (0.28 + 0.72 * (0.5 + 0.5 * Math.sin(s.ph + frame * s.sp)));
    if (opacity < 0.02) return;
    ctx.beginPath();
    ctx.arc(s.x, s.y, s.r, 0, 6.28);
    ctx.fillStyle = `rgba(255,255,255,${opacity})`;
    ctx.fill();
  });

  // 3. SUN / MOON
  if (sky.sun) {
    const sx = sky.sun.x * width;
    const sy = sky.sun.y * height * 0.58;
    const sunG = ctx.createRadialGradient(sx, sy, 0, sx, sy, 110);
    sunG.addColorStop(0, 'rgba(255,250,205,1)');
    sunG.addColorStop(0.14, 'rgba(255,230,130,.92)');
    sunG.addColorStop(0.4, 'rgba(255,190,80,.45)');
    sunG.addColorStop(1, 'rgba(255,150,0,0)');
    ctx.beginPath(); ctx.arc(sx, sy, 110, 0, 6.28); ctx.fillStyle = sunG; ctx.fill();
    ctx.beginPath(); ctx.arc(sx, sy, 18, 0, 6.28); ctx.fillStyle = 'rgba(255,255,230,.98)'; ctx.fill();
  }
  if (sky.moon) {
    const mx = sky.moon.x * width;
    const my = sky.moon.y * height * 0.58;
    ctx.beginPath(); ctx.arc(mx, my, 26, 0, 6.28); ctx.fillStyle = 'rgba(240,235,200,.94)'; ctx.fill();
    ctx.beginPath(); ctx.arc(mx + 10, my - 5, 22, 0, 6.28); ctx.fillStyle = rgb(sky.top); ctx.fill();
  }

  // 4. HILLS
  const hillBaseY = height * 0.58;
  const hillCols = [
    ['rgba(180,150,180,.35)', 'rgba(200,170,190,.2)'],
    ['rgba(140,170,120,.52)', 'rgba(160,190,130,.32)'],
    ['rgba(90,130,60,.72)', 'rgba(110,150,70,.48)']
  ];
  for (let hl = 0; hl < 3; hl++) {
    const hscale = 1 - hl * 0.15;
    const hy = hillBaseY + (hl * height * 0.024);
    ctx.save();
    ctx.filter = `blur(${3 - hl * 1.2}px)`;
    ctx.beginPath(); ctx.moveTo(0, height); ctx.lineTo(0, hy);
    for (let hx = 0; hx <= width; hx += width / 20) {
      const hamp = (24 + hl * 14) * hscale;
      ctx.lineTo(hx, hy - Math.sin(hx * 0.0035 + hl * 2.1) * hamp - Math.sin(hx * 0.007 + hl * 1.3) * hamp * 0.5);
    }
    ctx.lineTo(width, height); ctx.closePath();
    const hg2 = ctx.createLinearGradient(0, hy - 55, 0, hy + 28);
    hg2.addColorStop(0, hillCols[hl][0]); hg2.addColorStop(1, hillCols[hl][1]);
    ctx.fillStyle = hg2; ctx.fill(); ctx.restore();
  }

  // 5. GROUND
  const gy = height * 0.62;
  ctx.save();
  ctx.beginPath(); ctx.moveTo(0, height); ctx.lineTo(width, height); ctx.lineTo(width, gy + height * 0.033);
  ctx.bezierCurveTo(width * 0.72, gy - height * 0.017, width * 0.28, gy - height * 0.017, 0, gy + height * 0.033);
  ctx.closePath();
  const groundG = ctx.createLinearGradient(0, gy, 0, height);
  groundG.addColorStop(0, '#3d6b22');
  groundG.addColorStop(0.08, '#2d5a1b');
  groundG.addColorStop(0.28, '#1e3e0e');
  groundG.addColorStop(0.6, '#152b08');
  groundG.addColorStop(1, '#0c1e04');
  ctx.fillStyle = groundG; ctx.fill(); ctx.restore();

  // Soil texture
  ctx.save();
  ctx.globalAlpha = 0.2;
  for (let i = 0; i < 35; i++) {
    ctx.beginPath();
    ctx.ellipse(width * 0.03 + i * (width * 0.028) + Math.sin(i * 1.7) * width * 0.012, gy + height * 0.04 + Math.sin(i * 2.3) * height * 0.018, 10 + Math.sin(i) * 7, 3.5 + Math.cos(i) * 1.8, Math.sin(i * 0.5) * 0.6, 0, 6.28);
    ctx.fillStyle = '#0a1804'; ctx.fill();
  }
  ctx.restore();

  // 6. PEBBLES & MOSS
  pebbles.forEach((pb, i) => {
    const py2 = gy + height * 0.055 + Math.sin(i * 1.4) * height * 0.022;
    ctx.beginPath();
    ctx.ellipse(pb.x, py2, pb.r, pb.r * 0.62, Math.sin(i) * 0.4, 0, 6.28);
    const pg2 = ctx.createRadialGradient(pb.x - pb.r * 0.2, py2 - pb.r * 0.2, 0, pb.x, py2, pb.r);
    pg2.addColorStop(0, 'rgba(255,255,255,.38)'); pg2.addColorStop(0.3, pb.col); pg2.addColorStop(1, 'rgba(0,0,0,.5)');
    ctx.fillStyle = pg2; ctx.fill();
  });

  // 7. MEMORY CAPSULE GLOW
  capsulePulse = (capsulePulse + 0.018) % (Math.PI * 2);
  const cpInten = 0.5 + 0.5 * Math.sin(capsulePulse);
  for (let r = 3; r > 0; r--) {
    const cg3 = ctx.createRadialGradient(capsuleX, capsuleY, 0, capsuleX, capsuleY, 40 * r * cpInten);
    cg3.addColorStop(0, `rgba(150,80,255,${0.18 * cpInten / r})`);
    cg3.addColorStop(0.4, `rgba(100,50,200,${0.1 * cpInten / r})`);
    cg3.addColorStop(1, 'rgba(80,30,180,0)');
    ctx.beginPath(); ctx.arc(capsuleX, capsuleY, 40 * r * cpInten, 0, 6.28); ctx.fillStyle = cg3; ctx.fill();
  }

  // 8. FLOWERS
  const sorted = [...flowerDefs].sort((a, b) => a.baseY - b.baseY);
  sorted.forEach(fl => {
    const sway = Math.sin(frame * fl.swaySpd + fl.swayPh) * (fl.side === 'left' ? 4 : fl.side === 'right' ? -4 : 2.5);
    const totalAngle = (fl.baseAngle + sway + fl.lean) * Math.PI / 180;
    fl.lean *= fl.leanDecay;
    const stage = fl.stage; // Will hook bloom later

    ctx.save();
    ctx.translate(fl.x, fl.baseY);
    ctx.rotate(totalAngle);
    ctx.translate(-fl.x, -fl.baseY);
    if (fl.type === 'lily') drawLily(ctx, fl.x, fl.baseY, fl.h, fl.sz, fl.pc, fl.pc2, sway, stage, frame);
    else if (fl.type === 'rose') drawRose(ctx, fl.x, fl.baseY, fl.h, fl.sz, fl.pc, fl.pc2, sway, stage, frame);
    else drawGenericFlower(ctx, fl.x, fl.baseY, fl.h, fl.sz, fl.pc, fl.pc2, sway, stage, frame, fl.type);
    ctx.restore();
  });

  // 9. DNA PANEL UI (Top Left overlay on canvas)
  drawDNAPanelUI(ctx, 20, 20, 150, 110, frame);
}
