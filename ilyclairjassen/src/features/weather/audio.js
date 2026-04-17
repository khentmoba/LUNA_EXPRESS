/**
 * Weather Audio System
 * Synthesizes wind and rain sounds, and provides frequency data for visualizers.
 */

let audioCtx = null;
let analyser = null;
let dataArr = null;
let nodes = {};
let currentMode = 'off'; // 'off' | 'wind' | 'rain'
let phase = 0;

export const WeatherAudio = {
  /**
   * Initializes the Audio Context and Analyser.
   * Should be called on user interaction.
   */
  init() {
    if (audioCtx) return;
    try {
      audioCtx = new (window.AudioContext || window.webkitAudioContext)();
      analyser = audioCtx.createAnalyser();
      analyser.fftSize = 64;
      dataArr = new Uint8Array(analyser.frequencyBinCount);

      // Ambient oscillators (from SonicViz)
      for (let h = 0; h < 4; h++) {
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.type = h % 2 === 0 ? 'sine' : 'triangle';
        osc.frequency.value = [220, 330, 440, 528][h];
        gain.gain.value = 0.012;
        osc.connect(gain);
        gain.connect(analyser);
        analyser.connect(audioCtx.destination);
        osc.start();
      }
      console.log('[Audio] Context initialized');
    } catch (e) {
      console.warn('[Audio] Could not initialize Web Audio:', e);
    }
  },

  /**
   * stops all synthesized weather sounds.
   */
  stopAll() {
    for (const k in nodes) {
      try {
        if (nodes[k].stop) nodes[k].stop();
        nodes[k].disconnect();
      } catch (e) {}
    }
    nodes = {};
  },

  /**
   * Synthesizes brown noise for wind.
   */
  playWind() {
    this.stopAll();
    if (!audioCtx) return;

    const bufSize = audioCtx.sampleRate * 3;
    const buf = audioCtx.createBuffer(1, bufSize, audioCtx.sampleRate);
    const data = buf.getChannelData(0);
    let last = 0;
    for (let i = 0; i < bufSize; i++) {
      const white = (Math.random() * 2 - 1);
      data[i] = (last + 0.02 * white) / 1.02;
      last = data[i];
      data[i] *= 3.5;
    }

    const src = audioCtx.createBufferSource();
    src.buffer = buf;
    src.loop = true;

    const lp = audioCtx.createBiquadFilter();
    lp.type = 'lowpass';
    lp.frequency.value = 320;

    const gain = audioCtx.createGain();
    gain.gain.value = 0.0;

    src.connect(lp);
    lp.connect(gain);
    gain.connect(audioCtx.destination);
    src.start();

    gain.gain.linearRampToValueAtTime(0.12, audioCtx.currentTime + 2);

    // LFO for wind gusts
    const lfo = audioCtx.createOscillator();
    const lfoGain = audioCtx.createGain();
    lfoGain.gain.value = 0.07;
    lfo.frequency.value = 0.08;
    lfo.type = 'sine';
    lfo.connect(lfoGain);
    lfoGain.connect(gain.gain);
    lfo.start();

    nodes = { src, lp, gain, lfo, lfoGain };
  },

  /**
   * Synthesizes white noise filtered for rain.
   */
  playRain() {
    this.stopAll();
    if (!audioCtx) return;

    const bufSize = audioCtx.sampleRate * 2;
    const buf = audioCtx.createBuffer(1, bufSize, audioCtx.sampleRate);
    const data = buf.getChannelData(0);
    for (let i = 0; i < bufSize; i++) data[i] = Math.random() * 2 - 1;

    const src = audioCtx.createBufferSource();
    src.buffer = buf;
    src.loop = true;

    const hp = audioCtx.createBiquadFilter();
    hp.type = 'highpass';
    hp.frequency.value = 400;

    const lp2 = audioCtx.createBiquadFilter();
    lp2.type = 'lowpass';
    lp2.frequency.value = 3000;

    const gain = audioCtx.createGain();
    gain.gain.value = 0;

    src.connect(hp);
    hp.connect(lp2);
    lp2.connect(gain);
    gain.connect(audioCtx.destination);
    src.start();

    gain.gain.linearRampToValueAtTime(0.15, audioCtx.currentTime + 1.5);
    nodes = { src, hp, lp2, gain };
  },

  /**
   * Retrieves current frequency data for visualizers.
   */
  getFreqs() {
    phase += 0.04;
    if (analyser && dataArr) {
      analyser.getByteFrequencyData(dataArr);
      const out = [];
      for (let i = 0; i < dataArr.length; i++) out.push(dataArr[i] / 255);
      return out;
    }
    // Animated fallback
    const out = [];
    for (let i = 0; i < 32; i++) {
      out.push(0.08 + 0.12 * Math.sin(phase * 1.3 + i * 0.4) + 0.05 * Math.cos(phase * 2.1 + i * 0.8));
    }
    return out;
  }
};
