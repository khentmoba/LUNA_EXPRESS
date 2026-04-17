# Feature Specification: Modularization (Project Optimization)

**Feature Branch**: `001-modularize-project`  
**Created**: 2026-04-17  
**Status**: Draft  
**Input**: User description: "optimize this file first, like have multiple files rather than one single file to make it more effecient... use a bundler... Feature-based (Vertical Slicing)."

## Clarifications

### Session 2026-04-17
- Q: Should code migration involve refactoring or strict copy-paste? → A: **Refactor**: Modernize syntax and rename variables for clarity to support long-term efficiency.
- Q: How should styles and deployment be handled? → A: Use **Scoped CSS** per feature and **Automated Netlify Builds** from source.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Maintain Functional Parity (Priority: P1)

As a user, I should be able to access the exact same "Eternal Sanctuary" experience (visuals, auth, garden, diary) after the modularization as I did before.

**Why this priority**: Modularity is an internal improvement; the user's current experience must not be degraded or broken during the transition.

**Independent Test**: The application can be built and run. Navigating through the portal, interacting with the garden, and checking the diary works exactly as in the monolithic `index.html`.

**Acceptance Scenarios**:

1. **Given** the monolithic `index.html`, **When** the code is split into modules, **Then** all base64-encoded photos must still render correctly.
2. **Given** the new modular structure, **When** I enter a birthday into the portal, **Then** I must be granted access if the credentials match Khent or Clair Jassen.

---

### User Story 2 - Vite Bundling (Priority: P2)

As a developer, I want to use Vite to manage my separate CSS and JS files so that I can have faster development cycles (Hot Module Replacement) and optimized production results.

**Why this priority**: Vite provides the "bundler" capability requested by the user and handles the complexity of modular loading automatically.

**Independent Test**: Running `npm run dev` starts a local server with HMR. Running `npm run build` generates a production folder that can be deployed to Netlify.

**Acceptance Scenarios**:

1. **Given** a multi-file setup, **When** I run the dev server, **Then** changes to a CSS file should instantly reflect in the browser without a full refresh.
2. **Given** a multi-file setup, **When** I run the build command, **Then** all JS and CSS should be combined/minified into an optimized production output.

---

### User Story 3 - Feature-Based Organization (Priority: P3)

As a developer, I want my code organized by features (e.g., Garden, Auth, Diary) rather than just file types (e.g., all JS in one folder) so that I can easily find and modify specific parts of the "Eternal Sanctuary."

**Why this priority**: Follows the user's specific request for "Vertical Slicing" to support future complexity.

**Independent Test**: Browsing the `src` directory reveals top-level folders for each major feature, each containing its own relevant logic and styles.

**Acceptance Scenarios**:

1. **Given** the new `src/` directory, **When** I look into `src/features/garden`, **Then** I should find all JavaScript logic and CSS specifically related to the canvas-based flower system.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST be initialized as a **Vite** project (vanilla template).
- **FR-002**: All CSS MUST be extracted into separate `.css` files.
- **FR-003**: All JavaScript MUST be extracted into ES Modules.
- **FR-004**: Base64 images MUST be moved to external files in the `public/assets` or `src/assets` directory.
- **FR-005**: Infrastructure MUST support "Vertical Slicing" (Feature-based grouping).
- **FR-006**: Code migration MUST involve refactoring for clarity (modern ES6+ syntax, descriptive variable naming).
- **FR-007**: System MUST use `.env` files for managing sensitive configuration (Supabase keys).
- **FR-008**: Deployment MUST be configured for automated builds from source (Git-linked CI/CD).

### Key Entities *(include if feature involves data)*

- **Feature Modules**: Independent units of functionality (Auth, Garden, Diary, Weather) containing their own styles and logic.
- **App Entry Point**: The core `index.html` and `main.js` that bootstrap the feature modules.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Initial "cold" reload of the dev environment is under 2 seconds.
- **SC-002**: Production build deployment on Netlify is successful and functional.
- **SC-003**: Zero global namespace pollution (everything is scoped to modules).

## Assumptions

- We will utilize the **Vite Vanilla** preset to keep the "Vanilla JS/CSS" spirit while gaining the benefits of a bundler.
- The `index.html` file will remain the primary entry point for the browser.
- External dependencies (Supabase, Google Fonts) will remain handled via CDN/Direct Links as per current implementation, or imported via npm if the user prefers (current assumption is continuing with existing pattern).
