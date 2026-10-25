# Staff Operations Kanban Board & Quick PIN Authentication

Proof of implementation and visual verification for the Luna Bites & Delights staff portal upgrade, including Quick PIN authentication, shift session persistence, and the live operations Kanban board with Web Audio alerts.

## 1. Concrete Proof Artifacts

All artifacts captured from the actual running Flutter web build:

- **Desktop Operations Kanban Board (1280x800):** `docs/evidence/staff-kds-kanban-desktop.png`
  - 3-column Kanban layout: `1. PENDING QUEUE`, `2. PREPARING NOW`, `3. READY FOR PICKUP / RIDER`.
  - Rich cards showing order type badges (Delivery, Pickup, Walk-in), payment badges (GCash Paid vs Cash Unpaid), elapsed time trackers, customer phone links, delivery landmark with Google Maps navigation button, interactive checkboxes for kitchen assembly, and primary stage transition actions.
- **Mobile Operations Tabbed Board (390x844):** `docs/evidence/staff-kds-kanban-mobile.png`
  - Responsive segmented status tab bar with badge counts (`PENDING 1`, `COOKING 1`, `READY 1`, `DONE 0`), full order cards, and sticky app bar.
- **Desktop Quick PIN Dialog:** `docs/evidence/staff-pin-desktop.png`
  - Tactile 4-digit PIN pad (`1 2 3`, `4 5 6`, `7 8 9`, `⌫ 0 →`) with masked dot indicators (`○ ○ ○ ○`) and default PIN `1234`.
- **Desktop Password Login Tab:** `docs/evidence/staff-password-desktop.png`
  - Username & password fallback tab with show/hide password toggle.
- **Mobile Quick PIN Screen (390x844):** `docs/evidence/staff-pin-mobile.png`
  - Touch-optimized PIN entry card on mobile viewports.

## 2. Operational Features & Architecture

### A. Frictionless Kiosk Authentication
- **Tactile Quick PIN**: Default PIN `1234` configured out-of-the-box. Passwords and PINs are securely hashed using scrypt with per-user salt on the server.
- **Rate-Limited Server Verification**: `verifyStaff` Cloud Function enforces brute-force protection (lockout after 5 failed attempts) and issues custom Firebase Auth tokens with `staff` claims.
- **Direct Bookmarking**: Staff can navigate directly to `/kiosk/#/staff` or `/kiosk/#/orders` (mapped to `KdsPage`).
- **Shift Session Persistence**: `Session` monitors `FirebaseAuth.instance.authStateChanges()` to restore credentials across page refreshes and device sleep.

### B. Kitchen & Dispatch Kanban Board
- **Status Lifecycle**: `Pending` → `Preparing` → `Ready` → `Completed` (or `Cancelled`).
- **Real-Time Auto-Sync**: Background timer syncs with Cloud Functions every 10 seconds with a visual countdown and manual refresh trigger.
- **Two-Tone Audio Chime**: Synthesized via HTML5 Web Audio API (659 Hz & 880 Hz sine wave) playing automatically when new pending orders arrive in the queue. Sound toggle in the header allows kitchen staff to mute or test the alert.
- **Operational Efficiency**: Includes 1-tap `POS WALK-IN` button to take in-person counter orders, with an `[ORDERS]` badge pinned to the menu header to toggle back immediately.

## 3. Automated Verification Results

- `flutter test`: 31/31 passed (including new `test/staff_kds_test.dart`).
- `dart analyze`: passed with 0 errors and 0 warnings.
- `dart format`: 100% compliant with repository formatting standards.
- `cd functions && npm test`: 16/16 passed (including new `test/staff_auth.test.js`).
- `cd functions && npm audit --audit-level=high`: passed with zero high or critical vulnerabilities.
