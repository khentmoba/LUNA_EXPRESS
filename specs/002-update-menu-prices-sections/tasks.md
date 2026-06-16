# Tasks: Menu Pricing and Section Updates

**Input**: Design documents from `/specs/002-update-menu-prices-sections/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Tests**: Tests are not explicitly requested; verification will be performed manually per `quickstart.md`.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Verify local development server is running via `flutter run -d chrome`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [x] T002 Identify line numbers for all `MenuItem` and `MenuSection` definitions in `lib/main.dart`

---

## Phase 3: User Story 1 - Updated Shawarma Pricing (Priority: P1)

**Goal**: Update prices for Shawarma Wrap (60) and Shawarma Quesadilla (75).

**Independent Test**: View the Shawarma section in the menu and verify prices.

### Implementation for User Story 1

- [x] T003 [US1] Update Shawarma Wrap (id: 's1') price to 60 in `lib/main.dart`
- [x] T004 [US1] Update Shawarma Quesadilla (id: 's7') price to 75 in `lib/main.dart`

---

## Phase 4: User Story 2 - Menu Category Cleanup (Priority: P1)

**Goal**: Remove redundant "Burgers" and "Hotdog Bun" categories.

**Independent Test**: Verify both categories are absent from the menu scroll.

### Implementation for User Story 2

- [x] T005 [US2] Remove "Burgers" (`id: 'burgers'`) category definition in `lib/main.dart`
- [x] T006 [US2] Remove "Hotdog Bun" (`id: 'hotdog'`) category definition in `lib/main.dart`

---

## Phase 5: User Story 3 - Clarity Improvement (B1T1) (Priority: P2)

**Goal**: Normalize "B1T1" and "Buy1 Take1" to "Buy 1 Take 1".

**Independent Test**: Search for old strings in the UI and verify all say "Buy 1 Take 1".

### Implementation for User Story 3

- [x] T007 [P] [US3] Replace "Buy1 Take1" with "Buy 1 Take 1" in `kMenuSections` labels in `lib/main.dart`
- [x] T008 [P] [US3] Replace "B1T1" with "Buy 1 Take 1" in `_ProductCard` widget in `lib/main.dart` (Line 874)
- [x] T009 [P] [US3] Replace "B1T1" with "Buy 1 Take 1" in `_VariantRow` widget in `lib/main.dart` (Line 954)

---

## Phase 6: User Story 4 - New Product Offering (Oreo Craze) (Priority: P1)

**Goal**: Add 4 Oreo specialty drinks at ₱65 to Extras.

**Independent Test**: Verify "Oreo Craze" items appear in Extras at ₱65.

### Implementation for User Story 4

- [x] T010 [US4] Create a single "Oreo Craze" `MenuItem` in the `extras` category in `lib/main.dart`
- [x] T011 [US4] Implement flavors (Cookies & Cream, Chocolate, Strawberry, Milo) as `MenuVariant` options for the Oreo Craze item
- [x] T012 [US4] Set global price of 65 and ensure "(Large)" is included in the variant labels or description

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final verification and consistency checks

- [x] T012 Run `quickstart.md` validation steps
- [x] T013 [P] Verify no lint errors in modified sections of `lib/main.dart`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup.
- **User Stories (Phase 3+)**: All depend on Phase 2 completion.
  - US2 (Cleanup) should be done before US4 (Addition) to ensure a clean slate.
  - US1 and US3 can proceed independently.

### Parallel Opportunities

- US1 and US3 implementation tasks can run in parallel.
- US3 normalization tasks (T007-T009) can run in parallel since they touch different parts of the code.

---

## Implementation Strategy

### MVP First (Priorities P1)

1. Complete Setup (P1)
2. Complete Foundational (P1)
3. Complete US1 (P1 - Pricing)
4. Complete US2 (P1 - Cleanup)
5. Complete US4 (P1 - Addition)
6. **PROCEED TO US3** (P2 - Normalization) only after P1 tasks are finished.
