# Quickstart: Delivery Fee & GCash Feature

## Configuration
The store coordinates are hardcoded in `main.dart` for the MVP:
- Latitude: `9.0205090`
- Longitude: `125.5175910`

## Key Implementation Areas

### 1. Distance Calculation
Located in `_CheckoutPageState._calculateDeliveryFee`. Uses the Haversine formula.

### 2. UI Summary
The `Order Summary` section in `CheckoutPage` now includes a `Delivery Fee` row which is dynamically updated.

### 3. Payment Toggle
The `CheckoutPage` includes a toggle for Cash vs GCash. GCash displays the static instructions.

### 4. Telegram Notification
`TelegramService.sendOrder` has been updated to accept and display the payment status.

## Verification
1. Open the app as a customer.
2. Add items to cart and go to checkout.
3. Select "Delivery".
4. Pin a location. Confirm the distance and fee (₱39 * KM).
5. Ensure "Proceed" is blocked if no location is pinned.
6. Verify Telegram receipt reflects the selected payment method.
