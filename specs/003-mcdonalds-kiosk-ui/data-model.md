# UI State & Data Model: McDonalds-Style Kiosk UI

## Entities and State Models

### DiningMode (Enum)
Represents the user's selected consumption method.
- **EAT_IN**: Customer intends to dine at the establishment.
- **TAKE_OUT**: Customer intends to take the food away.

### KioskSession (State Object)
Maintains the active state of the ordering session.
- **currentDiningMode**: `DiningMode?` (Initialized during splash).
- **selectedCategoryId**: `String` (Defaults to first category in `kMenuSections`).
- **isCartSummaryVisible**: `bool`.
- **activeProductDetails**: `MenuItem?` (Controls the visibility and content of the customization modal).

## Interaction Contracts

### Sidebar -> Menu Grid
- **Input**: `CategoryId`.
- **Action**: Update `KioskSession.selectedCategoryId`.
- **Result**: `AnimatedSwitcher` triggers a smooth cross-fade to the new product list.

### Product Card -> Customization Modal
- **Input**: `MenuItem`.
- **Action**: Set `KioskSession.activeProductDetails = item`.
- **Result**: `Hero` animation launches the modal/sheet from the card position.

### Modal -> Cart
- **Input**: `CartItem` (constructed from `MenuItem` + quantity).
- **Action**: `cartNotifier.add(item)`.
- **Result**: Update `Order Summary Bar` with success feedback animation.
