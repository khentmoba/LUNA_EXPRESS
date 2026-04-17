# Feature Specification: Realtime Sanctuary Communications

**Feature Directory**: `specs/002-realtime-sanctuary-comms`  
**Created**: 2026-04-17  
**Status**: Clarified  
**Input**: "i want to add a realtime chat system and a diary that will persist and stay within the site as well as a memory (with an uploadable picture), and ofc for example if khent is the one who made the memory or diary, clair jassen would be able to read it instantly, as well as receiving messages from the chat system and it can be vice versa too"

---

## Clarifications

### Session 2026-04-17

- Q: Should the new real-time features replace or extend the existing stub `diary-panel.js` overlay? → A: Replace entirely — remove `diary-panel.js`; build three separate new feature modules: `src/features/chat/`, `src/features/diary/` (real), and `src/features/memories/` (real).
- Q: Is `Message.read_status` / read receipts (e.g., ✓✓ indicator) in scope? → A: Out of scope — remove `read_status` from Message entity; no read receipt UI in v1.
- Q: How is the chat panel accessed by the user? → A: Fixed floating button in the bottom-right corner of the screen, consistent with the existing sound toggle and vault buttons in the current UI.
- Q: What should happen to real-time subscriptions when connectivity drops and resumes mid-session? → A: Auto-reconnect silently — the system re-establishes the subscription automatically and fetches any missed messages/entries when connectivity returns; no user action required.
- Q: Should diary entries support editing after saving? → A: Write-once — diary entries are permanent, uneditable reflections; they cannot be modified after saving.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Send and Receive Messages in Real Time (Priority: P1)

Khent opens the Eternal Sanctuary and taps the chat floating button in the bottom-right corner. A chat panel slides open. He types a short message like "I miss you 🌸" and presses Enter. The message appears in his chat panel immediately. On Clair Jassen's device, the same message pops up in real time — without her needing to refresh — so they feel genuinely connected even when apart.

**Why this priority**: Real-time chat is the most time-sensitive and emotionally core feature. A message should arrive the moment it is sent — delay breaks the intimacy effect entirely.

**Independent Test**: Open the sanctuary on two separate devices (one as Khent, one as Clair Jassen). Send a message from one device and confirm it appears on the other device within 2 seconds, with no manual action required.

**Acceptance Scenarios**:

1. **Given** both users have the sanctuary open, **When** Khent sends a message, **Then** Clair Jassen sees it appear in the chat panel instantly (under 2 seconds) with a timestamp and Khent's display name.
2. **Given** Clair Jassen has the sanctuary open and Khent's device is offline, **When** Khent later sends a message after reconnecting, **Then** it appears in the shared chat history with its original send time.
3. **Given** a user scrolls through the chat, **When** they view older messages, **Then** all messages since the beginning of the chat are visible in chronological order.
4. **Given** either user sends a message, **When** the other user is not currently viewing the chat panel, **Then** a visible notification badge appears on the floating chat button.
5. **Given** the real-time subscription drops due to lost connectivity, **When** connectivity is restored, **Then** the system auto-reconnects and any messages sent during the outage appear immediately without user action.

---

### User Story 2 — Write and Read Diary Entries (Priority: P2)

Khent wants to leave a personal reflection inside the sanctuary — something like a letter for Clair Jassen to read. He opens the Diary panel (separate from chat), writes a title and body, and saves it. The entry is permanent and cannot be edited. Clair Jassen, on her device, immediately sees the new diary entry appear in the Diary panel, complete with Khent's name and the time it was written. She can read all past entries from both of them in chronological order.

**Why this priority**: Diary entries are asynchronous — they carry emotional weight and longevity. They persist across sessions and create a shared story over time. Their write-once nature preserves authenticity.

**Independent Test**: While logged in as Khent, write and save a diary entry. Switch devices and log in as Clair Jassen — confirm the diary entry appears immediately without a page refresh, with author name and timestamp. Confirm the entry has no edit option.

**Acceptance Scenarios**:

