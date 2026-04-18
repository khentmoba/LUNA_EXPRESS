<!--
Sync Impact Report:
- Version change: [INITIAL] → 1.0.0
- List of modified principles:
  - [PRINCIPLE_1_NAME] → User-Centric Ordering
  - [PRINCIPLE_2_NAME] → Payment-First Fulfillment
  - [PRINCIPLE_3_NAME] → Fulfillment Flexibility
  - [PRINCIPLE_4_NAME] → Data Integrity & Security
  - [PRINCIPLE_5_NAME] → Spec Kit Compliance
- Added sections: Technology Stack & Security, Development Workflow
- Removed sections: None
- Templates requiring updates:
  - ✅ .specify/templates/plan-template.md (Checked, generic gates sufficient)
  - ✅ .specify/templates/spec-template.md (Checked, structure aligns)
  - ✅ .specify/templates/tasks-template.md (Checked, categorization aligns)
- Follow-up TODOs:
  - Define specific payment provider (e.g., Stripe, PayPal) once decided.
  - Set up Firestore rules for the new ordering schema.
-->

# LUNA_EXPRESS Constitution

## Core Principles

### I. User-Centric Ordering
The ordering experience is the heart of LUNA_EXPRESS. Every interface decision must prioritize speed, clarity of menu items, and ease of cart management. Interfaces MUST be mobile-optimized by default.

### II. Payment-First Fulfillment
No order workflow shall proceed to the fulfillment stage (Kitchen/Preparation) without a verified payment status. This ensures business continuity and reduces abandonment risk.

### III. Fulfillment Flexibility
The system must natively support both 'Delivery' and 'Pickup' options. Each mode must collect appropriate metadata (delivery address/coordinates vs. pickup time/location) before the order is finalized.

### IV. Data Integrity & Security
Customer personal information and order history are sacred. We MUST use strict Firebase Security Rules to ensure users can only access their own data, and administrative overrides are audit-logged.

### V. Spec Kit Compliance
All feature development must follow the Spec Kit methodology. No implementation shall begin without a reviewed Spec and an approved Implementation Plan. This ensures architectural consistency and technical debt management.

## Technology Stack & Security

**Frontend**: Flutter Web / Mobile (Single codebase)
**Backend**: Firebase (Auth, Firestore, Storage)
**Security**: Principle of Least Privilege applies to all database access.

## Development Workflow

1. **Specification**: Define the "What" and "Why" in `/specs/[feature]/spec.md`.
2. **Planning**: Define the "How" and "Where" in `/specs/[feature]/plan.md`.
3. **Execution**: Breakdown into tasks in `/specs/[feature]/tasks.md` and implement.
4. **Verification**: Automated tests and user acceptance before merging.

## Governance

- This Constitution is the supreme guide for project development.
- Amendments require a version increment (MAJOR.MINOR.PATCH).
- All PRs must be checked against these principles during review.

**Version**: 1.0.0 | **Ratified**: 2026-04-19 | **Last Amended**: 2026-04-19
