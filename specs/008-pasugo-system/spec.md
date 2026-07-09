# Feature Specification: Pasugo (Errand) System

**Feature Branch**: `008-pasugo-system`  
**Created**: 2026-07-06  
**Status**: Draft  
**Input**: User description: "I would like to add a Pasugo System within the app itself..."

## Clarifications

### Session 2026-07-06

- **Q: Phone number privacy on bulletin board** → **A: Hidden until accepted** — bulletin shows customer name + errand message only; phone number is revealed to the rider only after they accept the errand.
- **Q: Customer access to active pasugo without account** → **A: Simple PIN (4-digit code)** — customer sets a 4-digit PIN when posting an errand; re-enters phone + PIN to access their active session/chat.
- **Q: Errand cancellation policy** → **A: Customer cancels before acceptance; rider can cancel after acceptance** — customer can freely remove their errand while unaccepted; once accepted, only the rider can cancel (notifying the customer). If rider is unresponsive, customer can request admin intervention.
- **Q: Map feature scope** → **A: Customer can optionally drop a pin on a map when posting their errand; rider sees the pin after accepting** — no live GPS tracking for v1. The pin provides a visual location for the rider to navigate to.
- **Q: Chat history persistence after session completion** → **A: Archive as read-only** — chat is closed (no new messages) and archived when rider marks session as done. Both parties can view past messages but cannot send new ones. Provides audit trail while preserving the "temporary" feel.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Customer Posts an Errand on the Bulletin Board (Priority: P1)

As a customer, I want to choose the "Pasugo" option from the Luna landing screen so that I can post an errand request on a public bulletin board for riders to see and accept.

**Why this priority**: This is the core flow that enables the entire pasugo service — without customers posting errands, there is nothing for riders to accept.

**Independent Test**: Can be fully tested by opening the app, clicking Pasugo, filling in name, phone number, 4-digit PIN, and errand message, then submitting. The bulletin board should display the post with name and message (phone hidden).

**Acceptance Scenarios**:

1. **Given** the customer is on the Luna landing screen, **When** they tap "Pasugo", **Then** they are taken to the errand creation screen (not the regular order flow).
2. **Given** the customer is on the errand creation screen, **When** they fill in Name, Phone Number, a 4-digit PIN, optionally drop a location pin on a map, and write an errand message and tap submit, **Then** the errand post appears on the public bulletin board with their name and message.
3. **Given** the customer tries to submit an errand, **When** the Name, Phone Number, or PIN fields are empty, **Then** the system shows a validation error and prevents submission.
4. **Given** the customer wants to check their active errand, **When** they return to the Pasugo screen and enter their phone + PIN, **Then** they can view their errand status and chat with the accepting rider.

---

### User Story 2 - Rider Registers and Gets Verified by Admin (Priority: P1)

As a rider, I want to register for a rider account and be verified by an admin so that I can accept pasugo errands from the bulletin board.

**Why this priority**: Riders must be trusted and verified before interacting with customers — this is a safety and trust prerequisite.

**Independent Test**: Can be fully tested by registering a new rider account, checking that the rider status is "Pending", then having an admin approve the rider from the dashboard. The rider should then be able to log in and see the bulletin board.

**Acceptance Scenarios**:

1. **Given** a new rider visits the rider registration screen, **When** they submit their registration details, **Then** their account is created with status "Pending" and they cannot yet access the bulletin board.
2. **Given** an admin views the rider management dashboard, **When** they see a rider with "Pending" status and click "Approve", **Then** the rider's status changes to "Approved" and the rider can now log in and accept errands.
3. **Given** an admin views the rider management dashboard, **When** they click "Reject" on a pending rider, **Then** the rider's status changes to "Rejected" and they receive a rejection notification.
4. **Given** a rider with "Pending" status tries to accept an errand, **When** they attempt to access the bulletin board, **Then** the system blocks access and shows a message that their account is awaiting verification.

---

### User Story 3 - Rider Accepts a Pasugo and Communicates with Customer (Priority: P2)

As a verified rider, I want to browse the bulletin board of available errands and accept one so that I can coordinate with the customer and complete the delivery.

**Why this priority**: This is the transaction flow where riders and customers connect.

**Independent Test**: Can be fully tested by a verified rider browsing the bulletin board, selecting an errand, accepting it, then seeing a temporary chat session open. If the customer dropped a location pin, the rider should see it on a map.

**Acceptance Scenarios**:

1. **Given** a verified rider is logged into the rider interface, **When** they browse the bulletin board, **Then** they see all available (unaccepted) pasugo errands listed with customer name and message.
2. **Given** a verified rider views an available errand, **When** they tap "Accept", **Then** the errand is marked as claimed and a temporary chat session is created between the rider and the customer.
3. **Given** a rider has accepted an errand, **When** the customer views the bulletin board, **Then** that errand is no longer visible as available to other riders.
4. **Given** a rider has accepted an errand with a location pin, **When** they view the chat, **Then** they can see the customer's dropped pin on a map within the session.

---

### User Story 4 - Rider Completes a Pasugo Session (Priority: P2)

As a rider, I want to mark a pasugo session as "Done" when the errand is complete so that the chat ends and the system resets for future errands.

**Why this priority**: Completing the lifecycle ensures accurate tracking and allows the same customer to post new errands.

**Independent Test**: Can be fully tested by a rider tapping "Mark as Done" in the active chat, then checking that the chat is closed and the errand is no longer active.

**Acceptance Scenarios**:

1. **Given** the rider is in an active pasugo chat, **When** they tap "Mark as Done", **Then** the chat session is closed for both parties (becomes read-only archive), the errand is marked as completed, and the rider is returned to the bulletin board.
2. **Given** a pasugo session is marked as done, **When** the customer returns to the app, **Then** they can post a new errand on the bulletin board.

---

### User Story 5 - Customer Views Pasugo Status (Priority: P3)

As a customer, I want to see when a rider has accepted my errand and communicate with them through the temporary chat so that I can coordinate delivery details.

**Why this priority**: While the core flow works without this, the chat feature is essential for coordination and a good user experience.

**Independent Test**: Can be tested by the customer viewing their posted errand and seeing rider acceptance, then exchanging messages in the temporary chat.

**Acceptance Scenarios**:

1. **Given** a customer has posted an errand, **When** a rider accepts it, **Then** the customer receives a notification and a chat session opens.
2. **Given** the customer is in the chat with the rider, **When** they send a message, **Then** the rider can see it in real-time.
3. **Given** the chat session is active, **When** the rider marks the session as done, **Then** the customer sees the chat is closed with a "Completed" status.

---

### Edge Cases

- What happens when a rider who accepted an errand becomes unresponsive? Customer can flag the session for admin intervention; admin can cancel and return the errand to the bulletin board.
- How does the system handle a rider who has been approved but later violates policies? (Admin should be able to deactivate/ban riders.)
- What happens if two riders try to accept the same errand at the exact same time? (System must prevent double-acceptance via atomic locking.)
- How does the system handle a customer who posts inappropriate content in the errand message? (Consider basic content moderation or reporting.)
- What happens if a rider or customer loses internet connection during the chat?
- How does the system handle errands that are never accepted? Consider auto-expiry after a set period.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Luna landing screen MUST display two primary options: "Order Now" and "Pasugo".
- **FR-002**: The system MUST provide an errand posting form that collects the customer's Name, Phone Number, a 4-digit PIN, and a free-text errand message.
- **FR-003**: The system MUST display all unaccepted errand posts on a public bulletin board view, showing only the customer's name and errand message — phone number MUST remain hidden until a rider accepts the errand.
- **FR-004**: The system MUST support rider account registration with details required for verification.
- **FR-005**: Rider accounts MUST default to "Pending" status upon registration.
- **FR-006**: The admin/staff dashboard MUST include a rider management section showing all registered riders and their verification status.
- **FR-007**: Admins MUST be able to approve or reject pending rider registrations from the dashboard.
- **FR-008**: Riders with "Pending" or "Rejected" status MUST NOT be able to access the bulletin board or accept errands.
- **FR-009**: Verified ("Approved") riders MUST be able to browse and accept available errands from the bulletin board.
- **FR-010**: The system MUST prevent two riders from accepting the same errand simultaneously.
- **FR-011**: The system MUST create a temporary chat session between the customer and rider upon errand acceptance.
- **FR-012**: The chat session MUST only be accessible to the customer who posted the errand and the rider who accepted it.
- **FR-013**: The rider MUST be able to mark a pasugo session as "Done", which closes the chat and marks the errand as completed.
- **FR-014**: Once marked as done, the errand MUST be removed from the rider's active list and the customer MUST be able to post new errands.
- **FR-015**: Completed errands and their chat history MUST be archived as read-only — both customer and rider can view past messages but cannot send new ones. The archive MUST be retained for audit/reference purposes.
- **FR-016**: The system MUST show a "Pasugo" landing screen when the Pasugo option is selected, distinct from the regular ordering flow.
- **FR-017**: The system MUST provide a way for customers to view the status of their posted errand (pending acceptance, active with rider, completed).
- **FR-018**: The system MUST support real-time (or near-real-time) messaging in the chat between customer and rider.
- **FR-019**: Customer name and phone number fields MUST be required and validated before submitting an errand.
- **FR-020**: The system MUST require the customer to set a 4-digit PIN when posting an errand, and use it together with their phone number to allow them to re-access their active session.
- **FR-021**: The system MUST reveal the customer's full phone number to the rider only after the rider accepts the errand and the chat session is created.
- **FR-022**: The system MUST NOT display the customer's phone number on the public bulletin board to any unauthenticated or non-accepting user.
- **FR-023**: The customer MUST be able to cancel their errand freely while it has status "available" (unaccepted).
- **FR-024**: Once an errand is accepted, the rider MUST be able to cancel the pasugo session, which notifies the customer and returns the errand to "available" status on the bulletin board.
- **FR-025**: If a rider becomes unresponsive, the customer MUST be able to flag the session to admin for intervention and potential cancellation.
- **FR-026**: The errand posting form SHOULD include an optional map pin feature allowing the customer to drop a location marker for the rider to see after acceptance.
- **FR-027**: Once a rider accepts an errand with a location pin, the rider MUST be able to view the pinned location on a map within the chat or session view.