1. **Given** Khent is authenticated, **When** he fills in a diary title and body and saves it, **Then** the entry is immediately visible to both users in the Diary panel with his name and timestamp.
2. **Given** multiple diary entries exist from both users, **When** either user opens the Diary panel, **Then** all entries are shown newest-first, each with author name, date, and full text.
3. **Given** a user reads an existing diary entry, **When** they close and reopen the sanctuary, **Then** the entry is still present (fully persisted, not lost on refresh).
4. **Given** Clair Jassen writes a diary entry while Khent has the sanctuary open, **When** the entry is saved, **Then** it appears in Khent's Diary panel in real time without refreshing.
5. **Given** a diary entry has been saved, **When** either user views it, **Then** there is no edit or modify option visible — the entry is read-only.

---

### User Story 3 — Upload and View Shared Memories (Priority: P3)

Khent wants to commemorate a moment — a photo from a date, a screenshot of a funny conversation. He opens the Memories panel (separate from diary and chat), uploads a photo, adds a caption, and saves it. The memory immediately appears in the shared gallery. Clair Jassen sees it in real time on her side, complete with the photo, caption, Khent's name, and when it was added.

**Why this priority**: Memories are richer than diary entries (they include a photo) but are secondary to real-time message intimacy. They enhance the "living scrapbook" feel of the sanctuary.

**Independent Test**: Log in as Khent, upload a photo with a caption. On a second device as Clair Jassen, confirm the new memory with image and caption appears immediately in the Memory gallery without refreshing.

**Acceptance Scenarios**:

1. **Given** Khent is authenticated, **When** he selects an image file and enters a caption and saves, **Then** the memory appears in both users' gallery within 3 seconds, showing the photo, caption, Khent's display name, and timestamp.
2. **Given** the gallery contains multiple memories, **When** either user opens the Memories panel, **Then** all memories are shown in reverse chronological order (newest first).
3. **Given** a memory has been uploaded, **When** either user taps/clicks the photo, **Then** it opens in a full-size view overlay.
4. **Given** a user attempts to upload a file that is not an image (e.g., a PDF), **When** they submit, **Then** the system rejects it with a clear, gentle error message.
5. **Given** a user uploads an image, **When** the upload is in progress, **Then** a loading indicator is shown so the user knows something is happening.

---

### Edge Cases

- What happens when a user sends a message and immediately loses internet connection? The message is visually marked as "sending…" and either confirmed or shown as failed when connectivity returns. The subscription auto-reconnects silently on resume.
- What happens if both users write a diary entry simultaneously? Each is saved independently without overwriting the other.
- What happens if the photo upload exceeds 10 MB? The system rejects it with a clear message before any upload attempt begins.
- What happens when one user has the chat panel closed and a new message arrives? A badge/indicator on the floating chat button notifies them.
- What happens if the same sanctuary is opened in two tabs by one user? Messages and entries appear consistently across both tabs via the shared real-time subscription.
- What happens if a user tries to edit a diary entry? No edit affordance exists — entries are displayed read-only from the moment they are saved.

---

## Requirements *(mandatory)*

### Functional Requirements

**Chat System**

- **FR-001**: The system MUST provide a persistent, shared chat panel accessible by both Khent and Clair Jassen via a fixed floating button in the bottom-right corner of the sanctuary.
- **FR-002**: Messages sent by either user MUST appear on the other user's screen within 2 seconds without requiring a manual refresh.
- **FR-003**: Each message MUST display the sender's display name, message content, and timestamp.
- **FR-004**: The complete chat history MUST be persisted and fully visible when either user opens the chat panel.
- **FR-005**: When a new message arrives and the chat panel is not open, the system MUST display a visual notification badge on the floating chat button.
- **FR-006**: The chat input MUST support plain text; messages are sent by pressing Enter or tapping a send button.
- **FR-007**: When the real-time connection drops, the system MUST automatically reconnect and fetch any missed messages upon connectivity restoration — no user action required.

**Diary Entries**

- **FR-008**: Either authenticated user MUST be able to create a diary entry with a title and a body (multi-line text) via a dedicated Diary panel (separate from chat and memories).
- **FR-009**: A saved diary entry MUST be immediately visible to both users in real time without requiring a page refresh.
- **FR-010**: All diary entries MUST be persisted and displayed in reverse chronological order (newest first), each showing the author's display name and creation timestamp.
- **FR-011**: Diary entries MUST survive page refreshes and new sessions — they are permanent records.
- **FR-012**: Diary entries MUST be write-once — no edit or delete functionality is provided after saving.

**Memory Uploads**

