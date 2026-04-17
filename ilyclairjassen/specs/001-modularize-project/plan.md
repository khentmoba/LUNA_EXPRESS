# Implementation Plan: Modularization (Project Optimization)

**Branch**: `001-modularize-project` | **Date**: 2026-04-17 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-modularize-project/spec.md`

## Summary

Transition the project from a monolithic `index.html` to a modern, modular architecture using the Vite bundler and a feature-based structure (Vertical Slicing). This improves developer productivity, allows for scalable growth, and enhances runtime performance by optimizing asset loading.

## Technical Context

**Language/Version**: JavaScript (ES2022+ / ES Modules)
**Primary Dependencies**: Vite 5.x (Vanilla preset)
**Storage**: N/A (Project uses Supabase for global and LocalStorage for local state)
**Testing**: Vitest (to be considered)
**Target Platform**: Modern Browsers, Netlify
**Project Type**: Web Application
**Performance Goals**: < 1s Load Time, Sub-second HMR
**Constraints**: 
- MUST maintain functional parity with the original Eternal Sanctuary.
- MUST refactor variables and logic for modern readability (FR-006).
- MUST use environment variables for keys (FR-007).
**Scale/Scope**: ~1MB monolithic file split into 10+ modules and 3+ external assets.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Principle I (Access)**: Auth logic remains session-based.
- [x] **Principle II (Modular Architecture)**: Plan aligns with the newly amended principle of using a modular build system.
- [x] **Principle III (Persistence)**: LocalStorage/Supabase mix is maintained.
- [x] **Principle IV (Aesthetics)**: Visual fidelity is preserved.
- [x] **Principle V (Reliability)**: Vite improves code reliability via build-time checks.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
src/
├── features/           # Vertical Slicing
│   ├── auth/           # Login gate logic & styles
│   ├── garden/         # Canvas garden logic & styles
│   ├── diary/          # Supabase diary integration
│   └── weather/        # Dynamic weather system
├── shared/             # Common utilities & global styles
│   ├── api/            # Supabase client config
│   └── utils/          # Formatting, time helpers
├── main.js             # App entry point
└── index.html          # HTML structure
public/
└── assets/             # Externalized images (from base64)
```

**Structure Decision**: Vertical Slicing within the `src/features` directory. This allows each feature to own its technical implementation (JS and CSS) while sharing common infrastructure.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
