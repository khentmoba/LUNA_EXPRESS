# Feature Specification: Staff Mode and Telegram Order Records

**Feature Branch**: `006-staff-mode-telegram-records`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "this is good for a customer standpoint, but what about staff, where after checking out it just gives the receipt cause there are customers on the store and rather than manually writing records, they can just use the records on telegram, so i want a staff mode of the app but i cant really think of how to integrate it without making it look unprofessional by having a literal 'log in' system thats very blatant, also i want the telegram bot to create a full records of orders that was done in the day, that is automated to send at every 10pm philippines time cause my store is closed"

## Clarifications

### Session 2026-04-19
- Q: When a staff member initiates a checkout, should the system assume a default payment method (e.g., Cash) to maximize speed, or should they still select from a limited list? → A: Option A - Default to Cash (No selection required).
- Q: Should the system also allow a manual "On-Demand" report from the app's Staff Mode? → A: Option B - Staff Mode Only (A button is added to the hidden staff menu for on-demand reports).
- Q: How detailed should the Telegram report be? → A: Option B - Detailed Summary (Total sales, total count, and top best-selling items/categories).
- Q: Should orders processed in Staff Mode be explicitly tagged? → A: Option B - Tag as Walk-in/Staff (Orders are explicitly marked in the database and report).


## User Scenarios & Testing *(mandatory)*

### User Story 1 - Hidden Staff Mode Access (Priority: P1)

As a staff member, I want to access a "Staff Mode" without customers noticing a blatant login screen, so that I can switch the device for internal use quickly and professionally.

**Why this priority**: High. This is the core entry point for the staff-specific workflow and addresses the user's concern about professionalism.

**Independent Test**: Can be tested by performing the "secret" action (e.g., long pressing a logo) and verifying that the app enters a staff-only state.

**Acceptance Scenarios**:

1. **Given** the app is on the main landing screen, **When** the staff performs the hidden trigger action, **Then** the app enters Staff Mode.
2. **Given** the app is in Staff Mode, **When** the app is idle for a long period or manually exited, **Then** it reverts to Customer Mode.

---

### User Story 2 - Efficient Staff Checkout (Priority: P1)

As a staff member processing a walk-in order, I want the checkout process to be streamlined to just generating a receipt and recording the transaction, so that I don't have to manually write records during busy hours.

**Why this priority**: High. This is the primary functional value for the staff—saving time on records.

**Independent Test**: Can be tested by placing an order in Staff Mode and verifying that checkout proceeds directly to a receipt/record confirmation without customer-facing prompts (like payment method selection or loyalty prompts if any).

**Acceptance Scenarios**:

1. **Given** the app is in Staff Mode and an order is ready, **When** checkout is initiated, **Then** the transaction is recorded as a "Cash" payment and a receipt is shown immediately.
2. **Given** a staff order is completed, **When** the receipt is shown, **Then** the app resets back to the Staff Mode menu for the next order.


---

### User Story 3 - Automated Daily Telegram Report (Priority: P2)

As a store owner, I want to receive a summary of all orders processed during the day via Telegram at 10 PM PHT, so that I can review sales after closing without manual intervention.

**Why this priority**: Medium. Provides automated auditing and reporting for the owner.

**Independent Test**: Can be tested by manually triggering the report script and verifying the message format in Telegram, and by observing the scheduled execution.

**Acceptance Scenarios**:

1. **Given** multiple orders have been processed during the day, **When** it is 10 PM PHT, **Then** a Telegram bot sends a formatted summary to the owner.
2. **Given** no orders were processed on a specific day, **When** it is 10 PM PHT, **Then** the bot sends a "No orders recorded today" message.

---

### Edge Cases

- **Trigger Accidental Discovery**: What happens if a customer accidentally performs the hidden action? (Should require a non-obvious gesture).
- **Network Failure for Telegram**: How does the system handle failed report delivery? (Should log the failure and possibly retry or alert via other means).
- **Timezone Drift**: System MUST ensure it uses Philippines Time (Asia/Manila) regardless of server location.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a hidden mechanism (e.g., long press on specific UI element) to toggle Staff Mode.
- **FR-002**: System MUST indicate current "Staff Mode" status to the user (staff) subtly (e.g., a small badge or color tint).
- **FR-003**: In Staff Mode, the checkout flow MUST default to "Cash" payment and skip all customer-facing steps to go directly to the record/receipt view.

- **FR-004**: System MUST persist all staff-recorded orders to the centralized order database and MUST tag them as "Staff/Walk-in" for reporting purposes.

- **FR-005**: System MUST automate a daily report containing total sales, item counts, and order timestamps, and MUST provide a button in Staff Mode to trigger this report manually.

- **FR-006**: System MUST send the daily report via a configured messaging service API.
- **FR-007**: The report delivery MUST be scheduled for 10:00 PM Philippines Standard Time (UTC+8).
- **FR-008**: Staff Mode configuration MUST be configurable (e.g., the hidden trigger element).

### Key Entities *(include if feature involves data)*

- **DailyReport**: A summary object containing aggregated data for a 24-hour period.
- **TelegramConfig**: Configuration for the bot token and target chat ID.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Staff can transition to Staff Mode in under 3 seconds using the hidden gesture.
- **SC-002**: Checkout in Staff Mode requires 50% fewer steps/taps compared to Customer Mode.
- **SC-003**: Telegram report is delivered daily within 5 minutes of 10:00 PM PHT.
- **SC-004**: The report includes at minimum: Total Revenue, Total Orders, and a Detailed Breakdown of top-selling items and categories for the day.


## Assumptions

- **PHT Timezone**: The server/function environment supports timezone-aware scheduling or UTC offset calculation for Asia/Manila.
- **Telegram Access**: The owner will provide a Telegram Bot Token and Chat ID.
- **Persistence**: The existing order database schema is sufficient to track "Staff" vs "Customer" orders if needed.
- **Hidden Action**: We will use a "Triple Tap on the Bottom-Right Corner of the Landing Page" as the hidden action to toggle Staff Mode.