- **FR-013**: Either authenticated user MUST be able to upload an image file and attach a text caption to create a memory via a dedicated Memories panel (separate from chat and diary).
- **FR-014**: A newly created memory MUST appear in both users' galleries in real time within 3 seconds of saving.
- **FR-015**: All memories MUST be displayed in reverse chronological order, each showing the photo (thumbnail), caption, author display name, and timestamp.
- **FR-016**: Clicking/tapping a memory photo MUST open it in a full-size overlay view.
- **FR-017**: The system MUST reject non-image file uploads and display a clear error message.
- **FR-018**: The system MUST reject image files exceeding 10 MB and display an appropriate message before any upload attempt.
- **FR-019**: A progress/loading indicator MUST be shown while an image is being uploaded.

**General / Cross-Cutting**

- **FR-020**: All three features (chat, diary, memories) MUST only be accessible to authenticated users (behind the existing birthday gatekeeper).
- **FR-021**: Attribution MUST be accurate — content created by Khent is labelled as Khent's; content by Clair Jassen is labelled as hers.
- **FR-022**: All content (messages, diary entries, memories) MUST persist indefinitely; no deletion functionality is provided in v1.
- **FR-023**: The existing `diary-panel.js` stub MUST be removed and replaced by the three new dedicated feature modules.

### Key Entities

- **Message**: A single chat entry. Has: sender identity, content (text), timestamp. *(read_status excluded — out of scope for v1)*
- **DiaryEntry**: A journal post. Has: author identity, title, body text, creation timestamp. Write-once — immutable after creation.
- **Memory**: A commemorated moment. Has: author identity, image (stored file reference), caption, creation timestamp.
- **User Session**: The currently authenticated user (Khent or Clair Jassen). Determines authorship and display name throughout the session.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A message sent by one user appears on the other user's screen in under 2 seconds under normal network conditions — verified by sending 10 test messages and measuring appearance time.
- **SC-002**: All diary entries and memories created in a session remain visible after the sanctuary is closed and reopened — zero data loss across 5 test session cycles.
- **SC-003**: A new diary entry or memory created by one user appears on the other user's screen without any manual action (refresh, click, reload) — confirmed in 100% of test cases.
- **SC-004**: A memory photo upload completes and the memory appears in the gallery within 3 seconds for image files under 5 MB on a standard connection.
- **SC-005**: Non-image files and images over 10 MB are rejected before any upload occurs and a clear message is shown — confirmed in 100% of attempted test cases.
- **SC-006**: A notification badge appears on the floating chat button when a new message arrives while the chat panel is closed — confirmed in 100% of test cases across both user accounts.
- **SC-007**: The chat history shows all messages ever sent, in correct chronological order, every time the panel is opened.
- **SC-008**: After a connectivity drop and restoration, all missed messages appear automatically without user action — verified by simulating an offline/online transition during an active chat session.
- **SC-009**: No edit affordance is present on any saved diary entry — confirmed visually on both user accounts across 5 different entries.

---

## Assumptions

- The existing authentication system (birthday gatekeeper + `sessionStorage`) determines which user is active. Attribution uses this identity — no separate login is needed.
- Both users will access the sanctuary from a modern mobile or desktop browser with internet connectivity.
- The existing Supabase project (`qozvdxgkvxfelixuuogb.supabase.co`) will be used for storing messages, diary entries, memory metadata, and image files. No new backend infrastructure is required.
- The existing `garden-images` storage bucket (or a dedicated new bucket) will be used for memory photo uploads.
- The existing `diary-panel.js` stub will be **removed entirely** and replaced by three separate, real feature modules.
- Read receipts / `read_status` are explicitly **out of scope** for v1 — the Message entity does not track read state.
- The chat panel is accessed via a **fixed floating button in the bottom-right corner**, consistent with the sound toggle and other existing fixed UI buttons.
- Real-time subscriptions **auto-reconnect silently** on connectivity restoration; no user action or notification is required for the reconnect itself.
- Diary entries and memories are **write-once** — no editing or deletion is provided in v1.
- Deletion of individual messages, diary entries, or memories is out of scope for this version.
- The chat does not need to support media (images/GIFs) in messages — text only in v1.
- Push notifications (e.g., when the browser tab is not focused or the device is locked) are out of scope for this version. The notification badge applies within the app only.
- The three features will be integrated into the existing sanctuary UI as accessible panels/overlays, consistent with the current mystical aesthetic.
