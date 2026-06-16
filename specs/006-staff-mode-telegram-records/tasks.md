# Tasks: Staff Mode and Telegram Order Records

**Input**: Design documents from `specs/006-staff-mode-telegram-records/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel
- **[Story]**: US1, US2, US3, US4 (from spec.md)

## Phase 1: Setup (Shared Infrastructure)

- [ ] T001 Initialize Firebase Functions in root (typescript)
- [ ] T002 Install `node-telegram-bot-api` in `functions/`
- [ ] T003 [P] Configure Firebase secrets for `TELEGRAM_TOKEN` and `TELEGRAM_CHAT_ID`
- [ ] T004 Define `Order` model in `lib/models/order.dart` based on data-model.md

## Phase 2: Foundational (Blocking Prerequisites)

- [ ] T005 Implement `OrderService` in `lib/services/order_service.dart` for Firestore writes
- [ ] T006 [P] Update `Session` class in `lib/main.dart` to support staff login without credentials (gesture-based)
- [ ] T007 [P] Create `functions/src/telegram_api.ts` for unified bot messaging logic

## Phase 3: User Story 1 - Hidden Access (Priority: P1) 🎯 MVP

**Goal**: Staff can enter Staff Mode via a hidden gesture.

**Independent Test**: Triple-tap the bottom-right corner of the splash screen and verify the "Staff Mode Active" snackbar and indicator appear.

- [ ] T008 [US1] Implement triple-tap detector in `lib/screens/splash_screen.dart`
- [ ] T009 [US1] Add subtle "Staff Mode" indicator to `KioskMenuPage` header in `lib/main.dart`
- [ ] T010 [US1] Implement "Logout" functionality for Staff Mode in `lib/main.dart`

## Phase 4: User Story 2 - Streamlined Checkout (Priority: P1) 🎯 MVP

**Goal**: Staff checkouts are fast, default to Cash, and tagged for reporting.

**Independent Test**: Complete an order in Staff Mode and verify it goes directly to the receipt, bypassing location/payment selection.

- [ ] T011 [US2] Update `CheckoutFlowBridge` in `lib/main.dart` to bypass customer steps if `session.isStaff`
- [ ] T012 [US2] Modify `KioskCartPage` in `lib/screens/cart_page.dart` to use `OrderService` for persistence
- [ ] T013 [US2] Update `ReceiptPage` in `lib/main.dart` to display "Staff/Walk-in" label
- [ ] T014 [US2] Ensure all kiosk (customer) orders are also persisted via `OrderService` for uniformity

## Phase 5: User Story 3 - Daily Telegram Records (Priority: P2)

**Goal**: Automated daily sales summary at 10:00 PM PHT.

**Independent Test**: Trigger the scheduled function in the Firebase Emulator and verify the formatted report is sent to the Telegram group.

- [ ] T015 [US3] Implement `functions/src/reporting/aggregator.ts` to sum today's orders (PHT)
- [ ] T016 [US3] Implement `functions/src/reporting/daily_report.ts` as a scheduled v2 function (22:00 PHT)
- [ ] T017 [US3] Format the Telegram message according to the contract in `report-contract.md`

## Phase 6: User Story 4 - Manual Report & Management (Priority: P2)

**Goal**: Staff can trigger reports on-demand and manage mode.

**Independent Test**: Click "Generate Today's Report" in the Staff Mode hidden menu and verify instant Telegram delivery.

- [ ] T018 [US4] Implement HTTPS Callable `triggerManualReport` in `functions/src/reporting/manual_report.ts`
- [ ] T019 [US4] Create `lib/screens/staff_menu.dart` hidden bottom sheet for on-demand actions
- [ ] T020 [US4] Add "Generate Report" button to `StaffMenu` sheet

## Phase 7: Polish & Validation

- [ ] T021 [P] Configure Firestore Security Rules in `firestore.rules` for the new `orders` collection
- [ ] T022 [P] Clean up logic in `lib/main.dart` to remove redundant legacy staff login code if possible
- [ ] T023 Run full `quickstart.md` validation flow

## Dependencies & Execution Order

1. **Setup (Phase 1)** must be done first.
2. **Foundational (Phase 2)** blocks US1 and US2.
3. **US1 & US2** are P1/MVP and should be completed before US3.
4. **US3 & US4** can be done in parallel once `OrderService` and Firestore are active.
