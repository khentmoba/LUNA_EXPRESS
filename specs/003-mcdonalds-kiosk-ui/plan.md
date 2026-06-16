# Implementation Plan: McDonalds-Style Kiosk UI

**Branch**: `003-mcdonalds-kiosk-ui` | **Date**: 2026-04-19 | **Spec**: [spec.md](file:///c:/APPLICATIONS/luna_express/specs/003-mcdonalds-kiosk-ui/spec.md)
**Input**: Feature specification from `/specs/003-mcdonalds-kiosk-ui/spec.md`

## Summary

This plan outlines the transformation of the Luna Express ordering UI into a premium, self-service kiosk interface inspired by McDonald's terminals. The technical approach involves a complete aesthetic overhaul using a vibrant yellow theme (#FFBC0D), a new "Tap to Start" splash sequence, and a redesigned menu page featuring a vertical sidebar and highly interactive product cards with smooth transitions.

## Technical Context

**Language/Version**: Dart (Flutter SDK ^3.11.3)
**Primary Dependencies**: Flutter, Firebase (Auth, Firestore, Storage), latlong2, geolocator
**Storage**: Cloud Firestore
**Testing**: Flutter Test
**Target Platform**: Web (Primary), Mobile (Native)
**Project Type**: Food Ordering Kiosk Application
**Performance Goals**: UI transitions < 400ms, Touch target size min 56x56 logical pixels
**Constraints**: MUST use #FFBC0D Primary color; MUST align with 'Luna Express' branding
**Scale/Scope**: ~10 categories, ~50 products, Kiosk mode deployment

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. User-Centric Ordering**: ✅ The Kiosk UI optimizes for speed and visual clarity.
- **II. Payment-First Fulfillment**: ✅ Existing order workflows are preserved.
- **III. Fulfillment Flexibility**: ✅ Added "Eat In / Take Out" mode selection.
- **IV. Data Integrity & Security**: ✅ No changes to backend security models.
- **V. Spec Kit Compliance**: ✅ Following the `speckit-plan` workflow.

## Project Structure

### Documentation (this feature)

```text
specs/003-mcdonalds-kiosk-ui/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Visual and component research findings
├── data-model.md        # UI state models and transitions
├── quickstart.md        # Feature testing guide
├── contracts/           # UI Component interface definitions
└── checklists/          # Quality validation lists
```

### Source Code (repository root)

```text
lib/
├── main.dart            # Entry point & Theme updates
├── models/              # (Existing) Data models
├── widgets/
│   ├── kiosk/           # [NEW] Kiosk-specific UI components
│   │   ├── sidebar.dart
│   │   ├── product_card.dart
│   │   └── summary_bar.dart
│   └── shared/          # Generic reusable widgets
├── screens/
│   ├── splash_screen.dart   # [NEW] Tap to Start sequence
│   └── menu_page.dart       # [MODIFY] Refactored Kiosk Menu
└── services/            # (Existing) Firebase/Telegram Logic
```

**Structure Decision**: Single project layout with a dedicated `kiosk/` directory under `widgets/` to isolate the new UI system while reusing existing data models and services.

## Complexity Tracking

*No constitution check violations.*
