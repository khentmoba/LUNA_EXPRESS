# Feature Specification: Menu Pricing and Section Updates

**Feature Branch**: `002-update-menu-prices-sections`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "remove the burger and hotdog bun section since we have it on another section already, change the price of shawarma wrap into 60 pesos, and shawarma quesadilla into 75 pesos, make all "B1T1" into the site into "Buy 1 Take 1" cause some customers might get confused and not understand, also add oreo craze in extras, The Oreo Craze features a variety of specialty drinks in large sizes, all priced at a flat rate of 65. You can choose from indulgent options like Cookies & Cream Overload, Chocolate Oreo, and Strawberry Oreo, or opt for the Milo Oreo Float."

## Clarifications

### Session 2026-04-19
- Q: Which specific sections should be removed to eliminate redundancy? → A: Remove both the separate "Burgers" and "Hotdog Bun" categories.
- Q: How should the "Oreo Craze" specialty drinks be displayed? → A: As a sub-heading (group) named "Oreo Craze" within the Extras category.
- Q: Should the "Large" size indicator be part of the item's display name? → A: Yes, include "(Large)" in the name (e.g., "Chocolate Oreo (Large)").

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Updated Shawarma Pricing (Priority: P1)

As a customer browsing the menu, I see the updated prices for Shawarma items so I am charged the correct amount.

**Why this priority**: Correct pricing is essential for business operations and customer trust.

**Independent Test**: Can be verified by viewing the Shawarma section in the menu and checking the price labels for Wrap and Quesadilla.

**Acceptance Scenarios**:

1. **Given** the customer is on the menu page, **When** they look at "Shawarma Wrap", **Then** the price displayed is 60 Pesos.
2. **Given** the customer is on the menu page, **When** they look at "Shawarma Quesadilla", **Then** the price displayed is 75 Pesos.

---

### User Story 2 - Menu Clarification: Buy 1 Take 1 (Priority: P2)

As a customer viewing promotional items, I see "Buy 1 Take 1" instead of "B1T1" so that the deal is immediately clear to me.

**Why this priority**: Improves user experience and reduces confusion for new customers.

**Independent Test**: Search for the string "B1T1" across the application UI and ensure it is replaced by "Buy 1 Take 1".

**Acceptance Scenarios**:

1. **Given** an item has a "Buy 1 Take 1" promotion, **When** it is displayed in the menu, **Then** the label explicitly says "Buy 1 Take 1".

---

### User Story 3 - Oreo Craze Drink Selection (Priority: P1)

As a customer, I want to see all "Oreo Craze" flavors under a single menu item so I can easily compare and pick my preferred flavor from the options.

**Why this priority**: Improves menu organization and aligns with the existing "French Fries" selection pattern.

**Independent Test**: Verify that clicking "Oreo Craze" in the Extras section reveals all flavor options as variants.

**Acceptance Scenarios**:

1. **Given** the customer is in the "Extras" section, **When** they see "Oreo Craze", **Then** the price displayed is 65 Pesos.
2. **Given** the customer selects "Oreo Craze", **When** they view the variants, **Then** only Cookies & Cream Overload, Chocolate Oreo, Strawberry Oreo, and Milo Oreo Float are listed.

---

### User Story 4 - Redundant Section Removal (Priority: P1)

As a customer, I do not see the "Burger & Hotdog Bun" section twice so that the menu is not cluttered.

**Why this priority**: Improves navigation speed and menu professionality.

**Independent Test**: Verify that only one instance of the burger/hotdog items exists in the menu.

**Acceptance Scenarios**:

1. **Given** the menu is loaded, **When** the user scrolls through categories, **Then** the "Burger & Hotdog Bun" section specifically requested for removal is gone.

---

### Edge Cases

- What happens if "B1T1" is used in an image asset? (Assumption: Only text-based labels are updated).
- Q: Should the "Large" size indicator be part of the item's display name? → A: Yes, include "(Large)" in the name (e.g., "Chocolate Oreo (Large)").
- Q: Should other variations like "Buy1 Take1" also be normalized? → A: Yes, normalize all variations ("B1T1", "Buy1 Take1") to "Buy 1 Take 1".

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST remove the "Burgers" and "Hotdog Bun" categories from the active menu, as they are now consolidated in the "Burger & Hotdog Sandwich" section.
- **FR-002**: System MUST update the base price of "Shawarma Wrap" to 60 Pesos.
- **FR-003**: System MUST update the base price of "Shawarma Quesadilla" to 75 Pesos.
- **FR-004**: System MUST perform a global replacement of the strings "B1T1" and "Buy1 Take1" (and variations) with "Buy 1 Take 1" in menu item labels and descriptions.
- **FR-005**: System MUST add a new `MenuItem` named "Oreo Craze" within the Extras category.
- **FR-006**: System MUST include the following flavors as `MenuVariant` options within the "Oreo Craze" item: Cookies & Cream Overload, Chocolate Oreo, Strawberry Oreo, and Milo Oreo Float.
- **FR-007**: System MUST set a flat price of 65 Pesos for all variants in "Oreo Craze".
- **FR-008**: System MUST include "(Large)" in the variant labels or the main item description for all Oreo Craze options.

### Key Entities *(include if feature involves data)*

- **MenuItem**: Represents an individual food or drink item (Attributes: name, price, category, promoLabel).
- **Category**: Represents a grouping of MenuItems (Attributes: name, isActive).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of "B1T1" occurrences in the UI text are replaced by "Buy 1 Take 1".
- **SC-002**: Shawarma Wrap price is exactly 60 in the database and UI.
- **SC-003**: Shawarma Quesadilla price is exactly 75 in the database and UI.
- **SC-004**: All 4 "Oreo Craze" drinks are visible and orderable at 65 Pesos.
- **SC-005**: The redundant "Burger & Hotdog Bun" section is no longer present in the category list.

## Assumptions

- "Oreo Craze" items belong to the "Extras" category but may have their own header/grouping.
- "B1T1" replacement is for user-facing text only (not internal IDs or keys if they exist).
- The user has another section for burgers/hotdogs already correctly configured.
- Large size is the default and only size for Oreo Craze specialty drinks.
