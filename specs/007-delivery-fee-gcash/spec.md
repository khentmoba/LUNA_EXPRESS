# Feature Specification: Delivery Fee & GCash Integration

**Feature Branch**: `007-delivery-fee-gcash`  
**Created**: 2026-04-20  
**Status**: Draft  
**Input**: User description: "add an automatic delivery fee based on peso per km (39 pesos/km), store location (9.0205090, 125.5175910), show on checkout summary, total amount, add GCash online payment, and update Telegram receipt status."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Distance-based Delivery Fee Calculation (Priority: P1)

As a customer ordering for delivery, I want the system to automatically calculate my delivery fee based on my distance from the store so that I know the transparent cost before placing my order.

**Why this priority**: Essential for automated checkout and transparent pricing. 39 pesos per km is a fixed business rule.

**Independent Test**: Can be tested by selecting a delivery address at various distances and verifying the "Delivery Fee" line item in the order summary matches (distance in km * 39).

**Acceptance Scenarios**:

1. **Given** the store is at `(9.0205090, 125.5175910)`, **When** a user enters a delivery address 2km away, **Then** the checkout summary shows a delivery fee of 78 pesos.
2. **Given** a delivery order is being prepared, **When** the distance is less than 1km, **Then** the system should still calculate the fee proportionally or apply a minimum (Assume proportional unless specified).

---

### User Story 2 - GCash Payment Option & Summary Update (Priority: P1)

As a customer, I want to choose GCash as a payment method during checkout so that I can pay online instead of cash on delivery.

**Why this priority**: Core requirement for online payment integration.

**Independent Test**: Can be tested by selecting "GCash" in the payment method selector and verifying the order summary includes the delivery fee in the final total.

**Acceptance Scenarios**:

1. **Given** the checkout page, **When** the user selects "GCash", **Then** the payment instructions or QR code should be displayed (Assume standard manual GCash flow for now).
2. **Given** any payment method, **When** the delivery fee is calculated, **Then** the "Grand Total" reflects the sum of items + delivery fee.

---

### User Story 3 - Telegram Receipt Payment Status (Priority: P2)

As a staff member/manager, I want to see the payment status (Paid/Not Paid) on the Telegram order receipt so that I know whether to collect payment upon delivery.

**Why this priority**: Critical for operational efficiency and avoiding payment errors.

**Independent Test**: Place an order with GCash vs Cash and verify the Telegram message includes "Status: PAID" or "Status: NOT PAID" accordingly.

**Acceptance Scenarios**:

1. **Given** a GCash order is placed, **When** the notification is sent to Telegram, **Then** the receipt explicitly states "Payment Status: PAID" (or "NOT PAID" if verification is pending).
2. **Given** a Walk-in or COD order, **When** the notification is sent, **Then** it states "Payment Status: NOT PAID".

---

### Edge Cases

- **Invalid Location**: If the user's location cannot be determined or is invalid, how does the system fallback? (Assumption: Prompt for manual entry or use a default flat fee).
- **Zero Distance**: If the customer is at the store (pickup disguised as delivery), fee should be 0.
- **Large Distances**: Is there a maximum delivery range? (Assumption: No limit for now, just proportional calculation).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST store the base coordinates for the store: `(9.0205090, 125.5175910)`.
- **FR-002**: System MUST calculate distance using the Haversine formula or a reliable mapping service.
- **FR-003**: System MUST multiply calculated distance (km) by 39 pesos to determine the delivery fee.
- **FR-004**: System MUST display "Delivery Fee" as a separate line item in the Order Summary.
- **FR-005**: System MUST include "GCash" as a selectable payment option in the checkout flow.
- **FR-006**: System MUST update the Telegram order notification template to include a clear "Payment Status" field.
- **FR-007**: System MUST set Payment Status to 'PENDING VERIFICATION' for GCash and 'NOT PAID' for Cash/Walk-in.
- **FR-008**: System MUST display GCash payment instructions (Phone Number and QR Code Placeholder) when GCash is selected.
- **FR-009**: System MUST restrict delivery orders to a maximum radius of 10km from the store.
- **FR-010**: System MUST display a warning message if the pinned location is outside the 10km delivery range.
- **FR-011**: System MUST require a valid pinned location on the map before allowing a Delivery order to be submitted.
- **FR-012**: System MUST disable the "Place Order" button for Delivery orders if coordinates are not available.

### Key Entities

- **Order**: Updated to include `deliveryFee`, `totalDistance`, `paymentMethod`, and `paymentStatus`.
- **StoreLocation**: A configuration entity for the origin point.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Delivery fee is calculated correctly (Strictly distance * 39) for 100% of delivery orders.
- **SC-002**: Payment status is correctly reflected in Telegram receipts (PENDING VERIFICATION for GCash).
- **SC-003**: Checkout "Grand Total" always equals Item Subtotal + Delivery Fee + (any other charges).

## Clarifications

### Session 2026-04-20
- Q: GCash Payment Flow → A: Option B (Display GCash number/QR code).
- Q: Payment Status on Telegram → A: Option B (PENDING VERIFICATION for GCash).
- Q: Delivery Fee Minimums → A: Option A (No minimum, strictly ₱39/km).
- Q: Maximum Delivery Range → A: Option B (10km Limit).
- Q: GPS & Location Fallback → A: Option A (GPS Required).

## Assumptions

- **Distance Logic**: We will use a standard Haversine distance calculation for MVP, ignoring road route complexity unless Map API is explicitly configured.
- **GCash Verification**: For simplicity, selecting GCash marks the order as "PAID" in the system to satisfy the user's "Paid or Not Paid" requirement, but we might need a verification step.
- **User Location**: The frontend is capable of providing the user's delivery coordinates (Lat/Long).
- **Telegram Bot**: The existing Telegram bot integration is functional and the message template is accessible.
