import './diary.css';
import { fetchDiaryEntries, createDiaryEntry } from './api.js';

/**
 * Diary UI — panel logic for the persistent diary feature.
 * Write-once: entries cannot be edited or deleted after saving.
 */

let _user = null;
let _panel = null;
let _fab = null;
let _entryList = null;

/**
 * Mount the Diary FAB + panel into the DOM.
 * @param {Object} user - { key: 'khent'|'clair', name: string }
 */
export function mountDiaryUI(user) {
  _user = user;

  // --- FAB ---
  _fab = document.createElement('button');
  _fab.className = 'sanctuary-fab diary-fab';
  _fab.id = 'diary-fab';
  _fab.setAttribute('aria-label', 'Open diary');
  _fab.innerHTML = '📖';
  _fab.addEventListener('click', togglePanel);
  document.body.appendChild(_fab);

  // --- Panel ---
  _panel = document.createElement('div');
  _panel.id = 'diary-panel';
  _panel.className = 'sanctuary-panel';
  _panel.style.display = 'none';
  _panel.innerHTML = `
    <div class="sanctuary-panel-header">
      <span class="sanctuary-panel-title">Our Diary ✦</span>
      <button class="sanctuary-panel-close" id="diary-close" aria-label="Close diary">✕</button>
    </div>
    <div class="sanctuary-panel-body">

      <div id="diary-form">
        <label class="diary-form-label" for="diary-title-input">New Entry</label>
        <input id="diary-title-input" type="text" placeholder="A title for this moment…" maxlength="120" autocomplete="off">
        <textarea id="diary-body-input" placeholder="Pour your heart out…" maxlength="8000"></textarea>
        <button id="diary-submit">Save Entry ✦</button>
        <div class="diary-error" id="diary-error"></div>
      </div>

      <hr class="diary-divider">

      <div id="diary-entries">
        <div class="sanctuary-empty">No entries yet — write the first one 🌿</div>
      </div>
    </div>
  `;
  document.body.appendChild(_panel);

  _entryList = _panel.querySelector('#diary-entries');

  // Wire close
  _panel.querySelector('#diary-close').addEventListener('click', closePanel);
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && _panel.style.display !== 'none') closePanel();
  });

  // Wire form submit
  const submitBtn = _panel.querySelector('#diary-submit');
  submitBtn.addEventListener('click', () => submitEntry(submitBtn));
}

/**
 * Render all entries (newest first). Called on init and after polling.
 * @param {Array} entries
 */
export function renderAllEntries(entries) {
  if (!_entryList) return;
  _entryList.innerHTML = '';

  if (!entries || entries.length === 0) {
    _entryList.innerHTML = '<div class="sanctuary-empty">No entries yet — write the first one 🌿</div>';
    return;
  }

  entries.forEach(entry => _entryList.appendChild(buildEntryCard(entry)));
}

/**
 * Prepend a single new entry card to the top of the list.
 * Called by the realtime onInsert callback.
 * @param {Object} entry
 */
export function prependEntry(entry) {
  if (!_entryList) return;
  const empty = _entryList.querySelector('.sanctuary-empty');
  if (empty) empty.remove();

  const card = buildEntryCard(entry);
  _entryList.insertBefore(card, _entryList.firstChild);
}

// ─────────────────────────────────────
// Internal helpers
// ─────────────────────────────────────

function buildEntryCard(entry) {
  const authorName = entry.added_by === 'khent' ? 'Khent' : 'Clair Jassen';
  const date = formatDate(entry.date);

  const card = document.createElement('div');
  card.className = 'diary-entry';
  card.dataset.id = entry.id;
  card.innerHTML = `
    <div class="diary-entry-header">
      <div class="diary-entry-title">${escapeHtml(entry.title)}</div>
      <span class="diary-author-badge">${escapeHtml(authorName)}</span>
    </div>
    <div class="diary-entry-date">${date}</div>
    <div class="diary-entry-body">${escapeHtml(entry.content)}</div>
  `;
  // No edit/delete affordance — entries are read-only after creation (FR-012)
  return card;
}

async function submitEntry(btn) {
  const titleInput = _panel.querySelector('#diary-title-input');
  const bodyInput = _panel.querySelector('#diary-body-input');
  const errorEl = _panel.querySelector('#diary-error');

  const title = titleInput.value.trim();
  const body = bodyInput.value.trim();
  errorEl.textContent = '';

  if (!title) {
    errorEl.textContent = 'Please give this entry a title.';
    titleInput.focus();
    return;
  }
  if (!body) {
    errorEl.textContent = 'The entry body cannot be empty.';
    bodyInput.focus();
    return;
  }

  btn.disabled = true;
  btn.textContent = 'Saving…';

  try {
    await createDiaryEntry(_user, title, body);
    titleInput.value = '';
    bodyInput.value = '';
    // The realtime subscription will prepend the new card automatically
  } catch (err) {
    console.error('[Diary] Save failed:', err);
    errorEl.textContent = 'Something went wrong. Please try again.';
  } finally {
    btn.disabled = false;
    btn.textContent = 'Save Entry ✦';
  }
}

function togglePanel() {
  _panel.style.display === 'none' ? openPanel() : closePanel();
}

function openPanel() {
  _panel.style.display = 'flex';
  setTimeout(() => _panel.querySelector('#diary-title-input')?.focus(), 100);
}

function closePanel() {
  _panel.style.display = 'none';
}

function formatDate(iso) {
  if (!iso) return '';
  return new Date(iso).toLocaleDateString('en-US', {
    year: 'numeric', month: 'long', day: 'numeric',
    hour: '2-digit', minute: '2-digit'
  });
}

function escapeHtml(str) {
  return String(str ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}
