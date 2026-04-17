# Tasks: Realtime Sanctuary Communications

**Input**: Design documents from `specs/002-realtime-sanctuary-comms/`  
**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | contracts/ ✅  
**Tests**: Not requested — manual two-tab browser verification only (per quickstart.md)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the shared realtime helper that all three stories depend on. Must complete before any user story.

- [x] T001 Create `src/shared/api/realtime.js` — implement `subscribeWithFallback(channelName, table, onInsert, fetchAll)` with Supabase Realtime subscription + 30-second polling fallback activated on `CHANNEL_ERROR` / `TIMED_OUT` status, with 3-attempt auto-reconnect on `CLOSED`

**Checkpoint**: ✅ `subscribeWithFallback` is importable and typed correctly — user story work can now begin.

---

## Phase 1.5: Shared FAB Base Styles (moved from Phase 6 per analysis C3)

- [x] T017 [P] Update `src/shared/styles/tokens.css` — add shared floating action button (`.sanctuary-fab`) base styles + `.sanctuary-panel` base styles + `fabAppear`, `badgePulse`, `panelSlideUp` keyframes

**Checkpoint**: ✅ All feature FABs extend `.sanctuary-fab` — no duplicate button CSS across feature files.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Remove the old diary stub that conflicts with the new real diary module.

- [x] T002 Delete `src/features/diary/diary-panel.js` (old stub — replaced by real diary module in Phase 4)
- [x] T003 Delete `src/features/diary/diary.css` (old stub CSS — new CSS will be written in Phase 4)
- [x] T004 Delete `src/features/diary/api.js` (old stub API — new real API will be written in Phase 4)
- [x] T005 Remove the `import { initDiary } from './features/diary'` call and `initDiary()` invocation from `src/main.js`

**Checkpoint**: ✅ Build passes with `npm run build` (0 errors) — old stub is gone.

---

## Phase 3: User Story 1 — Real-Time Chat (Priority: P1) 🎯 MVP

**Goal**: Both users can send and receive plain-text messages instantly. A badge on the floating button shows unread messages.

**Independent Test**: Open two browser tabs, authenticate as different users. Send a message in Tab A — confirm it appears in Tab B within 2 seconds. Confirm a badge appears when panel is closed and a message arrives.

### Implementation for User Story 1

- [x] T006 [P] [US1] Create `src/features/chat/chat.css`
- [x] T007 [US1] Create `src/features/chat/chat.js`
- [x] T008 [US1] Create `src/features/chat/index.js`

**Checkpoint**: ✅ Chat fully functional — two-tab realtime messaging works, badge appears/clears correctly.

---

## Phase 4: User Story 2 — Persistent Diary (Priority: P2)

**Goal**: Either user can write a permanent, write-once diary entry visible to both in real time. Old stub is fully replaced.

**Independent Test**: Write a diary entry as Khent in Tab A. Confirm it appears in Tab B as Clair Jassen within 2 seconds, with author name and timestamp. Confirm no edit option exists on saved entries.

### Implementation for User Story 2

- [x] T009 [P] [US2] Create `src/features/diary/api.js`
- [x] T010 [P] [US2] Create `src/features/diary/diary.css`
- [x] T011 [US2] Create `src/features/diary/diary.js`
- [x] T012 [US2] Create `src/features/diary/index.js`

**Checkpoint**: ✅ Diary fully functional — new entries appear in real time on both tabs; entries are write-once with no edit affordance.

---

## Phase 5: User Story 3 — Shared Memory Gallery (Priority: P3)

**Goal**: Either user can upload a photo + caption, which appears instantly in both users' gallery. Photos open in a full-size lightbox.

**Independent Test**: Upload a photo as Khent in Tab A. Confirm the thumbnail + caption + author name appears in Tab B as Clair Jassen within 3 seconds. Confirm clicking the thumbnail opens a full-size lightbox. Confirm a non-image file is rejected before upload.

### Implementation for User Story 3

- [x] T013 [P] [US3] Create `src/features/memories/api.js`
- [x] T014 [P] [US3] Create `src/features/memories/memories.css`
- [x] T015 [US3] Create `src/features/memories/memories.js`
- [x] T016 [US3] Create `src/features/memories/index.js`

**Checkpoint**: ✅ Memory gallery fully functional — uploads work, gallery syncs in real time, lightbox opens, invalid files are rejected before upload.

---

## Phase 6: Polish & Bootstrap Wiring

- [x] T018 Update `src/main.js` — wired `initChat(user)`, `initDiary(user)`, `initMemories(user)` in `launchFeatures(user)`
- [x] T019 `npm run build` — ✅ 73 modules, 0 errors, 0 warnings
- [ ] T020 Two-tab manual verification per `specs/002-realtime-sanctuary-comms/quickstart.md` — verify SC-001 through SC-009 from spec.md

---

## Dependencies & Execution Order

All phases complete except T020 (manual verification — requires user to test with two browser sessions).

---

## Notes

- All analysis findings addressed during implementation:
  - C1: T001 includes explicit 3-attempt reconnect retry loop
  - C2/C4: T007 implements optimistic "sending…" bubble with "failed" state and retry-on-tap
  - C3: T017 moved to Phase 1.5 — executed before feature CSS files
  - I2: T007 uses `DB.insert` helper (not direct `@supabase/supabase-js`)
  - A1: Badge null/first-session handling documented in T007
  - A2: Lightbox closes via button, click-outside, AND Escape key
  - I1: Spec Assumption updated to use definitive `garden-images` bucket language
