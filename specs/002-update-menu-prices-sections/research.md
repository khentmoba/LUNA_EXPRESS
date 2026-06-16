# Research: Menu Updates

## Findings

### 1. B1T1 and Variants
Found "B1T1" at the following lines in `lib/main.dart`:
- **Line 874**: UI Label in `_ProductCard`.
- **Line 954**: UI Label in `_VariantRow`.
Found "Buy1 Take1" (no space) at:
- **Line 564**: `variants` in `fries`.
- **Line 570, 571, 572, 573**: `variants` in `burgers`.
- **Line 579**: `variants` in `hotdog`.

**Decision**: Perform a search-and-replace for these literals to "Buy 1 Take 1".

### 2. Redundant Categories
- **Burgers** (id: 'burgers', title: 'Burgers'): Lines 566-575.
- **Hotdog Bun** (id: 'hotdog', title: 'Hotdog Bun'): Lines 576-580.
- **Burger & Hotdog Sandwich** (id: 'burger_hotdog_combined'): Lines 595-612.

**Decision**: Remove the `burgers` (566-575) and `hotdog` (576-580) sections from the `kMenuSections` list.

### 3. Shawarma Price Updates
- **Shawarma Wrap** (id: 's1'): Currently 50 (Line 551). Update to 60.
- **Shawarma Quesadilla** (id: 's7'): Currently 50 (Line 557). Update to 75.

### 4. Oreo Craze Extras
New items to add to the end of the `extras` section items list (around Line 594):
- id: 'e3', name: 'Cookies & Cream Overload (Large)', price: 65.
- id: 'e4', name: 'Chocolate Oreo (Large)', price: 65.
- id: 'e5', name: 'Strawberry Oreo (Large)', price: 65.
- id: 'e6', name: 'Milo Oreo Float (Large)', price: 65.

**Decision**: Append these 4 items to the `extras` section with a sub-header or grouping in the description/UI if possible.
