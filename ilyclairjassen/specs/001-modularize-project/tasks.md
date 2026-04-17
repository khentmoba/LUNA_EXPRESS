# Tasks: Modularization (Project Optimization)

**Input**: Design documents from `/specs/001-modularize-project/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Initialize `package.json` with Vite and basic meta dependencies
- [ ] T002 Configure `vite.config.js` for vanilla JS and single-page behavior
- [ ] T003 [P] Create directory structure: `src/features`, `src/shared`, `public/assets`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [ ] T004 Create shared Supabase client in `src/shared/api/supabase.js` using `import.meta.env`
- [ ] T005 [P] Implement common styling tokens in `src/shared/styles/tokens.css`
- [ ] T006 [P] Create global date-time helpers in `src/shared/utils/time.js`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Maintain Functional Parity & Refactor (Priority: P1) 🎯 MVP

**Goal**: Split the monolith into vertical slices while modernizing the codebase for long-term efficiency.

**Independent Test**: The app loads correctly via `npm run dev` and all features (portal, flower growth, diary history) match the original `index.html` behavior, but with cleaner console output and modernized code.

### Implementation for User Story 1

- [ ] T007 [P] [US1] Extract base64 images from `index.html` to `public/assets/*.jpg`
- [ ] T008 [P] [US1] Implement Auth gate in `src/features/auth/` (Refactor to ES6+, rename variables)
- [ ] T009 [P] [US1] Implement Garden canvas in `src/features/garden/` (Refactor to ES6+, modernize logic)
- [ ] T010 [P] [US1] Implement Diary bridge in `src/features/diary/` (Refactor Supabase fetches)
- [ ] T011 [P] [US1] Implement Weather engine in `src/features/weather/` (Refactor cycle logic)
- [ ] T012 [US1] Bootstrap app entry point in `src/main.js` and link all feature modules
- [ ] T013 [US1] Refactor root `index.html` to be a clean entry point fetching `src/main.js`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Vite Bundling & Security (Priority: P2)

**Goal**: Optimize the build and secure the configuration.

**Independent Test**: Running `npm run build` produces a functional `dist/` folder with minified assets.

### Implementation for User Story 2

- [ ] T014 [US2] Create `.env.example` and verify `.env` loading for Supabase keys
- [ ] T015 [US2] Add Netlify configuration file `netlify.toml` for automated CI/CD builds

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Final refinements

- [ ] T016 Final pass on CSS consistency across Vertical Slices
- [ ] T017 Run quickstart validation to ensure local setup is seamless
- [ ] T018 [P] Update Project Constitution walkthrough to reflect the new structure

---

## Dependencies & Execution Order

### Phase Dependencies
- **Phase 1 (Setup)**: No dependencies.
- **Phase 2 (Foundational)**: Depends on Phase 1 completion.
- **Phase 3 (User Stories)**: Depends on Phase 2 completion.
- **Phase 4 (Bundling)**: Can run in parallel with US1 integration.

### Parallel Opportunities
- Asset extraction (T007) can start immediately after directory creation.
- Feature migrations (T008-T011) can run in parallel once the Foundation is ready.
