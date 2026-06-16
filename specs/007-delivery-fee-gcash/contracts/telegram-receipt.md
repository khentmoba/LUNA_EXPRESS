# Telegram Receipt Contract

The order notification sent to staff via Telegram MUST follow this updated schema.

## Template

```text
🔔 *NEW ORDER — [ORDER_ID]*
[TYPE_EMOJI] *Type: [ORDER_TYPE]*

👤 *Name:* [CUSTOMER_NAME]
📍 *Address:* [CUSTOMER_ADDRESS]
🗺 [Map Link if available]
📞 *Phone:* [CUSTOMER_PHONE]

🛒 *Items:*
[ITEM_LIST]

🚚 *Delivery Fee:* ₱[FEE]
💳 *Payment Method:* [CASH | GCash]
📝 *Payment Status:* [NOT PAID | PENDING VERIFICATION]

💰 *TOTAL: ₱[TOTAL]*
🕐 *Time:* [TIMESTAMP]

✅ _Please prepare this order!_
```

## Field Mappings

- `ORDER_ID`: Existing auto-gen ID.
- `FEE`: Calculated `distance * 39`.
- `TOTAL`: `sum(items) + FEE`.
- `PAYMENT_STATUS`: Based on logic below:
  - If Method == 'GCash' -> 'PENDING VERIFICATION'
  - If Method == 'Cash' -> 'NOT PAID'
