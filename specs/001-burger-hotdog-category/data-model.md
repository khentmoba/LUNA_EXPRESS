# Data Model: Burger & Hotdog Category

## New Menu Section: `burger_hotdog_combined`

| Field | Value |
|-------|-------|
| id | `burger_hotdog_combined` |
| title | `Burger & Hotdog Sandwich` |
| emoji | `🍔🌭` |

### Items & Variants

#### Item: `bh1` (Burger & Hotdog Combos)
- **Description**: All items are Buy 1 Take 1! Choose your favorite combination.
- **Variants**:

| Variant Label | Price (PHP) | isBuy1Take1 |
|---------------|-------------|-------------|
| Burger Patty | 55 | true |
| Ham & Cheese | 55 | true |
| Cheese Burger | 65 | true |
| Burger with Egg | 85 | true |
| Egg & Cheese | 95 | true |
| Hotdog Sandwich | 69 | true |

## Validation Rules
- **Quantity**: Each selection results in 2 units of the same item.
- **Customizations**: Any add-ons (Extra Cheese, etc.) apply to both units for a single fee.
- **Ordering**: No maximum limit on the number of deals per order.
