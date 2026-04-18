# Tasks: Burger & Hotdog Category

**Input**: Design documents from `/specs/001-burger-hotdog-category/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Tests**: Test tasks are included as verification steps after each user story implementation.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Initialize feature documentation in `specs/001-burger-hotdog-category/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [x] T002 Verify current `kMenuSections` location in `lib/main.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Add Burger/Hotdog Deal to Cart (Priority: P1) 🎯 MVP

**Goal**: Customers can add the new burger and hotdog deals to their cart from the menu.

**Independent Test**: Navigate to "Burger & Hotdog Sandwich" tab, add "Cheese Burger" to cart, and verify subtotal is ₱65.

### Implementation for User Story 1

- [x] T003 [US1] Create the new `MenuSection` object in `lib/main.dart` for "Burger & Hotdog Sandwich"
- [x] T004 [US1] Define all 6 variants in the new `MenuSection` with correct prices and `isBuy1Take1: true` in `lib/main.dart`
- [x] T005 [US1] Append the new section to the `kMenuSections` list in `lib/main.dart`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently.

---

## Phase 4: User Story 2 - Staff Mode Access (Priority: P2)

**Goal**: Staff members can process walk-in orders for the new items using the staff dashboard.

**Independent Test**: Login as staff, select "Hotdog Sandwich" deal, and verify the receipt generation flow works.

### Implementation for User Story 2

- [x] T006 [US2] Verify the new category is visible and functional in Staff Mode UI in `lib/main.dart`
- [x] T007 [US2] Test the end-to-end order flow for a walk-in customer using the new items

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T008 [P] Verify item description and pricing accuracy across all platforms (PWA/Web) in `lib/main.dart`
- [x] T009 Run `quickstart.md` validation checklist

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Completed.
- **Foundational (Phase 2)**: Completed.
- **User Stories (Phase 3+)**: Sequential implementation (US1 → US2).
- **Polish (Final Phase)**: Depends on all user stories being complete.

### Parallel Opportunities

- T008 and T009 can be performed simultaneously.
- Implementation of US1 and US2 is sequential as they both modify the same monolithic file (`lib/main.dart`).

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 3: User Story 1
2. **STOP and VALIDATE**: Test User Story 1 independently
3. Demo if ready

### Incremental Delivery

1. Add User Story 1 → Test independently (MVP!)
2. Add User Story 2 → Test independently
