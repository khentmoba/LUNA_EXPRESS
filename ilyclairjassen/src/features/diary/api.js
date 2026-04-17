import { DB } from '../../shared/api/supabase.js';

/**
 * Diary API — Supabase CRUD for the diary table.
 */

/**
 * Fetch all diary entries, newest first.
 * @returns {Promise<Array>}
 */
export async function fetchDiaryEntries() {
  return DB.select('diary', { orderField: 'date', descending: true });
}

/**
 * Create a new diary entry (write-once — no update/delete exposed).
 * @param {Object} user    - { key: 'khent'|'clair', name: string }
 * @param {string} title   - Entry title
 * @param {string} content - Entry body text
 * @returns {Promise<Object>} Inserted row
 */
export async function createDiaryEntry(user, title, content) {
  const rows = await DB.insert('diary', {
    title: title.trim(),
    content: content.trim(),
    date: new Date().toISOString(),
    added_by: user.key
  });
  return rows?.[0] ?? null;
}
