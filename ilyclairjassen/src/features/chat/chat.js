import './chat.css';
import { DB } from '../../shared/api/supabase.js';

/**
 * Chat Panel — UI logic for the real-time chat feature.
 * Handles rendering, history loading, send logic, and badge management.
 * Import and call from index.js (not directly from main.js).
 */

const LAST_OPEN_KEY = 'last_chat_open';

let _user = null;
let _panel = null;
let _fab = null;
let _messageList = null;
let _isOpen = false;
let _allMessages = [];

/**
 * Build and mount the Chat FAB + panel into the DOM.
 * @param {Object} user - { key: 'khent'|'clair', name: 'Khent'|'Clair Jassen' }
 */
export function mountChatUI(user) {
  _user = user;

  // --- Floating Action Button ---
  _fab = document.createElement('button');
  _fab.className = 'sanctuary-fab chat-fab';
  _fab.id = 'chat-fab';
  _fab.setAttribute('aria-label', 'Open chat');
  _fab.innerHTML = '💬';
  _fab.addEventListener('click', togglePanel);
  document.body.appendChild(_fab);

  // --- Panel ---
  _panel = document.createElement('div');
  _panel.id = 'chat-panel';
  _panel.className = 'sanctuary-panel';
  _panel.style.display = 'none';
  _panel.innerHTML = `
    <div class="sanctuary-panel-header">
      <span class="sanctuary-panel-title">Chat ✦</span>
      <button class="sanctuary-panel-close" id="chat-close" aria-label="Close chat">✕</button>
    </div>
    <div class="sanctuary-panel-body" id="chat-messages-wrap">
      <div id="chat-messages"></div>
    </div>
    <div id="chat-input-bar">
      <textarea id="chat-input" rows="1" placeholder="Write something lovely…" maxlength="2000"></textarea>
      <button id="chat-send" aria-label="Send message">➤</button>
    </div>
  `;
  document.body.appendChild(_panel);

  _messageList = _panel.querySelector('#chat-messages');

  // Wire close button
  _panel.querySelector('#chat-close').addEventListener('click', closePanel);

  // Wire send
  const input = _panel.querySelector('#chat-input');
  const sendBtn = _panel.querySelector('#chat-send');

  input.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage(input, sendBtn);
    }
  });
  sendBtn.addEventListener('click', () => sendMessage(input, sendBtn));

  // Auto-resize textarea
  input.addEventListener('input', () => {
    input.style.height = 'auto';
    input.style.height = Math.min(input.scrollHeight, 100) + 'px';
  });

  // Close on Escape
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && _isOpen) closePanel();
  });
}

/**
 * Render/replace the full message list.
 * Called on init and after polling fallback fetches.
 * @param {Array} messages - Array of message rows from DB
 */
export function renderAllMessages(messages) {
  _allMessages = messages;
  if (!_messageList) return;
  _messageList.innerHTML = '';

  if (messages.length === 0) {
    _messageList.innerHTML = '<div class="sanctuary-empty">No messages yet — say hello 🌸</div>';
    return;
  }

  messages.forEach(msg => appendMessageBubble(msg, false));
  scrollToBottom();
  updateBadge();
}

/**
 * Append a single new message bubble.
 * Called by the realtime onInsert callback.
 * @param {Object} msg - A single message row
 * @param {boolean} scroll - Whether to scroll to bottom
 */
export function appendMessage(msg) {
  if (!_messageList) return;

  // Remove empty state if present
  const emptyEl = _messageList.querySelector('.sanctuary-empty');
  if (emptyEl) emptyEl.remove();

  appendMessageBubble(msg, true);

  // Update badge if panel is closed
  if (!_isOpen) {
    updateBadge();
  } else {
    // Panel is open — mark as seen immediately
    saveLastOpen();
  }
}

// ─────────────────────────────────────
// Internal helpers
// ─────────────────────────────────────

