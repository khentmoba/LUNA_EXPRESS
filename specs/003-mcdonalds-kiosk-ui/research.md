# Research Findings: McDonalds-Style Kiosk UI

## Decision: Visual and Interaction Patterns

We will implement a custom Flutter UI system that replicates the core UX of professional food kiosks (McDonald's style).

- **Pattern**: Vertical Category Sidebar + Modular Product Grid.
- **Rationale**: This is the industry-standard layout for high-volume kiosks. It reduces cognitive load by separating category navigation from product exploration.
- **Alternatives Considered**: 
  - *Top Tab Bar*: Rejected because it limits the number of visible categories and feels like a standard mobile app rather than a dedicated terminal.
  - *Infinite Scroll*: Rejected as it lacks the "menu" organization expected in a kiosk.

## Decision: Theming and Brand Color

- **Selected Hex**: `#FFBC0D` (McDonald's Golden Yellow).
- **Rationale**: High visibility, warm aesthetic, and aligns with the user's "yellowish" request.
- **Style**: Material 3 with extensive use of `Card` components and `Hero` animations for smooth transitions.

## Decision: Interaction Model

- **Selection**: 2-Step Interaction (Grid Tap -> Customization Modal -> Add to Cart).
- **Rationale**: Professional kiosks provide a moment of focus (the modal) to allow for upselling, quantity adjustment, and variant selection. This fulfills the "smooth and aesthetic" requirement better than an instant, "jittery" add-to-cart mechanism.

## Decision: Technology Strategy (Flutter)

- **Sidebar**: Custom `Container` with `ListView.builder` for maximum styling control over the "active" state indicators.
- **Animations**: 
  - `Hero` animations for product image transitions between grid and modal.
  - `AnimatedSwitcher` for smooth cross-fading when switching categories.
  - `TweenAnimationBuilder` for the splash screen's "pulse" effect.
- **Grid**: `SliverGrid` within a `CustomScrollView` for high-performance scrolling.
