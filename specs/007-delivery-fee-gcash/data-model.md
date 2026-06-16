# Data Model: Delivery & Payment Updates

## OrderModel (Updated)

| Field | Type | Description |
| :--- | :--- | :--- |
| `deliveryFee` | `int` | Fee in Pesos based on distance. |
| `totalDistance` | `double` | Distance in KM for audit purposes. |
| `paymentMethod` | `String` | 'Cash' or 'GCash'. |
| `paymentStatus` | `String` | 'NOT PAID' (Cash) or 'PENDING VERIFICATION' (GCash). |

## StoreLocation (Config)

- `lat`: 9.0205090
- `lng`: 125.5175910
