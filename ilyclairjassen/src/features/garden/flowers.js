import { getDNA } from './dna';

/**
 * Flower Drawing Functions for Garden
 */

/**
 * Draws a Lily flower.
 */
export function drawLily(ctx, x, y, h, sz, col, col2, sway, stage, t3) {
  ctx.save();
  ctx.translate(x, y);
  const cx = Math.sin(sway * 0.035) * h * 0.42 + Math.sin(sway * 0.015) * h * 0.12;
  
  // Stem
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.bezierCurveTo(cx * 0.25, -h * 0.28, cx * 0.6, -h * 0.6, cx, -h);
  ctx.strokeStyle = '#3d7a22';
  ctx.lineWidth = 3 * sz;
  ctx.lineCap = 'round';
  ctx.stroke();

  // Stem highlight
  ctx.beginPath();
  ctx.moveTo(cx * 0.15, -h * 0.12);
  ctx.bezierCurveTo(cx * 0.3, -h * 0.35, cx * 0.5, -h * 0.55, cx * 0.85, -h * 0.88);
  ctx.strokeStyle = 'rgba(120,200,60,.2)';
  ctx.lineWidth = 1 * sz;
  ctx.stroke();

  // Leaves
  for (let li = 0; li < 2; li++) {
    const lp = 0.3 + li * 0.3;
    const lx = cx * lp;
    const lly = -h * lp;
    ctx.save();
    ctx.translate(lx, lly);
    ctx.rotate(li === 0 ? -0.4 : 0.35);
    ctx.beginPath();
    ctx.ellipse(li === 0 ? -10 * sz : 9 * sz, 0, 16 * sz, 5.5 * sz, li === 0 ? -0.15 : 0.15, 0, 6.28);
    
    const lg = ctx.createLinearGradient(-16 * sz, 0, 12 * sz, 0);
    lg.addColorStop(0, '#3a7018');
    lg.addColorStop(0.5, '#6aba30');
    lg.addColorStop(1, '#3a7018');
    ctx.fillStyle = lg;
    ctx.fill();

    const dg = ctx.createRadialGradient(li === 0 ? -8 * sz : 8 * sz, -2 * sz, 0, li === 0 ? -8 * sz : 8 * sz, -2 * sz, 2.2 * sz);
    dg.addColorStop(0, 'rgba(255,255,255,.9)');
    dg.addColorStop(0.4, 'rgba(200,240,255,.6)');
    dg.addColorStop(1, 'rgba(150,200,255,0)');
    ctx.beginPath();
    ctx.ellipse(li === 0 ? -8 * sz : 8 * sz, -2 * sz, 2.2 * sz, 1.8 * sz, -0.3, 0, 6.28);
    ctx.fillStyle = dg;
    ctx.fill();
    ctx.restore();
  }

  const px = cx;
  const py = -h;
  const openness = stage;
  const petSz = (14 + openness * 8) * sz;
  const petH = (28 + openness * 14) * sz;

  if (stage < 0.2) {
    // Bud
    ctx.beginPath();
    ctx.ellipse(px, py, 5 * sz, 12 * sz, 0, 0, 6.28);
    const bg = ctx.createLinearGradient(px, py + 12 * sz, px, py - 12 * sz);
    bg.addColorStop(0, col2);
    bg.addColorStop(1, col);
    ctx.fillStyle = bg;
    ctx.fill();
  } else {
    // Blossomed
    for (let p = 0; p < 6; p++) {
      const pa = (Math.PI / 3) * p + t3 * 0.006;
      ctx.save();
      ctx.translate(px, py);
      ctx.rotate(pa);
      const pg = ctx.createLinearGradient(0, 0, 0, -petH);
      pg.addColorStop(0, col2);
      pg.addColorStop(0.45, col);
      pg.addColorStop(1, 'rgba(255,255,255,.75)');
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.bezierCurveTo(-petSz * 0.55, -petH * 0.28, -petSz * 0.65, -petH * 0.72, 0, -petH);
      ctx.bezierCurveTo(petSz * 0.65, -petH * 0.72, petSz * 0.55, -petH * 0.28, 0, 0);
      ctx.fillStyle = pg;
      ctx.fill();
      ctx.strokeStyle = 'rgba(255,255,255,.15)';
      ctx.lineWidth = 0.6;
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(0, -petH * 0.8);
      ctx.stroke();
      ctx.restore();
    }
    // Center
    ctx.beginPath();
    ctx.arc(px, py, 6 * sz, 0, 6.28);
    const cg = ctx.createRadialGradient(px, py - 1, 0, px, py, 6 * sz);
    cg.addColorStop(0, '#fff9c4');
    cg.addColorStop(0.5, '#fde68a');
    cg.addColorStop(1, '#f59e0b');
    ctx.fillStyle = cg;
    ctx.fill();
  }
  ctx.restore();
}