function appendMessageBubble(msg, animate) {
  const isMine = msg.sender === _user.key;
  const senderName = msg.sender === 'khent' ? 'Khent' : 'Clair Jassen';
  const time = formatTime(msg.created_at);

  const el = document.createElement('div');
  el.className = `chat-msg ${isMine ? 'msg-mine' : 'msg-theirs'}`;
  el.dataset.id = msg.id;
  if (!animate) el.style.animation = 'none';

  el.innerHTML = `
    <div class="chat-bubble">${escapeHtml(msg.content)}</div>
    <div class="chat-meta">${isMine ? 'You' : senderName} · ${time}</div>
  `;
  _messageList.appendChild(el);

  if (animate) scrollToBottom();
}

async function sendMessage(input, sendBtn) {
  const content = input.value.trim();
  if (!content) return;

  input.value = '';
  input.style.height = 'auto';
  sendBtn.disabled = true;

  // Optimistic bubble (pending state — addresses C2/C4 from analysis)
  const tempId = `temp-${Date.now()}`;
  const tempEl = document.createElement('div');
  tempEl.className = 'chat-msg msg-mine';
  tempEl.id = tempId;
  tempEl.innerHTML = `
    <div class="chat-bubble pending">${escapeHtml(content)}</div>
    <div class="chat-meta">Sending…</div>
  `;
  _messageList.appendChild(tempEl);
  scrollToBottom();

  try {
    await DB.insert('messages', { content, sender: _user.key });
    // On success the realtime subscription will append the real row —
    // remove the optimistic bubble to avoid duplication
    document.getElementById(tempId)?.remove();
  } catch (err) {
    console.error('[Chat] Send failed:', err);
    const pending = document.getElementById(tempId);
    if (pending) {
      pending.querySelector('.chat-bubble').classList.replace('pending', 'failed');
      pending.querySelector('.chat-meta').textContent = 'Failed to send — tap to retry';
      pending.style.cursor = 'pointer';
      pending.addEventListener('click', () => {
        pending.remove();
        input.value = content;
      });
    }
  } finally {
    sendBtn.disabled = false;
    input.focus();
  }
}

function togglePanel() {
  _isOpen ? closePanel() : openPanel();
}

function openPanel() {
  _isOpen = true;
  _panel.style.display = 'flex';
  saveLastOpen();
  updateBadge();
  setTimeout(() => _panel.querySelector('#chat-input')?.focus(), 100);
}

function closePanel() {
  _isOpen = false;
  _panel.style.display = 'none';
}

function saveLastOpen() {
  sessionStorage.setItem(LAST_OPEN_KEY, new Date().toISOString());
}

function getLastOpen() {
  return sessionStorage.getItem(LAST_OPEN_KEY); // null on first ever session
}

function updateBadge() {
  const lastOpen = getLastOpen();
  let count = 0;

  if (lastOpen === null) {
    // First session ever — show all messages as unread if panel is closed
    count = _isOpen ? 0 : _allMessages.length;
  } else {
    count = _isOpen ? 0 : _allMessages.filter(
      m => m.sender !== _user.key && new Date(m.created_at) > new Date(lastOpen)
    ).length;
  }

  let badge = _fab.querySelector('.fab-badge');

  if (count > 0) {
    if (!badge) {
      badge = document.createElement('span');
      badge.className = 'fab-badge';
      _fab.appendChild(badge);
    }
    badge.textContent = count > 9 ? '9+' : String(count);
  } else {
    badge?.remove();
  }
}

function scrollToBottom() {
  const wrap = _panel?.querySelector('#chat-messages-wrap');
  if (wrap) wrap.scrollTop = wrap.scrollHeight;
}

function formatTime(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  const h = d.getHours(), m = d.getMinutes();
  const ampm = h >= 12 ? 'PM' : 'AM';
  return `${h % 12 || 12}:${String(m).padStart(2, '0')} ${ampm}`;
}

function escapeHtml(str) {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}
