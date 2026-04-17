# Quickstart: Realtime Sanctuary Communications

**Feature**: `002-realtime-sanctuary-comms`  
**Date**: 2026-04-17

---

## Before You Start: Supabase Dashboard Setup

These steps must be completed **once** in the [Supabase Dashboard](https://supabase.com/dashboard/project/qozvdxgkvxfelixuuogb) before the feature will work:

### 1. Create the `messages` table

Go to **Table Editor → New Table**:

```sql
CREATE TABLE messages (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  content text NOT NULL,
  sender text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
```

### 2. Add `added_by` to `diary` (if missing)

Go to **SQL Editor** and run:

```sql
ALTER TABLE diary ADD COLUMN IF NOT EXISTS added_by text NOT NULL DEFAULT 'khent';
```

### 3. Enable Realtime on all three tables

Go to **Database → Replication** and enable Realtime for:
- `messages` ✓
- `diary` ✓
- `memories` ✓

### 4. Verify storage bucket

Confirm the `garden-images` bucket exists with **public** read access.  
Go to **Storage → garden-images → Policies** and ensure anonymous read is allowed.

---

## Environment Variables

Ensure `.env` at the project root contains:

```env
VITE_SUPABASE_URL=https://qozvdxgkvxfelixuuogb.supabase.co
VITE_SUPABASE_ANON_KEY=<your-anon-key-from-dashboard>
```

---

## Running Locally

```bash
npm install       # Install dependencies (already done)
npm run dev       # Start Vite dev server at http://localhost:5173
```

Open two browser tabs — one as Khent, one as Clair Jassen — to test realtime sync.

---

## Testing Realtime Sync

1. Open `http://localhost:5173` in **Tab A** → authenticate as Khent
2. Open `http://localhost:5173` in **Tab B** → authenticate as Clair Jassen
3. In Tab A, open the Chat panel and send a message
4. Confirm the message appears in Tab B **within 2 seconds** with no refresh

Repeat for Diary entries and Memories.

---

## Deploying to Netlify

```bash
npm run build   # Build to dist/
```

Then in **Netlify Dashboard → Site Settings → Environment Variables**, set:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

Deploy by pushing or by dropping the `dist/` folder to Netlify.
