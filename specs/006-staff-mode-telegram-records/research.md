# Research: Staff Mode and Telegram Reporting

## Triple Tap Implementation
- **Location**: `lib/screens/splash_screen.dart`.
- **Method**: Use a `Positioned` `GestureDetector` in the bottom-right corner (approx 100x100 area).
- **Logic**: Track `tapCount` and `lastTapTimestamp`. If 3 taps occur within 1 second, trigger `session.login('staff')`.

## Order Persistence
- **Current State**: 
  - Customer orders are sent to Telegram but NOT saved to Firestore.
  - Staff orders (legacy) are NOT saved anywhere; they only show a receipt.
- **Decision**: Implement a centralized `FirestoreService` to save all orders.
- **Schema**:
  - Collection: `orders`
  - Fields:
    - `orderId`: String (LU-XXXXX)
    - `items`: List<Map>
    - `total`: Number
    - `type`: String ("Delivery", "Pickup")
    - `entryType`: String ("Kiosk", "Staff")
    - `timestamp`: Timestamp (server version)
    - `dateLabel`: String (YYYY-MM-DD in PHT, for easy querying)

## Telegram Reporting (Backend)
- **Technology**: Firebase Cloud Functions (Node.js/TypeScript).
- **Scheduler**: `firebase-functions/v2/scheduler`.
- **Timezone**: "Asia/Manila" (PHT, UTC+8).
- **Automation**: Trigger `dailySalesReport` at 22:00 (10 PM).
- **On-Demand**: Trigger `manualSalesReport` via HTTPS Callable.
- **Library**: `node-telegram-bot-api` for rich message formatting (bolding, lists).

## Staff Mode UI
- **Indicator**: Add a small green indicator dot or "Staff Active" text in the menu header.
- **Controls**: Add a "Staff Menu" (accessible via the indicator) containing:
  - "Generate Today's Report Now" (triggers on-demand report).
  - "Log Out" (exits Staff Mode).

## Constraints & Edge Cases
- **Duplicate Reports**: Ensure the daily report only covers orders from the current PHT day.
- **Network Failure**: The Flutter app should attempt to retry Firestore writes, or indicate failure to staff.
- **Bot Security**: Ensure the HTTPS Callable for manual reports is only accessible from the app, and ideally restricted to "staff" (though basic kiosks are often trusted environments).
