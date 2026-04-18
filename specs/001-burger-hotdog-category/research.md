# Research: Burger & Hotdog Category

## Findings

### Menu Storage & Logic
The menu system is currently hardcoded in `lib/main.dart` within the `kMenuSections` list.
- Each section contains `MenuItem` objects.
- Each item can have `MenuVariant` objects.
- Both `MenuItem` and `MenuVariant` support an `isBuy1Take1` flag.

### Cart System
The `CartNotifier` manages state and calculates totals.
- It doesn't treat B1T1 specially in the calculation (prices in `kMenuSections` are already the "per deal" price).
- It tracks variants as strings.

### B1T1 Fulfillment
- The `isBuy1Take1` flag triggers a "B1T1" badge in the UI.
- The `ProductSheet` shows this badge next to variants.

## Decisions

### 1. Unified Category
- **Decision**: Create a single `MenuSection` titled "Burger & Hotdog Sandwich" to house all the new items.
- **Rationale**: Keeps the menu organized and matches the user's specific request for a "combined" category.

### 2. Implementation Strategy
- **Decision**: Add the new items as variants of a single "Burger & Hotdog Combos" item or as individual items.
- **Rationale**: Individual items allow better image association, but variants are cleaner for "Choose your deal" lists. Given the existing pattern in `burgers` section, I will use a single `MenuItem` with multiple `variants`.

### 3. Price Assumption
- **Decision**: Prices (55, 65, 85, 95, 69) are "Per Deal" prices.
- **Rationale**: Confirmed by the user description "all are buy 1 take 1".

## Alternatives Considered
- **Separate Categories**: Dismissed to follow user request for a combined category.
- **Dynamically Added Items**: Not viable as the current architecture is static.
