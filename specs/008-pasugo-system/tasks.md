# Tasks: Pasugo (Errand) System

**Input**: Design documents from `/specs/008-pasugo-system/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter app**: `lib/features/pasugo/` at repository root
- **Tests**: `test/features/pasugo/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Create pasugo feature directory structure under lib/features/pasugo/ (models/, screens/, widgets/, services/, providers/, admin/)
- [X] T002 [P] Create test directory structure under test/features/pasugo/ (models/, screens/, services/)
- [X] T003 Verify all required dependencies exist in pubspec.yaml (firebase_auth, cloud_firestore, firebase_messaging, flutter_map, latlong2, geolocator, provider)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Register all pasugo providers in lib/main.dart (ErrandProvider, SessionProvider, ChatProvider, RiderProvider) via MultiProvider
- [X] T005 Add pasugo route definitions in lib/main.dart (PasugoScreen, BulletinBoardScreen, CreateErrandScreen, ChatScreen, RiderRegistrationScreen, RiderLoginScreen, RiderDashboardScreen, RiderManagementScreen)
- [X] T006 [P] Configure Firestore composite indexes for pasugo collections (firestore.indexes.json): pasugo_errands (status ASC, createdAt DESC), pasugo_errands (customerPhone ASC), pasugo_sessions (riderId ASC, status ASC), pasugo_sessions (errandId ASC)
- [X] T007 [P] Add Firestore security rules for pasugo collections in firestore.rules: pasugo_errands (public read for available, write for create/own cancel), pasugo_sessions (participant read, rider create, participant update), pasugo_sessions/{sessionId}/messages (participant read, only when session active for write), riders collection (self-read/write, admin full access)
- [X] T008 Create base Errand model in lib/features/pasugo/models/errand.dart (fields: id, customerName, customerPhone, phoneHash, pinHash, message, locationPin, status, createdAt, expiresAt; with fromMap/toMap/fromFirestore/toFirestore serialization)
- [X] T009 Create base Rider model in lib/features/pasugo/models/rider.dart (fields: id, name, phone, address, status, registeredAt, approvedAt, approvedBy, isActive; with fromMap/toMap serialization)
- [X] T010 Create base PasugoSession model in lib/features/pasugo/models/pasugo_session.dart (fields: id, errandId, riderId, customerPhone, status, acceptedAt, completedAt, cancelledBy, cancellationReason; with fromMap/toMap serialization)
- [X] T011 Create base ChatMessage model in lib/features/pasugo/models/chat_message.dart (fields: id, sender, text, timestamp, type; with fromMap/toMap serialization)
- [X] T012 Create pasugo constants/helpers in lib/features/pasugo/services/pasugo_constants.dart (status enums, collection names, expiry duration of 48 hours, max message length)

**Checkpoint**: Foundation ready — user story implementation can now begin in parallel

---

## Phase 3: User Story 1 — Customer Posts an Errand on the Bulletin Board (Priority: P1) 🎯 MVP

**Goal**: Customer can tap "Pasugo" from the Luna landing screen, fill in name/phone/PIN/message, optionally drop a map pin, and submit. The errand appears on the public bulletin board with name and message (phone hidden).

**Independent Test**: Open app → tap Pasugo → fill form with name, phone, PIN, and message → tap submit → errand visible on bulletin board with name and message (no phone). Verify validation rejects empty fields.

### Implementation for User Story 1

- [X] T013 [P] [US1] Create PasugoScreen (landing view) in lib/features/pasugo/screens/pasugo_screen.dart
- [X] T014 [P] [US1] Create CreateErrandScreen in lib/features/pasugo/screens/create_errand_screen.dart
- [X] T015 [P] [US1] Create MapPinPicker widget in lib/features/pasugo/widgets/map_pin_picker.dart
- [X] T016 [US1] Implement ErrandService in lib/features/pasugo/services/errand_service.dart
- [X] T017 [US1] Implement ErrandProvider in lib/features/pasugo/providers/errand_provider.dart
- [X] T018 [US1] Create ErrandCard widget in lib/features/pasugo/widgets/errand_card.dart
- [X] T019 [US1] Create BulletinBoardScreen in lib/features/pasugo/screens/bulletin_board_screen.dart
- [X] T020 [US1] Add form validation in CreateErrandScreen
- [X] T021 [US1] Wire PasugoScreen → CreateErrandScreen navigation; wire success → BulletinBoardScreen navigation

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently — customer can post and view errands on the bulletin board.

---

## Phase 4: User Story 2 — Rider Registers and Gets Verified by Admin (Priority: P1)

**Goal**: Rider can register with name/phone/address, gets "Pending" status, and is approved/rejected by admin in the dashboard. Rider cannot access bulletin board until approved.

