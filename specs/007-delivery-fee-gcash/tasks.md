# Tasks: Delivery Fee & GCash Integration

**Feature**: Delivery Fee & GCash Integration
**Implementation Plan**: [plan.md](plan.md)
**User Stories**: [spec.md#user-scenarios--testing](spec.md#user-scenarios--testing)

## Phase 1: Setup

- [x] T001 Verify project structure and ensure all design artifacts are loaded in `specs/007-delivery-fee-gcash/`

## Phase 2: Foundational

- [x] T002 Update `OrderModel` to include `deliveryFee`, `totalDistance`, `paymentMethod`, and `paymentStatus` in `lib/models/order.dart`
- [x] T003 Update `toJson` and `fromJson` (if applicable) logic in `lib/models/order.dart` to handle new fields
- [x] T004 Update `TelegramService.sendOrder` signature in `lib/main.dart` to accept new delivery and payment parameters

## Phase 3: User Story 1 - Delivery Fee Calculation [US1]

**Goal**: Automatically calculate ₱39/km fee based on pinned map location.
**Test Criteria**: Pin a location 1km away -> Verify ₱39 fee appears in summary and Total.

- [x] T005 [P] [US1] Implement `_calculateDeliveryFee(double customerLat, double customerLng)` method using Haversine formula in `_CheckoutPageState` inside `lib/main.dart`
- [x] T006 [US1] Integrate `_calculateDeliveryFee` into the `_openMapPicker` callback in `lib/main.dart`
- [x] T007 [US1] Add "Delivery Fee" Row to the Order Summary UI in `lib/main.dart`
- [x] T008 [US1] Update `totalPrice` display logic in `CheckoutPage` to include `_deliveryFee` in `lib/main.dart`

## Phase 4: User Story 2 - GCash Payment Option & Summary Update [US2]

**Goal**: Allow choosing GCash and display payment instructions.
**Test Criteria**: Select GCash -> See QR placeholder/number. Total must still include delivery fee.

- [x] T009 [P] [US2] Add `_paymentMethod` state and method selection toggle button UI to `CheckoutPage` in `lib/main.dart`
- [x] T010 [US2] Create GCash Instructions UI component (displaying number/QR placeholder) in `CheckoutPage` in `lib/main.dart`
- [x] T011 [US2] Update `_submitOrder` logic to correctly populate `paymentMethod` and `paymentStatus` based on UI selection in `lib/main.dart`

## Phase 5: User Story 3 - Telegram Receipt Payment Status [US3]

**Goal**: Display Payment Method and Status on staff notifications.
**Test Criteria**: Place GCash order -> Verify Telegram message shows "Payment: GCash" and "Status: PENDING VERIFICATION".

- [x] T012 [US3] Update Telegram message template in `TelegramService.sendOrder` to include Delivery Fee, Payment Method, and Payment Status fields in `lib/main.dart`
- [x] T013 [US3] Update `CartPage` (Staff Mode) receipt generation logic to pass default "NOT PAID" status to `sendOrder` in `lib/main.dart`

## Phase 6: Polish & Edge Cases

- [x] T014 Implement 10km radius check within `_calculateDeliveryFee` and display warning/disable order button in `lib/main.dart`
- [x] T015 Enforce GPS requirement (disable "Place Order" if Delivery is selected but no coordinates are pinned) in `lib/main.dart`
- [x] T016 Final UI polish for consistent spacing and premium look per `KioskTheme` in `lib/main.dart`

## Dependencies

- **US2** depends on **T002**, **T003**, **T004**
- **US3** depends on **US1**, **US2**
- **Polish** depends on **US1**

## Implementation Strategy

1. **Foundational (T002-T004)**: Ensure data layer can handle the new information.
2. **MVP (US1)**: Get the automatic fee working first as it's the core calculation engine.
3. **Payments (US2)**: Add the payment method toggle.
4. **Ops (US3)**: Ensure staff get the right info on Telegram.
5. **Validation**: Add the 10km limit and GPS requirements to solidify the business rules.
