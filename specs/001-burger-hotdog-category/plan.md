# Implementation Plan: Burger & Hotdog Category

**Branch**: `001-burger-hotdog-category` | **Date**: 2026-04-19 | **Spec**: [spec.md](file:///c:/APPLICATIONS/luna_express/specs/001-burger-hotdog-category/spec.md)
**Input**: Feature specification from `/specs/001-burger-hotdog-category/spec.md`

## Summary

Add a new "Burger & Hotdog Sandwich" category to the mobile/web ordering app. This category features "Buy 1 Take 1" (B1T1) deals for burgers and hotdogs, with specific pricing variants for toppings like egg and cheese. The implementation will follow the existing hardcoded menu pattern in the codebase while ensuring B1T1 logic and labels are correctly applied.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: flutter, firebase_core, http (for Telegram orders)  
**Storage**: Static Menu Data in `lib/main.dart`  
**Testing**: Manual UI verification and Cart logic testing  
**Target Platform**: Web (Flutter), Android, iOS (PWA deployment)
**Project Type**: Mobile/Web Food Ordering Application  
**Performance Goals**: Instant menu navigation and smooth cart updates  
**Constraints**: Must match existing monolithic architecture and Telegram-based fulfillment.  
**Scale/Scope**: 1 new category, 1 new MenuItem with 6 price variants.

## Constitution Check

*GATE: Must pass before Phase 1 design.*

| Principle | Check | Status |
|-----------|-------|--------|
| **User-Centric Ordering** | Do prices clearly indicate B1T1? | ✅ Yes, via `isBuy1Take1: true` flag. |
| **Payment-First** | Does the checkout flow maintain payment priority? | ✅ Yes, existing flow is preserved. |
| **Fulfillment Flexibility** | Can customers choose Delivery/Pickup? | ✅ Yes, supported by `CheckoutPage`. |
| **Data Integrity** | Are prices accurate to the spec? | ✅ Yes, PHP 55, 65, 85, 95, 69. |
| **Spec Kit Compliance** | Is the branch correctly named? | ✅ Yes: `001-burger-hotdog-category`. |

## Project Structure

### Documentation

```text
specs/001-burger-hotdog-category/
├── plan.md              # This file
├── research.md          # Implementation research
├── data-model.md        # Data definitions
├── quickstart.md        # Quick instructions
└── tasks.md             # TODO list (to be generated)
```

### Source Code

```text
lib/
├── firebase_options.dart
└── main.dart            # Monolithic file containing all logic/UI
```

**Structure Decision**: Continue using the existing monolithic structure in `lib/main.dart` to maintain consistency with the current codebase.

## Proposed Changes

### [MODIFY] [main.dart](file:///c:/APPLICATIONS/luna_express/lib/main.dart)

- Append a new `MenuSection` to the `kMenuSections` list.
- Define 6 `MenuVariant` objects for the "Burger & Hotdog" item.
- Ensure `isBuy1Take1` is set to `true` for the item and its variants.

## Verification Plan

### Manual Verification
- **Menu Tab**: Verify tab "🍔🌭 Burger & Hotdog Sandwich" appears.
- **Variant Selection**: Open the item and verify all 6 variants show correct prices and the B1T1 badge.
- **Cart flow**: Add multiple variants and verify the subtotal matches the summed deal prices.
- **Receipt**: Complete a mockup order (in a test chat) to verify Telegram output formatting.