/**
 * Draws a Rose flower.
 */
export function drawRose(ctx, x, y, h, sz, col, col2, sway, stage, t3) {
  ctx.save();
  ctx.translate(x, y);
  const cx = Math.sin(sway * 0.035) * h * 0.38;
  
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.bezierCurveTo(cx * 0.2, -h * 0.25, cx * 0.55, -h * 0.58, cx, -h);
  ctx.strokeStyle = '#3d7a22';
  ctx.lineWidth = 3 * sz;
  ctx.stroke();

  ctx.save();
  ctx.translate(cx * 0.5, -h * 0.42);
  ctx.beginPath();
  ctx.ellipse(-8 * sz, 0, 15 * sz, 5.5 * sz, -0.25, 0, 6.28);
  ctx.fillStyle = '#4a8a22';
  ctx.fill();
  ctx.restore();

  const rx = cx;
  const ry = -h;
  const layers = [[3, 9 * sz, col], [5, 14 * sz, col2], [8, 20 * sz, col]];
  
  for (let li = layers.length - 1; li >= 0; li--) {
    if (li > 0 && stage < 0.35) continue;
    const l = layers[li];
    for (let p = 0; p < l[0]; p++) {
      const pa = (Math.PI * 2 / l[0]) * p + t3 * 0.035 + li * 0.35;
      ctx.save();
      ctx.translate(rx + Math.cos(pa) * l[1] * 0.28, ry + Math.sin(pa) * l[1] * 0.28);
      ctx.rotate(pa + Math.PI * 0.5);
      const rg = ctx.createLinearGradient(0, -l[1], 0, 0);
      rg.addColorStop(0, 'rgba(255,255,255,.5)');
      rg.addColorStop(0.35, l[2]);
      rg.addColorStop(1, col2);
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.bezierCurveTo(-l[1] * 0.5, -l[1] * 0.42, -l[1] * 0.42, -l[1] * 0.88, 0, -l[1]);
      ctx.bezierCurveTo(l[1] * 0.42, -l[1] * 0.88, l[1] * 0.5, -l[1] * 0.42, 0, 0);
      ctx.fillStyle = rg;
      ctx.globalAlpha = 0.88;
      ctx.fill();
      ctx.globalAlpha = 1;
      ctx.restore();
    }
  }
  
  ctx.beginPath();
  ctx.arc(rx, ry, 5 * sz, 0, 6.28);
  ctx.fillStyle = '#fde68a';
  ctx.fill();
  ctx.restore();
}

/**
 * Draws generic flowers (daisy, lavender, tulip, sunflower).
 */
