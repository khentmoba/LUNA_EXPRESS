# Implementation Plan: Pasugo (Errand) System

**Branch**: `008-pasugo-system` | **Date**: 2026-07-06 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/008-pasugo-system/spec.md`

## Summary

Add a Pasugo (Errand) subsystem to the Luna Express app where customers can post errand requests on a bulletin board, verified riders can accept and fulfill them, and both parties communicate via a temporary chat. The system includes rider registration with admin verification, phone/PIN-based customer session access, optional map pin drop for locations, and read-only chat archives on completion.

## Technical Context

**Language/Version**: Dart 3.x (Flutter SDK ^3.11.3)  
**Primary Dependencies**: Firebase (Auth, Firestore, Cloud Messaging), Provider (state management), flutter_map + latlong2 + geolocator (map pins)  
**Storage**: Firestore (errands, riders, sessions, chat messages, archives)  
**Testing**: flutter_test (unit/widget), integration_test (flow tests), Firebase Emulator Suite for backend-dependent tests  
**Target Platform**: Mobile (Android/iOS) + Web — Pasugo flows optimized for mobile  
**Project Type**: Mobile/web application (Flutter + Firebase)  
**Performance Goals**: Chat messages delivered within 5 seconds; errand creation under 30 seconds; 100 concurrent pasugo sessions  
**Constraints**: Real-time chat via Firestore snapshots; offline tolerance for message sending; atomic errand acceptance to prevent double-claim  
**Scale/Scope**: New subsystem within existing Luna Express app; v1 excludes live GPS tracking, full customer accounts, and in-app payment processing

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Notes |
|-----------|-------|-------|
| **I. User-Centric Ordering** | ✅ PASS | Pasugo flow is mobile-optimized, minimises friction with PIN-based access, and keeps the ordering and errand flows clearly separated from the landing screen. |
| **II. Payment-First Fulfillment** | ✅ N/A (Pasugo) | Pasugo explicitly does NOT process payments (payment arranged via chat). This is a deliberate exclusion documented in the spec — the Pasugo subsystem is a connection facilitator, not a payment-fulfillment pipeline. |
| **III. Fulfillment Flexibility** | ✅ PASS | The system supports the rider accepting an errand and both parties coordinating delivery or pickup through chat. The optional map pin provides location context. |
| **IV. Data Integrity & Security** | ✅ PASS | Phone numbers are hidden on the bulletin board until acceptance; PIN-based access protects session continuity; chat archives are read-only; rider verification gates access to the system. |
| **V. Spec Kit Compliance** | ✅ PASS | Feature follows the full Spec Kit workflow: spec → clarify → plan → tasks → implement. |

**Gate Verdict: PASS** — No violations. The payment exclusion (Principle II) is a documented design decision, not a violation, as Pasugo is explicitly scoped as a non-payment feature.

## Project Structure

### Documentation (this feature)

```text
specs/008-pasugo-system/
├── plan.md              # This file (/speckit.plan command output)
├── spec.md              # Feature specification
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── checklists/          # Quality checklists
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── features/                     # Feature modules
│   └── pasugo/                   # Pasugo subsystem
│       ├── models/               # Data classes for Errand, Rider, Session, ChatMessage
│       ├── screens/              # UI screens (Pasugo landing, bulletin board, chat, rider registration)
│       ├── widgets/              # Reusable widgets (errand card, chat bubble, map pin picker)
│       ├── services/             # Firebase data access, chat real-time service
│       └── providers/            # State management (Provider) for pasugo flows
├── shared/                       # Shared utilities (if needed)
│   └── widgets/                  # Shared widgets reused by pasugo
└── main.dart                     # App entry point (updated to add Pasugo route)

test/
├── features/
│   └── pasugo/                   # Pasugo-specific tests
│       ├── models/               # Unit tests for data models
│       ├── screens/              # Widget tests for screens
│       └── services/             # Service tests (with Firebase Emulator)
└── integration/                  # Integration tests for full pasugo flow
```

**Structure Decision**: Feature-first modular structure within the existing Flutter app. The pasugo subsystem gets its own feature directory under `lib/features/` to keep it isolated from the existing ordering code. This follows the existing app architecture pattern.

## Complexity Tracking

> **No violations to justify** — Constitution Check passed cleanly. Skip.
