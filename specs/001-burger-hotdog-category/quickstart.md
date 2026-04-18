# Quickstart: Burger & Hotdog Category

## Feature Preview
This feature adds a new combined "Burger & Hotdog Sandwich" category with 6 "Buy 1 Take 1" deal variants.

## Development Steps
1. **Locate Menu Data**: Open `lib/main.dart` and find the `kMenuSections` list (approx. Line 549).
2. **Add New Section**: Append the new `MenuSection` object to the list.
3. **Verify UI**: Run `flutter run` and check the menu tabs for the new emoji and title.
4. **Test Cart**: Add a "Cheese Burger" deal and verify it shows ₱65 with the "B1T1" label.

## Verification Checklist
- [ ] Tab "🍔🌭 Burger & Hotdog Sandwich" appears.
- [ ] All 6 variants show correct pricing.
- [ ] B1T1 badge is visible on all variants.
- [ ] Adding to cart shows two identical units (logic confirmed in spec).
