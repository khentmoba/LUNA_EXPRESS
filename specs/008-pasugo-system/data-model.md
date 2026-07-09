# Data Model: Pasugo (Errand) System

## Overview

The Pasugo subsystem uses Firestore collections for persistent storage. The data model centers on five entities: **Errand**, **Rider**, **Pasugo Session**, **Chat Message**, and **Admin User**. Rider authentication uses Firebase Auth with custom claims for verification status.

---

## Entity: Errand (pasugo_errands)

A bulletin board listing created by a customer.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string (auto) | auto | Firestore document ID |
| `customerName` | string | ✅ | Customer's full name |
| `customerPhone` | string | ✅ | Customer's phone number (hidden on public board) |
| `phoneHash` | string | ✅ | Hashed phone used for PIN-based session retrieval |
| `pinHash` | string | ✅ | Hashed 4-digit PIN for session re-access |
| `message` | string | ✅ | Free-text errand description |
| `locationPin` | GeoPoint | optional | Customer-dropped map pin (lat/lng) |
| `status` | enum | ✅ | `available` \| `accepted` \| `completed` \| `cancelled` |
| `createdAt` | timestamp | ✅ | When the errand was posted |
| `expiresAt` | timestamp | ✅ | Auto-expiry timestamp (48h after creation) |

**Validation Rules**:
- `customerName`: 2–100 characters
- `customerPhone`: valid phone format (PH mobile number)
- `pinHash`: SHA-256 hash of exactly 4 digits
- `message`: 10–500 characters

**Security Rules**:
- Read: Anyone can read errands where `status == "available"` (name + message only; phone and pinHash NOT readable by unauthenticated/non-accepting users)
- Write: Public write allowed for errand creation; only the owning customer can cancel their `available` errand (matched by phone + PIN)

---

## Entity: Rider (Firebase Auth + `riders` collection)

A registered delivery person with admin-managed verification.

| Auth Field | Type | Description |
|------------|------|-------------|
| `uid` | string | Firebase Auth UID |
| `email` | string | Rider's email (used for login) |
| `customClaims.riderStatus` | string | `pending` \| `approved` \| `rejected` |

| Firestore Field (`riders/{uid}`) | Type | Required | Description |
|----------------------------------|------|----------|-------------|
| `name` | string | ✅ | Rider's full name |
| `phone` | string | ✅ | Rider's contact number |
| `address` | string | ✅ | Rider's address |
| `status` | string | ✅ | `pending` \| `approved` \| `rejected` |
| `registeredAt` | timestamp | ✅ | When the rider registered |
| `approvedAt` | timestamp | optional | When admin approved the rider |
| `approvedBy` | string | optional | Admin UID who approved |
| `isActive` | boolean | ✅ | `true` by default; `false` if banned/deactivated |

**State Transitions**:
```text
[Pending] ──── admin approves ────→ [Approved]
[Pending] ──── admin rejects ─────→ [Rejected]
[Approved] ─── admin deactivates ─→ [Deactivated/Banned]
```

**Security Rules**:
- Read: Rider can read own document; admin can read all
- Write: Rider writes own document on registration; admin writes status changes only
- Custom claim `riderStatus` set by Cloud Function triggered on `riders/{uid}` document writes

---

## Entity: Pasugo Session (pasugo_sessions)

A link record created when a rider accepts an errand.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string (auto) | auto | Firestore document ID |
| `errandId` | string (ref) | ✅ | Reference to `pasugo_errands/{errandId}` |
| `riderId` | string (ref) | ✅ | Reference to `riders/{riderUid}` |
| `customerPhone` | string | ✅ | Customer's phone (for chat access) |
| `status` | enum | ✅ | `active` \| `completed` \| `cancelled` |
| `acceptedAt` | timestamp | ✅ | When the rider accepted |
| `completedAt` | timestamp | optional | When the session was completed/cancelled |
| `cancelledBy` | string | optional | `rider` \| `admin` |
| `cancellationReason` | string | optional | Reason for cancellation |

**Lifecycle States**:
```text
errand: available ──→ rider accepts ──→ session: active
                                              │
                           ┌──────────────────┼──────────────────┐
                           ▼                  ▼                  ▼
                   session: completed   session: cancelled   session: cancelled
                   errand: completed    errand: available     errand: available
                   (read-only archive)  (back on bulletin)   (back on bulletin)
```

**Security Rules**:
- Read: Participating customer (by phone), rider, or admin
- Write: Created by system on errand acceptance; updated by rider (mark done/cancel) or admin (cancel/intervention)

---

## Entity: Chat Message (pasugo_sessions/{sessionId}/messages)

Individual messages within a pasugo session.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string (auto) | auto | Firestore document ID |
| `sender` | string | ✅ | `customer` \| `rider` |
| `text` | string | ✅ | Message content |
| `timestamp` | timestamp | ✅ | When the message was sent |
| `type` | string | optional | `text` (default), `location_pin` (if rider views pin) |

**Validation Rules**:
- `text`: 1–1000 characters
- No new messages allowed when session `status != "active"`

**Security Rules**:
- Read: Participating customer (by phone + PIN hash check) or rider
- Write: Only when session is `active`; only by participants

---

## Entity: Admin/Staff User

An existing privileged user from the app's admin system.

| Field | Type | Description |
|-------|------|-------------|
| `uid` | string | Firebase Auth UID (existing admin) |
| `role` | string | `admin` \| `staff` |
| `permissions` | string[] | Includes `manage_riders` for pasugo admin functions |

Admin capabilities are added to the existing admin/staff user model. No new entity is created.

---

## Indexes

Composite indexes required for Firestore:

| Collection | Fields | Query |
|------------|--------|-------|
| `pasugo_errands` | `status` ASC, `createdAt` DESC | Bulletin board: show available errands newest first |
| `pasugo_errands` | `customerPhone` ASC | Customer lookup: find errands by phone |
| `pasugo_sessions` | `riderId` ASC, `status` ASC | Rider active sessions |
| `pasugo_sessions` | `errandId` ASC | Lookup session by errand |

---

## Relationships

```text
Errand (1) ──< Pasugo Session (1) ──< Chat Message (many)
  │                │
  │                └── Rider (1)
  │
  └── Customer (no account, identified by phone + PIN)
```

- An **Errand** is posted by a customer (identified by phone + PIN hash)
- A **Pasugo Session** is created when a **Rider** accepts an **Errand**
- **Chat Messages** belong to a **Pasugo Session** as a subcollection
- An **Admin** manages **Riders** (approve/reject/deactivate)
