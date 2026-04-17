# Module Contracts: Realtime Sanctuary Communications

**Feature**: `002-realtime-sanctuary-comms`  
**Phase**: 1 — Design  
**Date**: 2026-04-17

These contracts define the public JavaScript API that each new feature module exposes to `src/main.js`. They are UI contracts — not REST APIs.

---

## `src/features/chat/index.js`

```js
/**
 * Initializes the Chat feature.
 * Mounts the floating chat button and panel, subscribes to realtime messages.
 * Must be called AFTER authentication succeeds.
 *
 * @param {Object} user - The authenticated user session object
 * @param {string} user.key  - 'khent' or 'clair' (used as sender in DB)
 * @param {string} user.name - Display name ('Khent' or 'Clair Jassen')
 */
export function initChat(user): void
```

**Side effects**:
- Appends a `.chat-fab` floating button to `document.body`
- Appends a `#chat-panel` overlay to `document.body`
- Establishes a `supabase.channel('messages-realtime')` subscription on the `messages` table
- Sets a 30-second polling fallback on subscription failure
- Updates `sessionStorage['last_chat_open']` when panel is opened

**Events emitted**: none (internal rendering only)

---

## `src/features/diary/index.js`

```js
/**
 * Initializes the Diary feature.
 * Mounts the diary panel and subscribes to realtime diary entry updates.
 * Replaces the old diary-panel.js stub entirely.
 * Must be called AFTER authentication succeeds.
 *
 * @param {Object} user - The authenticated user session object
 * @param {string} user.key  - 'khent' or 'clair'
 * @param {string} user.name - Display name
 */
export function initDiary(user): void
```

**Side effects**:
- Mounts a `.diary-fab` floating button to `document.body`
- Appends a `#diary-panel` overlay to `document.body`
- Establishes a `supabase.channel('diary-realtime')` subscription on the `diary` table
- Sets a 30-second polling fallback on subscription failure

**Breaking change**: The previous `initDiary()` signature (no arguments) is retired. The new signature requires the `user` object.

---

## `src/features/memories/index.js`

```js
/**
 * Initializes the Memories (gallery) feature.
 * Mounts the memories panel with photo upload and realtime gallery.
 * Must be called AFTER authentication succeeds.
 *
 * @param {Object} user - The authenticated user session object
 * @param {string} user.key  - 'khent' or 'clair'
 * @param {string} user.name - Display name
 */
export function initMemories(user): void
```

**Side effects**:
- Mounts a `.memories-fab` floating button to `document.body`
- Appends a `#memories-panel` overlay to `document.body`
- Establishes a `supabase.channel('memories-realtime')` subscription on the `memories` table
- Sets a 30-second polling fallback on subscription failure
- Handles file validation (type + size) before any upload is attempted

---

## `src/main.js` Integration Contract

The updated `launchFeatures(user)` function in `main.js` must call all three initializers:

```js
import { initChat } from './features/chat';
import { initDiary } from './features/diary';       // new real module
import { initMemories } from './features/memories'; // new module

function launchFeatures(user) {
  initGarden('world');
  initWeatherFeature();
  initChat(user);      // NEW
  initDiary(user);     // REPLACED (was: initDiary() with no args)
  initMemories(user);  // NEW
}
```

**Retired imports** (must be removed from `main.js`):
- `import { initDiary } from './features/diary'` — old signature, no-arg version

---

## Shared Realtime Helper Contract

A shared helper in `src/shared/api/realtime.js` will abstract the channel + polling pattern:

```js
/**
 * Creates a realtime subscription with automatic polling fallback.
 *
 * @param {string} channelName   - Unique channel identifier
 * @param {string} table         - Supabase table name
 * @param {Function} onInsert    - Called with (newRow) on INSERT
 * @param {Function} fetchAll    - Called every 30s as polling fallback
 * @returns {{ unsubscribe: Function }} - Cleanup handle
 */
export function subscribeWithFallback(channelName, table, onInsert, fetchAll)
```