### Key Entities *(include if feature involves data)*

- **Errand (Pasugo Post)**: A bulletin board listing created by a customer containing Name, Phone Number (hidden on public board — only revealed to accepting rider), 4-digit PIN for session access, errand message/description, optional location pin, status (available/accepted/completed/cancelled), and timestamp.
- **Rider**: A registered user with verification status (Pending/Approved/Rejected), contact details, and a rider profile managed by admin/staff.
- **Pasugo Session**: An accepted errand linking a specific customer, rider, and errand post, with lifecycle status (active/completed/cancelled) and a reference to the associated chat. A completed session becomes a read-only archive.
- **Chat Message**: Individual messages within a temporary chat session between a customer and rider for a specific pasugo session, containing sender, timestamp, and message content.
- **Admin/Staff User**: An existing privileged user who can manage rider registrations and oversee pasugo activity.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A customer can post an errand on the bulletin board in under 30 seconds from the Luna landing screen.
- **SC-002**: A verified rider can browse and accept an errand in under 15 seconds.
- **SC-003**: After a rider accepts an errand, a chat session with the customer is available within 3 seconds.
- **SC-004**: The system prevents double-acceptance of the same errand 100% of the time (tested with simultaneous taps).
- **SC-005**: An admin can approve or reject a rider registration in under 3 actions from the dashboard.
- **SC-006**: 95% of errands posted are accepted by a rider within 24 hours during operational hours.
- **SC-007**: Chat messages are delivered and visible to the recipient within 5 seconds of sending.
- **SC-008**: The system handles at least 100 concurrent pasugo sessions without performance degradation.

## Assumptions

- **Customer identity**: Customers do not need a full registered account for v1 — they provide Name, Phone Number, and a 4-digit PIN per errand post. The PIN + phone allows them to return and access their active session/chat. This keeps friction low while enabling session continuity.
- **Payment handling**: Payment for pasugo errands is arranged directly between the rider and customer through the chat. The app does not process any payments for pasugo items or delivery fees — it solely facilitates the connection, communication, and tracking of the errand.
- **Rider registration**: Riders register with basic information: full name, phone number, and address. No ID upload or vehicle details are required for v1. Admin verifies based on this basic info.
- **Map feature**: Customers can optionally drop a location pin on a map when posting their errand. The rider sees the pinned location on a map after accepting the errand. No live GPS tracking for v1.
- **Notifications**: Assumed basic push notifications when an errand is accepted or a message is received (using existing Firebase integration).
- **Errand expiry**: Unaccepted errands are assumed to expire after 48 hours and be automatically removed from the bulletin board.
- **Existing infrastructure**: The Pasugo System will reuse the existing Flutter/Firebase architecture (Firestore for data, Firebase Auth for rider authentication, Cloud Messaging for notifications).
- **Chat storage**: Chat messages are stored in Firestore within the session document/subcollection for audit and continuity.
