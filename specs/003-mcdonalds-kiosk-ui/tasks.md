# Tasks: McDonalds-Style Kiosk UI

**Input**: Design documents from `/specs/003-mcdonalds-kiosk-ui/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create project structure for Kiosk widgets in lib/widgets/kiosk/
- [ ] T002 Add google_fonts dependency or manual 'Inter' font assets in pubspec.yaml

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure and state management

- [ ] T003 Implement KioskTheme color and style configuration in lib/widgets/kiosk/kiosk_theme.dart
- [ ] T004 Define KioskSession state (DiningMode, activeCategory) in lib/main.dart

**Checkpoint**: Foundation ready - UI components can now be built using the theme and session state.

---

## Phase 3: User Story 1 - Self-Service Ordering Experience (Priority: P1) 🎯 MVP

**Goal**: Implement the core ordering flow from a fresh splash screen to a visual menu and cart.

**Independent Test**: Start app -> Splash -> Select "Eat In" -> Select "Burgers" -> Add item -> View visual cart summary.

### Implementation for User Story 1

- [ ] T005 [P] [US1] Create KioskSplashScreen widget with "Tap to Start" button in lib/screens/splash_screen.dart
- [ ] T006 [P] [US1] Implement DiningModeSelection (Eat In / Take Out) icons in lib/screens/splash_screen.dart
- [ ] T007 [P] [US1] Implement KioskSidebar with category markers in lib/widgets/kiosk/sidebar.dart
- [ ] T008 [P] [US1] Implement KioskProductCard for high-impact grid display in lib/widgets/kiosk/product_card.dart
- [ ] T009 [US1] Refactor MenuPage to use 2-column Sidebar+Grid layout in lib/main.dart
- [ ] T010 [US1] Create KioskCustomizationModal for item details and confirmation in lib/widgets/kiosk/customization_modal.dart
- [ ] T011 [US1] Implement VisualOrderSummary grid for the cart view in lib/widgets/kiosk/cart_summary.dart

**Checkpoint**: User Story 1 is fully functional: customers can start an order and navigate a visual menu.

---

## Phase 4: User Story 2 - Smooth Aesthetic Transitions (Priority: P2)

**Goal**: Enhance the premium feel through fluid animations and transitions.

**Independent Test**: Navigate menu categories and open products; observers should see seamless fades and Hero transitions.

### Implementation for User Story 2

- [ ] T012 [P] [US2] Implement Hero animations for product image transitions in lib/widgets/kiosk/product_card.dart
- [ ] T013 [P] [US2] Add AnimatedSwitcher for category cross-fades in lib/main.dart
- [ ] T014 [US2] Implement custom page transitions (Slide/Fade) for Splash to Menu in lib/main.dart
- [ ] T015 [US2] Add micro-animations (scale/bounce) for button and card interactions in lib/widgets/kiosk/

**Checkpoint**: The experience feels "smooth and alive" as per user requirements.

---

## Phase 5: User Story 3 - Brand-Aligned Visual Identity (Priority: P3)

**Goal**: Finalize the "Yellowish" aesthetic and premium styling.

**Independent Test**: Verify all primary UI elements use #FFBC0D and the 'Inter' typeface.

### Implementation for User Story 3

- [ ] T016 [P] [US3] Global theme update for all primary/action colors to Confirmed #FFBC0D in lib/main.dart
- [ ] T017 [P] [US3] Update typography across all Kiosk widgets to used 'Inter' family in lib/main.dart
- [ ] T018 [US3] Apply final Glassmorphism/Card styles to product cards and modal in lib/widgets/kiosk/

**Checkpoint**: The application matches the "website logo" color and premium aesthetic.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T019 Final touch target audit ensuring all buttons meet min 56x56 targets in lib/
- [ ] T020 Run responsive check for both PC (Landscape) and Mobile (Portrait) to ensure layout stability in lib/
- [ ] T021 Clean up unused old LandingPage and MenuPage styles in lib/main.dart

---

## Dependencies & Execution Order

### Phase Dependencies
- **Setup & Foundational**: Must complete before starting User Story implementations.
- **US1 (MVP)**: The core functional flow.
- **US2 & US3**: Can be worked on in parallel once US1 components exist.

### Parallel Opportunities
- T005-T008 (US1 Components) can be built in parallel.
- T012-T013 (Animations) can be developed alongside UI components.
- T016-T017 (Styling) can be applied to existing widgets in parallel.

---

## Implementation Strategy

### MVP First (User Story 1 Only)
1. Complete Setup and Foundational.
2. Build the Splash and Menu Grid (US1).
3. Verify the basic ordering flow without advanced animations.

### Incremental Delivery
1. Foundation -> Core UI -> Transitions -> Final Branding.
2. Each phase adds a layer of "Aesthetic" and "Smoothness" to the functional MVP.
