# Implementation Plan: Staff Mode and Telegram Order Records

**Branch**: `006-staff-mode-telegram-records` | **Date**: 2026-04-19 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/006-staff-mode-telegram-records/spec.md`


**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Implement a "Staff Mode" accessible via a hidden triple-tap gesture on the landing page. This mode streamlines the checkout process for staff-assisted orders by defaulting to "Cash" and bypassing customer-facing steps. Additionally, integrate a Telegram bot to send detailed daily sales summaries (Total Revenue, Order Count, Top Items) at 10:00 PM PHT, including an on-demand report button in the Staff Mode UI.


**Language/Version**: Dart (Flutter 3.x), TypeScript/Node.js (Firebase Functions)
**Primary Dependencies**: `cloud_firestore`, `firebase_functions`, `node-telegram-bot-api` (for backend)
**Storage**: Cloud Firestore
**Testing**: Flutter Integration Tests, Firebase Local Emulator Suite
**Target Platform**: Web (Kiosk), Firebase (Serverless)
**Project Type**: Mobile/Web App + Backend-as-a-Service
**Performance Goals**: Staff mode entry < 3s, Report delivery +/- 5 min of schedule
**Constraints**: Philippines Time (UTC+8) for all scheduling and records
**Scale/Scope**: Single-store reporting v1


## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Principle I (User-Centric)**: Staff mode simplifies the experience for employees, directly supporting business efficiency. ✅
- **Principle II (Payment-First Fulfillment)**: Staff orders are recorded as "Cash" (paid) upon completion, ensuring verified status before fulfillment tracking. ✅
- **Principle IV (Data Integrity & Security)**: Staff/Walk-in tagging provides an audit trail for non-self-service orders. Security rules MUST enforce that only the kiosk can flag orders this way. ✅
- **Principle V (Spec Kit Compliance)**: Moving to Plan phase after Spec completion and Clarification. ✅


## Project Structure

### Documentation (this feature)

```text
specs/006-staff-mode-telegram-records/
├── plan.md              # Global technical approach
├── research.md          # Technical research and decisions
├── data-model.md        # Firestore entity definitions
├── quickstart.md        # Deployment and setup guide
├── contracts/           
│   └── report-contract.md # API and Message format definitions
└── tasks.md             # Implementation steps (TBD)
```

### Source Code (repository root)

```text
lib/
├── screens/
│   ├── splash_screen.dart   # [MODIFY] Added hidden gesture
│   ├── cart_page.dart       # [MODIFY] Logic for staff flow
│   └── staff_menu.dart      # [NEW] Hidden management menu
├── main.dart                # [MODIFY] Routes and Session logic
└── services/
    └── order_service.dart   # [NEW] Centralized Firestore writes

functions/                   # [NEW] Firebase Functions project
├── src/
│   ├── index.ts             # Entry point
│   ├── reporting/
│   │   ├── daily_report.ts  # Scheduled 10PM PHT logic
│   │   └── manual_report.ts # On-demand logic
│   └── telegram_api.ts      # Bot SDK integration
├── package.json
└── tsconfig.json
```

**Structure Decision**: A new `functions/` directory will be initialized for the backend logic. The Flutter app will be modularized with a new `OrderService` to handle database writes consistently.


## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