export function drawGenericFlower(ctx, x, y, h, sz, col, col2, sway, stage, t3, type) {
  ctx.save();
  ctx.translate(x, y);
  const cx = Math.sin(sway * 0.03) * h * 0.3;
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.bezierCurveTo(cx * 0.3, -h * 0.42, cx * 0.65, -h * 0.62, cx, -h);
  ctx.strokeStyle = '#4a8a22';
  ctx.lineWidth = 2.5 * sz;
  ctx.stroke();

  const dx = cx;
  const dy = -h;

  if (type === 'lavender') {
    for (let b = 0; b < 7; b++) {
      const bx = dx + Math.sin(b * 0.75 + t3 * 0.04) * 4 * sz;
      const by2 = dy + b * (h * 0.09);
      ctx.beginPath();
      ctx.ellipse(bx - 4 * sz, by2, 5 * sz, 3.5 * sz, -0.28, 0, 6.28);
      ctx.fillStyle = col;
      ctx.fill();
      ctx.beginPath();
      ctx.ellipse(bx + 4 * sz, by2, 5 * sz, 3.5 * sz, 0.28, 0, 6.28);
      ctx.fillStyle = col2;
      ctx.fill();
    }
  } else if (type === 'daisy') {
    const n = 10 + Math.floor(sz * 4);
    for (let p = 0; p < n; p++) {
      const pa = (Math.PI * 2 / n) * p + t3 * 0.02;
      ctx.save();
      ctx.translate(dx, dy);
      ctx.rotate(pa);
      ctx.beginPath();
      ctx.ellipse(0, -12 * sz, 3.5 * sz, 9 * sz, 0, 0, 6.28);
      ctx.fillStyle = col;
      ctx.fill();
      ctx.restore();
    }
    ctx.beginPath();
    ctx.arc(dx, dy, 8 * sz, 0, 6.28);
    ctx.fillStyle = '#fde68a';
    ctx.fill();
  } else if (type === 'tulip') {
    for (let p = 0; p < 3; p++) {
      const pa = p * (Math.PI * 2 / 3) + t3 * 0.015;
      ctx.save();
      ctx.translate(dx, dy);
      ctx.rotate(pa);
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.bezierCurveTo(-9 * sz, -8 * sz, -11 * sz, -26 * sz, 0, -32 * sz);
      ctx.bezierCurveTo(11 * sz, -26 * sz, 9 * sz, -8 * sz, 0, 0);
      ctx.fillStyle = col;
      ctx.fill();
      ctx.restore();
    }
  } else {
    // Sunflower / Default
    const n2 = 18;
    for (let p = 0; p < n2; p++) {
      const pa = (Math.PI * 2 / n2) * p + t3 * 0.006;
      ctx.save();
      ctx.translate(dx, dy);
      ctx.rotate(pa);
      ctx.beginPath();
      ctx.ellipse(0, -15 * sz, 4 * sz, 11 * sz, 0, 0, 6.28);
      ctx.fillStyle = p % 2 === 0 ? col : col2;
      ctx.fill();
      ctx.restore();
    }
    ctx.beginPath();
    ctx.arc(dx, dy, 10 * sz, 0, 6.28);
    ctx.fillStyle = '#451a03';
    ctx.fill();
  }
  ctx.restore();
}

/**
 * Draws the DNA Panel UI.
 */
