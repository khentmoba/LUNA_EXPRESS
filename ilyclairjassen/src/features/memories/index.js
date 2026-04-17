import { subscribeWithFallback } from '../../shared/api/realtime.js';
import { fetchMemories } from './api.js';
import { mountMemoriesUI, renderAllMemories, prependMemory } from './memories.js';

/**
 * Memories Feature — Entry Point
 * @param {Object} user - { key: 'khent'|'clair', name: string }
 */
export function initMemories(user) {
  console.log('[Memories] Initializing for:', user.name);

  // Mount UI
  mountMemoriesUI(user);

  // Fetch + render gallery on init
  async function fetchAll() {
    try {
      const memories = await fetchMemories();
      renderAllMemories(memories);
    } catch (err) {
      console.error('[Memories] Failed to fetch memories:', err);
    }
  }

  // Realtime subscription — new memory rows fire prependMemory
  subscribeWithFallback(
    'memories-realtime',
    'memories',
    (newRow) => prependMemory(newRow),
    fetchAll
  );

  fetchAll();

  console.log('[Memories] ✅ Realtime gallery ready');
}