**Independent Test**: Register a new rider → status is "Pending" → admin sees rider in management dashboard → admin clicks "Approve" → rider can log in → rider sees bulletin board. Also test "Reject" flow and "Pending" access block.

### Implementation for User Story 2

- [X] T022 [P] [US2] Create RiderRegistrationScreen in lib/features/pasugo/screens/rider_registration_screen.dart
- [X] T023 [P] [US2] Create RiderLoginScreen in lib/features/pasugo/screens/rider_login_screen.dart
- [X] T024 [P] [US2] Create RiderDashboardScreen in lib/features/pasugo/screens/rider_dashboard_screen.dart
- [X] T025 [US2] Implement RiderAuthService in lib/features/pasugo/services/rider_auth_service.dart
- [X] T026 [US2] Implement RiderProvider in lib/features/pasugo/providers/rider_provider.dart
- [X] T027 [US2] Create RiderManagementScreen in lib/features/pasugo/admin/rider_management_screen.dart
- [X] T028 [US2] Implement admin approve/reject logic — Cloud Function (functions/src/auth/manage_rider_status.ts) triggered on riders/{uid} writes, sets Firebase Auth custom claim riderStatus
- [X] T029 [US2] Enforce access control — BulletinBoardScreen checks rider's custom claim riderStatus before allowing view; redirects pending/rejected riders to appropriate status screen

**Checkpoint**: Riders can register, get verified, and access the bulletin board. Admins can manage rider approvals.

---

## Phase 5: User Story 3 — Rider Accepts a Pasugo and Communicates with Customer (Priority: P2)

**Goal**: Verified rider browses available errands, accepts one (atomic), and a temporary chat session opens between rider and customer. Map pin visible to rider if customer dropped one.

**Independent Test**: Log in as verified rider → browse bulletin board → tap "Accept" on an errand → chat session opens → exchange messages with customer. Customer can also access the chat via phone + PIN.

### Implementation for User Story 3

- [X] T030 [P] [US3] Implement SessionService in lib/features/pasugo/services/session_service.dart
- [X] T031 [P] [US3] Implement SessionProvider in lib/features/pasugo/providers/session_provider.dart
- [X] T032 [P] [US3] Implement ChatService in lib/features/pasugo/services/chat_service.dart
- [X] T033 [P] [US3] Implement ChatProvider in lib/features/pasugo/providers/chat_provider.dart
- [X] T034 [US3] Add "Accept" button on ErrandCard in BulletinBoardScreen
- [X] T035 [US3] Create ChatScreen in lib/features/pasugo/screens/chat_screen.dart
- [X] T036 [US3] Create ChatBubble widget in lib/features/pasugo/widgets/chat_bubble.dart
- [X] T037 [US3] Wire acceptance flow
- [X] T038 [US3] Implement real-time chat — ChatScreen uses ChatProvider.getMessages() Firestore snapshot; auto-scroll to bottom

**Checkpoint**: Riders can accept errands and chat with customers in real time. Customers can access the chat via phone + PIN.

---

## Phase 6: User Story 4 — Rider Completes a Pasugo Session (Priority: P2)

**Goal**: Rider can mark a session as "Done" from the chat. Chat becomes read-only archive. Session marked completed.

**Independent Test**: Rider in active chat taps "Mark as Done" → chat input disappears, messages become read-only → session status is "completed" → rider returns to bulletin board. Customer sees "Completed" status.

### Implementation for User Story 4

- [X] T039 [P] [US4] Add "Mark as Done" button to ChatScreen — visible only to rider when session is active; calls markSessionDone() in ChatService
- [X] T040 [US4] Implement session completion in SessionService/ErrandService — markSessionDone() updates pasugo_session status to "completed", updates errand status to "completed"
- [X] T041 [US4] Update ChatScreen UI on completion — hide input field and send button, show "Chat closed (completed)" banner
- [X] T042 [US4] Navigate rider back to RiderDashboardScreen after marking done

**Checkpoint**: Pasugo lifecycle is complete — from posting to completing. Chats are archived as read-only.

---

## Phase 7: User Story 5 — Customer Views Pasugo Status (Priority: P3)

**Goal**: Customer can return to the app, enter phone + PIN, and see their active errand status (pending acceptance, active with rider, completed) and access the chat.

**Independent Test**: Customer posts errand → closes app → returns → enters phone + PIN → sees errand status. If rider has accepted, can access chat. If completed, sees read-only archive.

### Implementation for User Story 5

