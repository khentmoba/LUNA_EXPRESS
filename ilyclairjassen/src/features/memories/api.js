import { DB } from '../../shared/api/supabase.js';

const BUCKET = 'garden-images';
const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10 MB

/**
 * Fetch all memories, newest first.
 * @returns {Promise<Array>}
 */
export async function fetchMemories() {
  return DB.select('memories', { orderField: 'date', descending: true });
}

/**
 * Upload an image and create a memory record.
 * Validates file type and size before any network call.
 *
 * @param {Object} user    - { key: 'khent'|'clair', name: string }
 * @param {File}   file    - The image File object
 * @param {string} caption - Caption text
 * @param {Function} onProgress - Optional (not used — Supabase SDK does not expose granular progress)
 * @returns {Promise<Object>} Inserted memory row
 */
export async function createMemory(user, file, caption) {
  // Client-side validation (FR-017, FR-018) — before any upload
  if (!file.type.startsWith('image/')) {
    throw new ValidationError('Only image files are allowed (JPEG, PNG, GIF, WebP, etc.).');
  }
  if (file.size > MAX_FILE_SIZE) {
    throw new ValidationError('This image is too large. Please choose one under 10 MB.');
  }

  // Generate a unique, safe storage path
  const safeName = file.name.replace(/[^a-z0-9._-]/gi, '_').toLowerCase();
  const storagePath = `memories/${Date.now()}-${safeName}`;

  // Upload to Supabase Storage
  await DB.uploadFile(BUCKET, storagePath, file, file.type);

  // Get the public URL
  const url = DB.publicUrl(BUCKET, storagePath);

  // Insert metadata row
  const rows = await DB.insert('memories', {
    url,
    description: caption.trim(),
    date: new Date().toISOString(),
    added_by: user.key
  });

  return rows?.[0] ?? null;
}

/**
 * Custom error class for client-side validation failures.
 * Allows the UI to distinguish validation errors from network errors.
 */
export class ValidationError extends Error {
  constructor(message) {
    super(message);
    this.name = 'ValidationError';
  }
}
