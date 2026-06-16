# Implementation Plan: Menu Pricing and Section Updates

**Branch**: `002-update-menu-prices-sections` | **Date**: 2026-04-19 | **Spec**: [spec.md](file:///c:/APPLICATIONS/luna_express/specs/002-update-menu-prices-sections/spec.md)
**Input**: Feature specification from `/specs/002-update-menu-prices-sections/spec.md`

## Summary

This plan covers the removal of redundant menu sections, price updates for Shawarma items, normalization of promotional labels ("B1T1" → "Buy 1 Take 1"), and the addition of the "Oreo Craze" specialty drink section under Extras. The approach involves direct modification of the `kMenuSections` static list and UI text widgets in `main.dart`.

## Technical Context

**Language/Version**: Dart 3.x (Flutter 3.x)  
**Primary Dependencies**: Flutter, Firebase (Auth/Firestore)  
**Storage**: Static memory list `kMenuSections` (UI source)  
**Testing**: Flutter Integration Tests (Manual verification via Chrome)  
**Target Platform**: Web (Chrome)
**Project Type**: Flutter Web Application  
**Performance Goals**: N/A (UI-only change)  
**Constraints**: Ensure the consolidated "Burger & Hotdog Sandwich" remains untouched while deleting separate categories.  
**Scale/Scope**: ~10 files, localized to `lib/main.dart`.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Principle I (User-Centric)**: Improves clarity by removing redundancy and clarifying labels.
- [x] **Principle V (Spec Kit)**: Follows structured planning and specification.

## Project Structure

### Documentation (this feature)

```text
specs/002-update-menu-prices-sections/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (generated later)
```

### Source Code (repository root)

```text
lib/
├── main.dart            # Contains menu data and UI logic
└── firebase_options.dart # Firebase configuration
```

**Structure Decision**: The application follows a monolithic `main.dart` structure for its current size, which contains both the data model (`kMenuSections`) and the UI components. Changes will be focused on the `kMenuSections` list and the product card widgets.

## Phase 0: Research

[See research.md for details on string occurrences and item mapping]

## Phase 1: Design & Development

[See data-model.md for the new Oreo Craze item schema]
