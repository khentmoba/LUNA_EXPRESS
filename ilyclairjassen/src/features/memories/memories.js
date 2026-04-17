import './memories.css';
import { createMemory, fetchMemories, ValidationError } from './api.js';

/**
 * Memories UI — gallery panel with upload form and lightbox.
 * All analysis findings addressed:
 *   A2: lightbox closes on click-outside, Escape key, AND close button
 *   FR-017/FR-018: validation fires immediately on file select (not on submit)
 */

let _user = null;
let _panel = null;
let _fab = null;
let _grid = null;

/**
 * Mount the Memories FAB + panel into the DOM.
 * @param {Object} user - { key: 'khent'|'clair', name: string }
 */
export function mountMemoriesUI(user) {
  _user = user;

  // --- FAB ---
  _fab = document.createElement('button');
  _fab.className = 'sanctuary-fab memories-fab';
  _fab.id = 'memories-fab';
  _fab.setAttribute('aria-label', 'Open memories gallery');
  _fab.innerHTML = '📷';
  _fab.addEventListener('click', togglePanel);
  document.body.appendChild(_fab);

  // --- Panel ---
  _panel = document.createElement('div');
  _panel.id = 'memories-panel';
  _panel.className = 'sanctuary-panel';
  _panel.style.display = 'none';
  _panel.innerHTML = `
    <div class="sanctuary-panel-header">
      <span class="sanctuary-panel-title">Memories ✦</span>
      <button class="sanctuary-panel-close" id="memories-close" aria-label="Close memories">✕</button>
    </div>
    <div class="sanctuary-panel-body">

      <div id="memories-form">
        <label class="memories-form-label">Add a Memory</label>
        <input type="file" id="memories-file-input" accept="image/*">
        <label for="memories-file-input" id="memories-file-label">
          📸 Tap to choose a photo
        </label>
        <img id="memories-preview" style="display:none" alt="Preview">
        <input id="memories-caption-input" type="text" placeholder="Describe this moment…" maxlength="300" autocomplete="off">
        <div class="memories-progress-wrap" id="memories-progress-wrap">
          <div class="memories-progress-bar" id="memories-progress-bar" style="width:0%"></div>
        </div>
        <button id="memories-submit" disabled>Save Memory ✦</button>
        <div class="memories-error" id="memories-error"></div>
      </div>

      <hr class="memories-divider">

      <div id="memories-grid" class="sanctuary-empty-wrap">
        <div class="sanctuary-empty">No memories yet — add the first one 🌸</div>
      </div>
    </div>
  `;
  document.body.appendChild(_panel);

  _grid = _panel.querySelector('#memories-grid');

  // Wire close button (A2 fix: all 3 close mechanisms)
  _panel.querySelector('#memories-close').addEventListener('click', closePanel);
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && _panel.style.display !== 'none') closePanel();
  });

  // Wire file input — validate immediately on change (FR-017, FR-018)
  const fileInput = _panel.querySelector('#memories-file-input');
  const fileLabel = _panel.querySelector('#memories-file-label');
  const preview = _panel.querySelector('#memories-preview');
  const submitBtn = _panel.querySelector('#memories-submit');
  const errorEl = _panel.querySelector('#memories-error');

  fileInput.addEventListener('change', () => {
    const file = fileInput.files?.[0];
    errorEl.textContent = '';
    preview.style.display = 'none';
    submitBtn.disabled = true;

    if (!file) return;

    // Immediate validation (FR-017, FR-018 — before any upload)
    if (!file.type.startsWith('image/')) {
      errorEl.textContent = 'Only image files are allowed (JPEG, PNG, GIF, WebP, etc.).';
      fileInput.value = '';
      return;
    }
    if (file.size > 10 * 1024 * 1024) {
      errorEl.textContent = 'This image is too large. Please choose one under 10 MB.';
      fileInput.value = '';
      return;
    }

    // Show preview
    const reader = new FileReader();
    reader.onload = (e) => {
      preview.src = e.target.result;
      preview.style.display = 'block';
      fileLabel.textContent = `✓ ${file.name}`;
    };
    reader.readAsDataURL(file);
    submitBtn.disabled = false;
  });

  // Wire upload form submission
  submitBtn.addEventListener('click', () => submitMemory(fileInput, submitBtn, errorEl));
}

/**
 * Render/replace the full gallery grid.
 * @param {Array} memories
 */
export function renderAllMemories(memories) {
  if (!_grid) return;
  _grid.innerHTML = '';

  if (!memories || memories.length === 0) {
    _grid.innerHTML = '<div class="sanctuary-empty">No memories yet — add the first one 🌸</div>';
    return;
  }

  memories.forEach(m => _grid.appendChild(buildMemoryCard(m)));
}

