import { subscribeWithFallback } from '../../shared/api/realtime.js';
import { fetchDiaryEntries } from './api.js';
import { mountDiaryUI, renderAllEntries, prependEntry } from './diary.js';

/**
 * Diary Feature — Entry Point
 * Replaces the old diary-panel.js stub entirely (FR-023).
 * @param {Object} user - { key: 'khent'|'clair', name: string }
 */
export function initDiary(user) {
  console.log('[Diary] Initializing for:', user.name);

  // Mount UI
  mountDiaryUI(user);

  // Fetch + render all entries on init
  async function fetchAll() {
    try {
      const entries = await fetchDiaryEntries();
      renderAllEntries(entries);
    } catch (err) {
      console.error('[Diary] Failed to fetch entries:', err);
    }
  }

  // Realtime subscription — new diary rows fire prependEntry
  subscribeWithFallback(
    'diary-realtime',
    'diary',
    (newRow) => prependEntry(newRow),
    fetchAll
  );

  fetchAll();

  console.log('[Diary] ✅ Realtime diary ready');
}
