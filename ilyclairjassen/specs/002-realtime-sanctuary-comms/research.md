# Research: Realtime Sanctuary Communications

**Feature**: `002-realtime-sanctuary-comms`  
**Phase**: 0 — Pre-Design Research  
**Date**: 2026-04-17

---

## 1. Supabase Realtime Subscriptions

### Decision
Use `supabase.channel()` with `postgres_changes` events on each table (`messages`, `diary`, `memories`). This is the Supabase v2 realtime API — it triggers a callback whenever a row is INSERTed into the subscribed table.

### Rationale
- Already using `@supabase/supabase-js` v2 (confirmed in `package.json`)
- `postgres_changes` requires zero additional infrastructure — just enabling Realtime on the table in the Supabase dashboard
- Fire-and-forget subscription: one `supabase.channel().on().subscribe()` call per feature module

### Pattern
```js
supabase
  .channel('messages-realtime')
  .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'messages' }, (payload) => {
    // payload.new contains the new row
    appendMessage(payload.new);
  })
  .subscribe();
```

### Alternatives Considered
- **Supabase Broadcast** — peer-to-peer, not persisted. Rejected: messages must survive page refresh.
- **Supabase Presence** — designed for online-status tracking. Rejected: wrong use case.

---

## 2. Polling Fallback (Constitution Principle V)

### Decision
Implement a `setInterval`-based 30-second polling fallback per table, activated only when the realtime subscription reports a `CHANNEL_ERROR` or `TIMED_OUT` status.

### Rationale
- Mandated by Constitution Principle V: "A robust 30-second polling fallback must be maintained for environments with restricted WebSocket access."
- Simple to implement alongside the existing `DB.select()` helper — no new infrastructure.

### Pattern
```js
// Inside each feature module
let pollingTimer = null;

channel.subscribe((status) => {
  if (status === 'SUBSCRIBED') {
    clearInterval(pollingTimer); // realtime working — stop polling
  } else if (status === 'CHANNEL_ERROR' || status === 'TIMED_OUT') {
    pollingTimer = setInterval(() => fetchAll(), 30000);
  }
});
```

---

## 3. Database Schema Decisions

### New Table: `messages`
Required columns:

| Column | Type | Notes |
|---|---|---|
| `id` | `bigint` (auto) | Primary key |
| `content` | `text` | Message body |
| `sender` | `text` | `'khent'` or `'clair'` |
| `created_at` | `timestamptz` | Default `now()` |

Enable Realtime on this table in Supabase Dashboard.

### Existing Table: `diary`
Current columns: `id, title, content, date`. 

Add column: `added_by text` (matches `memories` table convention). If column already exists, no change. Existing rows can default to `'khent'` for backward compatibility.

### Existing Table: `memories`
Current columns: `id, url, description, date, added_by`. Already has `added_by` — fully compatible. Enable Realtime on this table.

### Storage Bucket
Use existing `garden-images` bucket. New path convention for memory uploads: `memories/{timestamp}-{filename}`.

---

## 4. Module Structure Decision

### Decision
Three new independent vertical-slice modules under `src/features/`:
- `src/features/chat/` — realtime messaging
- `src/features/diary/` — replaced with a real persistent, realtime diary (removes old stub)
- `src/features/memories/` — replaces old stub memories gallery from `diary-panel.js`

### Rationale
- Matches the established pattern (auth, garden, weather all follow the same shape)
- FR-023 explicitly mandates removing `diary-panel.js` — the old module is retired
- Each module is independently testable (per spec P1/P2/P3)

---

## 5. UI Entry Points

### Decision
- **Chat**: Fixed floating button (bottom-right), renders a slide-up panel overlay
- **Diary**: Accessible via a floating button or world element tap, renders a full overlay
- **Memories**: Accessible via a floating button or world element tap, renders a gallery overlay

### Panel styling
- All three panels follow the existing glassmorphism tokens (`var(--glass-bg)`, `var(--glass-blur)`)
- Import from `src/shared/styles/tokens.css`

---

## 6. Notification Badge

### Decision
The chat floating button renders an unread count badge. Count = rows in `messages` with `created_at` after `sessionStorage.getItem('last_chat_open')`. Reset to 0 when panel opens; update `last_chat_open` timestamp.

### Rationale
- No server-side read tracking (read_status explicitly out of scope)
- Local timestamp in `sessionStorage` is consistent with the existing session model

---

## 7. Reconnect Strategy

### Decision
On subscription status `CLOSED` or `CHANNEL_ERROR`, call `channel.subscribe()` again after a 3-second delay. If the reconnect succeeds, fetch the full list (to catch any missed rows during the gap). If the reconnect fails after 3 attempts, fall back to 30-second polling.

---

## 8. Existing `diary-panel.js` Removal

The old `src/features/diary/diary-panel.js` exports `initDiary`. The `src/main.js` imports and calls `initDiary()`. 

Migration path:
1. Remove `diary-panel.js`, `diary.css`, and the old `diary/api.js` stub
2. Replace with `src/features/diary/index.js` (new, real implementation)
3. Replace the `initDiary` import in `main.js` with the new diary module's `initDiary`
4. Add new `initChat` and `initMemories` imports/calls in `main.js`
