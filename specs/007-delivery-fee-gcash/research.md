# Research: Delivery Fee & GCash Integration

## Decisions

### Distance Calculation
- **Decision**: Use the Haversine formula implemented in Dart.
- **Rationale**: Straight-line distance is computationally simple, cost-free (no Google Maps API requirement), and sufficient for the defined business rule (₱39/km).
- **Alternatives Considered**: Google Distance Matrix API (rejected due to cost/complexity).

### GCash Integration
- **Decision**: Manual instruction flow.
- **Rationale**: Rapid deployment without requiring complex payment aggregation accounts. Users scan or pay to a static number and the order is marked "PENDING VERIFICATION".
- **Alternatives Considered**: Xendit/PayMongo integration (rejected as out of scope for MVP).

### 10km Radius Enforcement
- **Decision**: Hard limit in the frontend `CheckoutPage`.
- **Rationale**: Prevents users from placing orders the store cannot fulfill and protects delivery staff from excessive travel.

## Dependencies Research

| Package | Purpose | Verification |
| :--- | :--- | :--- |
| `latlong2` | Coordinate math | Already used in `main.dart`. |
| `geolocator` | User location | Already used in `main.dart`. |
| `http` | API Calls | Already used for Telegram. |
