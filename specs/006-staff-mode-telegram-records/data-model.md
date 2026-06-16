# Data Model: Staff Mode and Telegram Reporting

## Entity: Order
Represents a completed transaction, whether from a customer at the kiosk or entered by staff.

**Storage**: Cloud Firestore (`orders` collection)

| Field | Type | Description |
| :--- | :--- | :--- |
| `orderId` | String | Unique human-readable ID (e.g., LU-12345) |
| `items` | List<Map> | List of ordered items with name, variant, price, and quantity |
| `totalAmount` | Number | Total transaction value (₱) |
| `timestamp` | Timestamp | Server-side creation time |
| `dateLabel` | String | Date in PHT format (YYYY-MM-DD) for aggregation |
| `type` | String | "Delivery" or "Pickup" |
| `entryType` | String | "Kiosk" (Self-service) or "Staff" (Walk-in) |
| `paymentStatus` | String | Always "Paid" for completed orders |
| `customerName` | String | Optional for Kiosk; "Walk-in" for Staff |
| `customerPhone` | String | Optional for Kiosk; "—" for Staff |

## Summary Logic (Aggregate)
The Telegram report will aggregate `orders` where `dateLabel` matches today's PHT date.

- **Total Sales**: Sum of `totalAmount`.
- **Order Count**: Length of list.
- **Top Product**: Sort items by frequency in map.
