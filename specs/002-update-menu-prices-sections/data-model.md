# Data Model: Menu Item Extensions

## New Items (Oreo Craze)

All items are added to the `extras` section of `kMenuSections`.

| ID | Name | Price | Category | Display Name |
|----|------|-------|----------|--------------|
| e3 | Cookies & Cream Overload | 65 | Extras | Cookies & Cream Overload (Large) |
| e4 | Chocolate Oreo | 65 | Extras | Chocolate Oreo (Large) |
| e5 | Strawberry Oreo | 65 | Extras | Strawberry Oreo (Large) |
| e6 | Milo Oreo Float | 65 | Extras | Milo Oreo Float (Large) |

## Updated Items (Shawarma)

| ID | Name | Old Price | New Price |
|----|------|-----------|-----------|
| s1 | Shawarma Wrap | 50 | 60 |
| s7 | Shawarma Quesadilla | 50 | 75 |

## Label Normalization

All instances of labels containing `B1T1` or `Buy1 Take1` will be normalized to `Buy 1 Take 1`.
