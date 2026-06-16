---
description: "Task list for Juicy Micro-Interactions implementation"
---

# Tasks: Juicy Micro-Interactions

**Input**: Design documents from `/specs/005-juicy-micro-interactions/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)
- Include exact file paths in descriptions

## Path Conventions

- Paths assume the single Flutter project structure in the repository root.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Define global interaction constants (kJuicyScale, kJuicyDuration) in lib/widgets/kiosk/kiosk_theme.dart

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [x] T002 Implement the JuicyFeedback widget wrapper in lib/widgets/kiosk/juicy_feedback.dart
- [x] T003 [P] Add haptic feedback logic to JuicyFeedback using HapticFeedback.lightImpact()

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Tactile Button Feedback (Priority: P1) 🎯 MVP

**Goal**: Provide tactile and visual feedback for primary call-to-action buttons.

**Independent Test**: Tapping "TAP TO START" or "ADD TO ORDER" triggers a scale pop and a vibration.

### Implementation for User Story 1

- [x] T004 [US1] Wrap the "TAP TO START" interaction in lib/screens/splash_screen.dart
- [x] T005 [US1] Wrap the primary "ADD TO ORDER" button in lib/widgets/kiosk/customization_modal.dart
- [x] T006 [P] [US1] Wrap category selection cards in lib/widgets/kiosk/product_card.dart
- [x] T007 [US1] Verify that "On Press" (PointerDown) triggers immediate feedback

**Checkpoint**: User Story 1 is fully functional and testable independently.

---

## Phase 4: User Story 2 - Interaction Consistency (Priority: P2)

**Goal**: Extend juicy feel to all secondary interactive elements for a cohesive experience.

**Independent Test**: Tapping quantity adjusters or cart removal icons triggers the same feedback.

### Implementation for User Story 2

- [x] T008 [US2] Wrap quantity increment/decrement buttons in lib/widgets/kiosk/customization_modal.dart
- [x] T009 [P] [US2] Wrap "Remove" and "Update" icons in lib/screens/cart_page.dart
- [x] T010 [US2] Ensure variant selection items in the modal have the juicy effect in lib/widgets/kiosk/customization_modal.dart
- [x] T011 [P] [US2] Wrap the "Checkout" button in lib/screens/cart_page.dart

**Checkpoint**: All user stories are now independently functional and consistent.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T012 [P] Implement debouncing or animation interruption to handle fast successive taps in lib/widgets/kiosk/juicy_feedback.dart
- [x] T013 Verify animation performance (60fps) on the target platform
- [x] T014 Run quickstart.md validation to ensure developer instructions are accurate

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately.
- **Foundational (Phase 2)**: Depends on T001 - BLOCKS all user stories.
- **User Stories (Phase 3+)**: All depend on Foundational phase completion.
- **Polish (Final Phase)**: Depends on all user stories being complete.

### Parallel Opportunities

- T003 can be done in parallel with T002 (logic vs structure).
- Once Phase 2 is done:
    - US1 and US2 can theoretically proceed in parallel if targeting different files.
- T006 [US1] can be done in parallel with T005 [US1].
- T009 [US2] and T010 [US2] can run in parallel.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 & 2 (Foundation).
2. Complete Phase 3 (Primary buttons).
3. **STOP and VALIDATE**: Test "ADD TO ORDER" and Splash screen.

### Incremental Delivery

1. Deploy MVP (Splash + Add to Order) to ensure hardware haptics work.
2. Incrementally add US2 (Cart, Variants, Quantities).
3. Final polish for debouncing.