export function drawDNAPanelUI(ctx, x, y, w, h2, t3) {
  const dna = getDNA();
  ctx.save();
  
  // Panel background
  const bg = ctx.createLinearGradient(x, y, x, y + h2);
  bg.addColorStop(0, 'rgba(0,15,30,.88)');
  bg.addColorStop(1, 'rgba(0,25,45,.92)');
  ctx.fillStyle = bg;
  ctx.beginPath();
  if (ctx.roundRect) ctx.roundRect(x, y, w, h2, 10);
  else ctx.rect(x, y, w, h2);
  ctx.fill();
  ctx.strokeStyle = 'rgba(0,200,255,.35)';
  ctx.lineWidth = 1;
  ctx.stroke();

  // Grid lines
  ctx.save();
  ctx.globalAlpha = 0.08;
  for (let gx = x + 20; gx < x + w; gx += 20) {
    ctx.beginPath();
    ctx.moveTo(gx, y);
    ctx.lineTo(gx, y + h2);
    ctx.strokeStyle = 'rgba(0,200,255,1)';
    ctx.lineWidth = 0.5;
    ctx.stroke();
  }
  for (let gy = y + 20; gy < y + h2; gy += 20) {
    ctx.beginPath();
    ctx.moveTo(x, gy);
    ctx.lineTo(x + w, gy);
    ctx.stroke();
  }
  ctx.globalAlpha = 1;
  ctx.restore();

  // Title
  ctx.fillStyle = 'rgba(0,220,255,.9)';
  ctx.font = 'bold 9px monospace';
  ctx.textAlign = 'left';
  ctx.fillText('DNA-GROWTH', x + 8, y + 14);

  // Sliders
  const sliders = [
    { label: 'CURVATURE', val: dna.curvature },
    { label: 'STEM H', val: dna.stemH },
    { label: 'PETALS', val: dna.petalCount / 10 },
    { label: 'SPREAD', val: dna.petalSpread }
  ];
  
  sliders.forEach((sl, i) => {
    const sy2 = y + 26 + i * 16;
    ctx.fillStyle = 'rgba(0,200,255,.55)';
    ctx.font = '6px monospace';
    ctx.fillText(sl.label, x + 8, sy2 + 5);
    ctx.fillStyle = 'rgba(0,40,60,.7)';
    ctx.fillRect(x + 55, sy2, w - 65, 7);
    
    const gc = ctx.createLinearGradient(x + 55, sy2, x + 55 + (w - 65) * sl.val, sy2);
    gc.addColorStop(0, 'rgba(0,255,200,.3)');
    gc.addColorStop(1, 'rgba(0,255,200,.9)');
    ctx.fillStyle = gc;
    ctx.fillRect(x + 55, sy2, (w - 65) * sl.val, 7);
    ctx.strokeStyle = 'rgba(0,200,255,.3)';
    ctx.lineWidth = 0.5;
    ctx.strokeRect(x + 55, sy2, w - 65, 7);
  });

  // Wireframe procedural flower
  const fcx = x + w / 2;
  const fcy = y + h2 - 65;
  const fh = 38 * dna.stemH;
  
  // Stem
  ctx.beginPath();
  ctx.moveTo(fcx, fcy);
  const scx = Math.sin(dna.phase * 0.3) * 12 * dna.curvature;
  ctx.bezierCurveTo(fcx + scx * 0.3, fcy - fh * 0.35, fcx + scx * 0.6, fcy - fh * 0.65, fcx + scx, fcy - fh);
  ctx.strokeStyle = 'rgba(0,255,150,.6)';
  ctx.lineWidth = 1.5;
  ctx.setLineDash([3, 3]);
  ctx.stroke();
  ctx.setLineDash([]);

  // Petals
  const n = Math.round(dna.petalCount);
  for (let p = 0; p < n; p++) {
    const pa = (Math.PI * 2 / n) * p + dna.phase * 0.04;
    const pr = 14 * dna.petalSpread;
    const ph2 = 22 * dna.petalSpread;
    ctx.save();
    ctx.translate(fcx + scx, fcy - fh);
    ctx.rotate(pa);
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.bezierCurveTo(-pr * dna.curvature * 0.6, -ph2 * 0.3, -pr * dna.curvature * 0.65, -ph2 * 0.72, 0, -ph2);
    ctx.bezierCurveTo(pr * dna.curvature * 0.65, -ph2 * 0.72, pr * dna.curvature * 0.6, -ph2 * 0.3, 0, 0);
    ctx.strokeStyle = `rgba(0,200,255,${0.4 + p / n * 0.4})`;
    ctx.lineWidth = 0.8;
    ctx.setLineDash([2, 2]);
    ctx.stroke();
    ctx.setLineDash([]);
    ctx.restore();
  }

  // Center dot
  ctx.beginPath();
  ctx.arc(fcx + scx, fcy - fh, 4, 0, 6.28);
  ctx.fillStyle = 'rgba(0,255,200,.8)';
  ctx.fill();

  // Scan line
  const scanY = y + 22 + (((dna.phase * 0.02) % 1) * (h2 - 30));
  ctx.fillStyle = 'rgba(0,200,255,0.06)';
  ctx.fillRect(x, scanY, w, 2);
  ctx.restore();
}
