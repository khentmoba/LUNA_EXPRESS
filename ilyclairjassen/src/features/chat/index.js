import { subscribeWithFallback } from '../../shared/api/realtime.js';
import { DB } from '../../shared/api/supabase.js';
import { mountChatUI, renderAllMessages, appendMessage } from './chat.js';

/**
 * Chat Feature — Entry Point
 * @param {Object} user - { key: 'khent'|'clair', name: string }
 */
export function initChat(user) {
  console.log('[Chat] Initializing for:', user.name);

  // Mount UI
  mountChatUI(user);

  // Fetch + render history
  async function fetchAll() {
    try {
      const messages = await DB.select('messages', {
        orderField: 'created_at',
        descending: false
      });
      renderAllMessages(messages);
    } catch (err) {
      console.error('[Chat] Failed to fetch messages:', err);
    }
  }

  // Realtime subscription — new rows fire appendMessage
  subscribeWithFallback(
    'messages-realtime',
    'messages',
    (newRow) => appendMessage(newRow),
    fetchAll
  );

  // Initial load
  fetchAll();

  console.log('[Chat] ✅ Realtime chat ready');
}
