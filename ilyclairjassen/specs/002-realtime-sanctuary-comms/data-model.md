# Data Model: Realtime Sanctuary Communications

**Feature**: `002-realtime-sanctuary-comms`  
**Phase**: 1 — Design  
**Date**: 2026-04-17

---

## Entity: Message

**Table**: `messages` *(new — must be created in Supabase)*  
**Realtime**: Enable in Supabase Dashboard → Database → Replication

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `bigint` | PK, auto-increment | |
| `content` | `text` | NOT NULL | Plain text only (v1) |
| `sender` | `text` | NOT NULL | `'khent'` or `'clair'` — matches session key |
| `created_at` | `timestamptz` | NOT NULL, default `now()` | Server-assigned |

**Indexes**: `created_at ASC` (natural chat order)  
**Validation**: `content` must be non-empty after trim; `sender` must be one of the two known keys.  
**Lifecycle**: Insert-only. No update, no delete (v1).  
**Read receipts**: Explicitly excluded — no `read_at` or `read_by` column.

---

## Entity: DiaryEntry

**Table**: `diary` *(existing — add `added_by` column if missing)*  
**Realtime**: Enable in Supabase Dashboard → Database → Replication

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `bigint` | PK, auto-increment | |
| `title` | `text` | NOT NULL | Entry title |
| `content` | `text` | NOT NULL | Multi-line body |
| `date` | `timestamptz` | NOT NULL, default `now()` | Existing column name preserved |
| `added_by` | `text` | NOT NULL, default `'khent'` | Added if missing; `'khent'` or `'clair'` |

**Migration**: `ALTER TABLE diary ADD COLUMN IF NOT EXISTS added_by text NOT NULL DEFAULT 'khent';`  
**Lifecycle**: Insert-only. **Write-once — no UPDATE or DELETE** (v1).  
**Display order**: `date DESC` (newest first).

---

## Entity: Memory

**Table**: `memories` *(existing — already has all required columns)*  
**Realtime**: Enable in Supabase Dashboard → Database → Replication

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `bigint` | PK, auto-increment | |
| `url` | `text` | NOT NULL | Public URL to image in `garden-images` bucket |
| `description` | `text` | NOT NULL | Caption text |
| `date` | `timestamptz` | NOT NULL, default `now()` | |
| `added_by` | `text` | NOT NULL | `'khent'` or `'clair'` |

**Storage path convention**: `memories/{timestamp}-{sanitized-filename}` in the `garden-images` bucket.  
**File validation** (client-side, before upload):
- Must be `image/*` MIME type
- Must be ≤ 10 MB (10,485,760 bytes)

**Display order**: `date DESC` (newest first).  
**Lifecycle**: Insert-only. No update, no delete (v1).

---

## Entity: UserSession

**Source**: `sessionStorage` (existing auth system)  
**Not persisted to DB** — ephemeral per tab.

| Field | Values | Notes |
|---|---|---|
| `name` | `'Khent'`, `'Clair Jassen'` | Display name |
| `key` | `'khent'`, `'clair'` | Used as `sender` / `added_by` value in DB |

---

## Relationships

```
UserSession ──(creates)──> Message (sender = session.key)
UserSession ──(creates)──> DiaryEntry (added_by = session.key)
UserSession ──(creates)──> Memory (added_by = session.key)

Message ──(stored in)──> Supabase table: messages
DiaryEntry ──(stored in)──> Supabase table: diary
Memory ──(metadata stored in)──> Supabase table: memories
Memory ──(image stored in)──> Supabase storage: garden-images/memories/*
```

---

## Supabase Setup Checklist

Before the feature works in production, the following must be done **once** in the Supabase Dashboard:

1. ☐ Create table `messages` with columns above
2. ☐ Enable Realtime on `messages` → Database → Replication → toggle
3. ☐ Enable Realtime on `diary` → Database → Replication → toggle
4. ☐ Enable Realtime on `memories` → Database → Replication → toggle
5. ☐ Run migration: `ALTER TABLE diary ADD COLUMN IF NOT EXISTS added_by text NOT NULL DEFAULT 'khent';`
6. ☐ Confirm `garden-images` bucket exists and has public read access
