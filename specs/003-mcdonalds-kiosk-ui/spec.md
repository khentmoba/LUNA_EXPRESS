# Feature Specification: McDonalds-Style Kiosk UI

**Feature Branch**: `003-mcdonalds-kiosk-ui`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "i would like to have a ui just like the mcdonalds screen something where you order, its smooth, simple and aesthetic, also change the color into a yellowish something just like the website logo so that it matches"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Self-Service Ordering Experience (Priority: P1)

As a customer, I want to use a high-contrast, touch-optimized 'McDonalds-style' kiosk interface so that I can easily browse products and place my order with minimal friction and a premium feel.

**Why this priority**: This is the core requirement. The visual and interactive transformation is the primary value of this feature.

**Independent Test**: Can be tested by launching the app and navigating through the entire ordering flow (Landing -> Menu -> Customize -> Cart) using only the new 'Kiosk' interface.

**Acceptance Scenarios**:

1. **Given** the customer is on the Landing Page, **When** they tap "START ORDER", **Then** they should see a horizontal or vertical category bar and a grid of large, high-quality product images.
2. **Given** the customer is on the Menu Page, **When** they tap a product, **Then** a smooth, aesthetic customization sheet should slide up with large selection buttons.
3. **Given** the customer has added items to the cart, **When** they view the cart summary, **Then** the UI should remain simple and uncluttered, using the 'yellowish' brand color for primary actions like "Place Order".

---

### User Story 2 - Smooth Aesthetic Transitions (Priority: P2)

As a customer, I want the UI to feel "smooth" and "alive" via micro-animations and fluid transitions so that the experience feels premium and responsive.

**Why this priority**: Enhances the "premium" feel requested by the user ("smooth, simple and aesthetic").

**Independent Test**: Can be tested by observing the framerate and fluidness of page transitions and button hover/tap effects.

**Acceptance Scenarios**:

1. **Given** any interactive element (button, card), **When** tapped, **Then** there should be a visible, smooth feedback animation (e.g., scale-down, ripple, or subtle color shift).
2. **Given** navigating between menu categories, **When** a new category is selected, **Then** the product grid should update with a smooth fade or slide transition.

---

### User Story 3 - Brand-Aligned Visual Identity (Priority: P3)

As a business owner, I want the application to use a 'yellowish' color theme matching my brand logo so that the app feels consistent with my other digital properties.

**Why this priority**: Specifically requested for branding consistency.

**Independent Test**: Compare the UI primary color with the reference 'yellowish' brand color (Default: #FFBC0D).

**Acceptance Scenarios**:

1. **Given** the app is running, **When** viewing the primary action buttons, headers, and highlights, **Then** they should be rendered in the specific 'yellowish' brand color.
2. **Given** the background of pages, **When** rendering, **Then** it should use a 'Cream' or light 'Yellow' off-white to maintain the warm brand aesthetic.

### Edge Cases

- **Large Menu Handling**: How does the system handle categories with many items (e.g., 20+ burgers)? (Requirement: Vertical scroll inside the grid while keeping the category bar fixed).
- **Network Latency**: How does the UI look while food images are loading? (Requirement: Show a shimmering yellowish placeholder or a generic food icon).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST implement a primary color theme shift to #FFBC0D (Confirmed McDonald's Yellow).
- **FR-002**: System MUST replace the current list-based layout with a 'Kiosk' style grid and a persistent **Vertical Sidebar (Left)** for category navigation.
- **FR-003**: System MUST implement a new **"Tap to Start" Splash Screen** with a prominent "Order Here" button and "Eat In / Take Out" selection.
- **FR-004**: System MUST use 'Inter' or a modern sans-serif font for better readability in a kiosk context.
- **FR-005**: System MUST include a persistent or easily toggleable 'Order Summary' bar showing total price and item count.
- **FR-006**: System MUST implement 'Glassmorphism' or 'Card-based' design for product entries to ensure a premium look.
- **FR-007**: System MUST open a **Detail/Customization Modal** when a product grid card is tapped, instead of adding instantly to the cart.
- **FR-008**: System MUST implement a **Visual Order Summary Grid** in the cart/checkout view, displaying product images and large quantity controls.

## Clarifications

### Session 2026-04-19
- Q: Specific yellowish color hex code for branding → A: #FFBC0D (Option A).
- Q: Navigation layout placement → A: Vertical Sidebar on the Left (Option A).
- Q: Start screen behavior → A: New "Tap to Start" Splash Screen with Eat In/Take Out (Option A).
- Q: Item selection interaction → A: Open Detail/Customization Modal (Option A).
- Q: Cart/Checkout summary layout → A: Visual Order Summary Grid (Option A).

### Key Entities *(include if feature involves data)*

- **MenuTheme**: Represents the stylistic configuration of the kiosk (colors, fonts, animation durations).
- **ProductCard**: The visual container for a MenuItem, including its image, price badge, and 'Add' button.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Page transitions (e.g., Landing to Menu) MUST complete within 400ms with no jarring jumps.
- **SC-002**: All primary action buttons (Add to Cart, Checkout) MUST meet a minimum touch target size of 56x56 logical pixels.
- **SC-003**: UI MUST maintain a 4.5:1 contrast ratio for all primary text against the yellowish background/buttons for accessibility.

## Assumptions

- The existing `kMenuSections` and `CartItem` models are sufficient for the new UI.
- The 'yellowish' color is a vibrant shade (e.g., #FFBC0D) rather than a pale gold.
- 'Smooth' implies the use of Flutter's `Hero` animations for product details and `AnimatedSwitcher` for category changes.
- The "website logo" exists but is currently inaccessible for sampling, so a standard premium yellow will be used as a placeholder/default.