/**
 * Prepend a single new memory card to the top of the grid.
 * Called by the realtime onInsert callback.
 * @param {Object} memory
 */
export function prependMemory(memory) {
  if (!_grid) return;
  const empty = _grid.querySelector('.sanctuary-empty');
  if (empty) empty.remove();

  const card = buildMemoryCard(memory);
  _grid.insertBefore(card, _grid.firstChild);
}

// ─────────────────────────────────────
// Internal helpers
// ─────────────────────────────────────

function buildMemoryCard(memory) {
  const authorName = memory.added_by === 'khent' ? 'Khent' : 'Clair Jassen';
  const date = new Date(memory.date).toLocaleDateString('en-US', {
    month: 'short', day: 'numeric', year: 'numeric'
  });

  const card = document.createElement('div');
  card.className = 'memory-card';
  card.dataset.id = memory.id;
  card.innerHTML = `
    <img src="${escapeHtml(memory.url)}" alt="${escapeHtml(memory.description)}" loading="lazy">
    <div class="memory-card-info">
      <div class="memory-card-caption">${escapeHtml(memory.description)}</div>
      <div class="memory-card-meta">${escapeHtml(authorName)} · ${date}</div>
    </div>
  `;

  // Open lightbox on click (FR-016)
  card.addEventListener('click', () => openLightbox(memory.url, memory.description));
  return card;
}

async function submitMemory(fileInput, submitBtn, errorEl) {
  const file = fileInput.files?.[0];
  const caption = _panel.querySelector('#memories-caption-input').value.trim();
  errorEl.textContent = '';

  if (!file) {
    errorEl.textContent = 'Please choose a photo first.';
    return;
  }

  // Show progress bar (FR-019)
  const progressWrap = _panel.querySelector('#memories-progress-wrap');
  const progressBar = _panel.querySelector('#memories-progress-bar');
  progressWrap.style.display = 'block';
  progressBar.style.width = '30%';
  submitBtn.disabled = true;
  submitBtn.textContent = 'Uploading…';

  try {
    progressBar.style.width = '60%';
    await createMemory(_user, file, caption || 'A moment to remember');
    progressBar.style.width = '100%';

    // Reset form
    fileInput.value = '';
    _panel.querySelector('#memories-caption-input').value = '';
    _panel.querySelector('#memories-preview').style.display = 'none';
    _panel.querySelector('#memories-file-label').textContent = '📸 Tap to choose a photo';
    setTimeout(() => {
      progressWrap.style.display = 'none';
      progressBar.style.width = '0%';
    }, 600);

    // Realtime subscription will prepend the new card automatically
  } catch (err) {
    progressWrap.style.display = 'none';
    progressBar.style.width = '0%';

    if (err instanceof ValidationError) {
      errorEl.textContent = err.message;
    } else {
      console.error('[Memories] Upload failed:', err);
      errorEl.textContent = 'Upload failed. Please check your connection and try again.';
    }
  } finally {
    submitBtn.disabled = false;
    submitBtn.textContent = 'Save Memory ✦';
  }
}

function openLightbox(url, caption) {
  const existing = document.getElementById('memories-lightbox');
  if (existing) existing.remove();

  const lightbox = document.createElement('div');
  lightbox.id = 'memories-lightbox';
  lightbox.setAttribute('role', 'dialog');
  lightbox.setAttribute('aria-label', 'Memory full size view');
  lightbox.innerHTML = `
    <img src="${escapeHtml(url)}" alt="${escapeHtml(caption)}">
    <button id="lightbox-close" aria-label="Close lightbox">✕</button>
  `;
  document.body.appendChild(lightbox);

  // A2 fix: all 3 close mechanisms
  // 1. Close button
  lightbox.querySelector('#lightbox-close').addEventListener('click', (e) => {
    e.stopPropagation();
    closeLightbox(lightbox);
  });

  // 2. Click outside the image
  lightbox.addEventListener('click', (e) => {
    if (e.target === lightbox) closeLightbox(lightbox);
  });

  // 3. Escape key
  const escHandler = (e) => {
    if (e.key === 'Escape') {
      closeLightbox(lightbox);
      document.removeEventListener('keydown', escHandler);
    }
  };
  document.addEventListener('keydown', escHandler);
}

function closeLightbox(lightbox) {
  lightbox?.remove();
}

function togglePanel() {
  _panel.style.display === 'none' ? openPanel() : closePanel();
}

function openPanel() {
  _panel.style.display = 'flex';
}

function closePanel() {
  _panel.style.display = 'none';
}

function escapeHtml(str) {
  return String(str ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}
