# Research: Pasugo (Errand) System

## Technical Decisions

### 1. Firestore Data Model for Bulletin Board

**Decision**: Use a top-level `pasugo_errands` collection with an `available` status field for bulletin board queries. Accepted errands create a `pasugo_sessions` subcollection entry.

**Rationale**: Firestore queries on collection fields are efficient. Filtering by `status == "available"` gives the bulletin board view. Creating a session document links the customer, rider, and errand without duplicating data. This avoids complex nested structures and keeps queries simple.

**Alternatives considered**: 
- Subcollection under each errand for session data (creates deep nesting, harder to query active sessions)
- Single `pasugo_sessions` collection with embedded errand data (data duplication on updates)

### 2. Real-Time Chat Implementation

**Decision**: Use Firestore snapshots (`.snapshots()`) on a `messages` subcollection within each `pasugo_session` document. Each message is a document with `sender`, `text`, `timestamp`, and `type` fields.

**Rationale**: Firestore's real-time listeners provide out-of-the-box chat functionality without needing a dedicated messaging service like PubNub or Firebase Realtime Database. The existing Flutter/Firebase stack already uses Firestore, so this adds zero new dependencies. Documents are ordered by `timestamp` ascending for chronological display.

**Alternatives considered**:
- Firebase Realtime Database (better for high-frequency chat but adds new infrastructure)
- Cloud Functions + PubSub (over-engineered for v1 chat needs)

### 3. Atomic Errand Acceptance (Double-Claim Prevention)

**Decision**: Use Firestore transactions with a two-phase check: (1) read errand document within transaction, verify `status == "available"`, (2) update status to `accepted` and create session document atomically.

**Rationale**: Firestore transactions are the standard mechanism for preventing race conditions. The transaction reads the errand's current status, and only proceeds if it's still available. If two riders tap "Accept" simultaneously, only the first transaction commits; the second fails and the rider sees an "Errand already claimed" message.

**Alternatives considered**:
- Client-side locking (unreliable with concurrent users)
- Cloud Function as a single entry point (adds latency and cost)

### 4. Map Pin Integration

**Decision**: Store the optional location as a Firestore `GeoPoint` field on the errand document. Display using `flutter_map` with a `Marker` widget at the pinned coordinates.

**Rationale**: Firestore natively supports `GeoPoint` for lat/lng storage. The app already depends on `flutter_map` and `latlong2`, so map rendering is already available. No new geocoding or reverse-geocoding service needed for v1 — the pin is manually dropped by the customer.

**Alternatives considered**:
- Google Maps widget (would require additional API key setup and new dependency)
- Address text only (no visual map, less useful for rider navigation)

### 5. PIN-Based Customer Session Access

**Decision**: When a customer posts an errand, the 4-digit PIN is hashed (bcrypt/sha256) and stored alongside the phone number on the errand document. The customer re-enters their phone + PIN to retrieve their errand(s) by matching against the errand collection.

**Rationale**: No Firebase Auth needed for customers, keeping friction low. The PIN is stored hashed so even if the Firestore rules are bypassed, the raw PIN is not exposed. Queries filter by phone number, then the client checks the PIN hash match.

**Alternatives considered**:
- Firebase Anonymous Auth (creates anon user per errand, harder to recover sessions)
- SMS OTP (requires SMS service integration and costs)

### 6. Rider Authentication & Verification

**Decision**: Riders use Firebase Auth with email/password for login. Verification status is stored as a custom claim (`riderStatus: "pending" | "approved" | "rejected"`) set by a Cloud Function triggered from the admin dashboard in Firestore.

**Rationale**: Custom claims allow Firestore Security Rules to check verification status at the database level — a rider with `pending` status cannot read the bulletin board or write to sessions. This provides defense in depth.

**Alternatives considered**:
- Rider status stored in a Firestore document only (Security Rules more complex, requires extra reads)
- Separate rider Users collection + manual check in app code (easier to bypass)

### 7. Notifications

**Decision**: Use Firebase Cloud Messaging (FCM) for push notifications — notify the customer when a rider accepts their errand, and notify the rider when a customer sends a chat message (if the app is backgrounded).

**Rationale**: FCM is already available in the project via Firebase integration. No additional service needed.

### 8. Chat Archive Strategy

**Decision**: When a session is marked as done, set a `status: "archived"` field on the session document. All existing messages remain in the `messages` subcollection with read-only access. No data is moved or deleted.

**Rationale**: Simplest implementation — no data migration needed. Security Rules enforce read-only after archiving (no new message writes allowed). Both parties can view the history through the same Firestore listener, just with different UI state (no input field).