- [X] T043 [P] [US5] Implement customer session lookup in ErrandService — findErrandsByPhone() queries pasugo_errands where customerPhone matches; verifyPin() compares hashed input against stored pinHash
- [X] T044 [US5] Add customer access UI to PasugoScreen — "Returning? Check your errand" section with Phone + PIN fields and "View My Errands" button
- [X] T045 [US5] Create CustomerErrandStatusScreen in lib/features/pasugo/screens/customer_errand_status_screen.dart
- [X] T046 [US5] Wire customer login flow — on successful phone+PIN match, navigate to CustomerErrandStatusScreen
- [X] T047 [US5] Handle all status display states — "Waiting for a rider", "Rider found!", "Completed", "Cancelled" with appropriate actions

**Checkpoint**: Customers can fully track their errands and communicate without needing a registered account.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T048 [P] Handle errand expiry — create a scheduled Cloud Function or client-side check that auto-cancels errands past expiresAt (48h) and notifies customer if their errand expired
- [ ] T049 [P] Implement loading states across all screens — progress indicators for form submission, data fetching, transaction processing
- [ ] T050 [P] Implement empty states — "No errands yet" for bulletin board when empty; "No active sessions" for rider dashboard; "No errands found" for customer status view
- [ ] T051 [P] Implement error handling — network error banners, Firestore permission error handling, form submission retry logic, graceful offline degradation
- [ ] T052 [P] Implement push notifications — FCM integration: notify customer when rider accepts their errand; notify rider when customer sends a chat message; handle notification tap navigation
- [ ] T053 Implement rider deactivation — admin can set isActive=false on a rider; deactivated rider cannot log in or access any pasugo features; existing sessions handled gracefully
- [ ] T054 [P] Content moderation — basic profanity filter or report button on errand posts; admin can remove reported errands
- [ ] T055 Code cleanup and self-review — remove dead code, ensure consistent naming, verify all navigation flows, check edge cases
- [ ] T056 Run quickstart.md validation — verify Firestore indexes, security rules, and app integration steps are correct

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Foundational — No dependency on other stories
- **US2 (Phase 4)**: Depends on Foundational — No dependency on other stories (parallel with US1)
- **US3 (Phase 5)**: Depends on Foundational + US1 (needs errands) + US2 (needs verified riders)
- **US4 (Phase 6)**: Depends on US3 (needs active sessions to complete)
- **US5 (Phase 7)**: Depends on US3 (needs sessions/chats for status) and US1 (needs errands to look up)
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

- **US1 (P1) 🎯 MVP**: No story dependencies — standalone MVP increment
- **US2 (P1)**: No story dependencies — standalone; can be built in parallel with US1
- **US3 (P2)**: Depends on US1 + US2 (needs errands and verified riders)
- **US4 (P2)**: Depends on US3 (needs active sessions to mark done)
- **US5 (P3)**: Depends on US1 + US3 (needs errands and sessions/chats)

### Within Each User Story

- Models before services
- Services before providers
- Providers before screens
- Core implementation before navigation wiring
- Story complete before moving to next priority

### Parallel Opportunities

- US1 (Phase 3) and US2 (Phase 4) can be implemented in parallel by different developers
- Setup tasks T001/T002 can run in parallel
- Foundational tasks T006/T007 can run in parallel
- All [P]-marked tasks within a phase can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch all models/widgets for User Story 1 together:
Task: "Create PasugoScreen"
Task: "Create CreateErrandScreen"
Task: "Create MapPinPicker widget"
Task: "Create ErrandCard widget"

# Then wire them with services and providers:
Task: "Implement ErrandService"
Task: "Implement ErrandProvider"
Task: "Connect screens with navigation"
```

## Parallel Example: Foundational Phase

```bash
# Launch all model tasks together:
Task: "Create Errand model"
Task: "Create Rider model"
Task: "Create PasugoSession model"
Task: "Create ChatMessage model"

# Launch infrastructure tasks in parallel:
Task: "Configure Firestore indexes"
Task: "Add Firestore security rules"
Task: "Register providers in main.dart"
Task: "Add routes in main.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1 (Customer posts errand on bulletin board)
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo — customers can post and view errands

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add US1 (Post errand) → Test independently → **MVP Deploy** 🎯
3. Add US2 (Rider registration + admin verify) → Test independently → Deploy
4. Add US3 (Rider accept + chat) → Test independently → **Core Pasugo complete!**
5. Add US4 (Complete session) → Test independently
6. Add US5 (Customer status view) → Test independently
7. Polish phase for all cross-cutting concerns

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. **Sprint 1** (parallel):
   - Developer A: US1 (Customer posts errand)
   - Developer B: US2 (Rider registration + admin verification)
3. **Sprint 2**: US3 (Rider accept + chat — needs US1 + US2)
4. **Sprint 3**: US4 (Complete session)
5. **Sprint 3/4**: US5 (Customer status view)
6. **Final**: Polish & Cross-cutting concerns

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- Total tasks: 56 across 8 phases
