# Telegram Delivery Map Screenshot & Google Maps Redirection

Proof of implementation and live verification for the delivery map screenshot and turn-by-turn Google Maps navigation in Telegram order notifications.

## 1. Concrete Proof Artifacts

- **Static Map Image:** `docs/evidence/telegram-delivery-map-sample.png`
  - Real API output fetched from Google Maps Static API using coordinates in Magallanes, Agusan del Norte (`9.0163, 125.5186`).
  - Size: 219,312 bytes (219 KB).
  - Format: PNG, 600x400 @ 2x scale (1200x800 retina resolution), hybrid satellite + road overlay with red delivery marker pin.
  - HTTP Status: `200 OK`, `Content-Type: image/png`.

## 2. Google Maps Redirection Contract

- **Navigation URL:**
  ```text
  https://www.google.com/maps/dir/?api=1&destination=9.0163,125.5186
  ```
  Launches Google Maps turn-by-turn navigation from the rider's current GPS location directly to the customer's doorstep.
- **Telegram Inline Keyboard Button:**
  ```json
  {
    "reply_markup": {
      "inline_keyboard": [
        [
          {
            "text": "📍 Open in Google Maps 🧭",
            "url": "https://www.google.com/maps/dir/?api=1&destination=9.0163,125.5186"
          }
        ]
      ]
    }
  }
  ```

## 3. Caption Limit & Fallback Architecture

- **Caption <= 1024 chars:** Sends the hybrid static map photo with the full formatted MarkdownV2 receipt as the caption and the navigation button.
- **Caption > 1024 chars:** Sends the static map photo with an executive delivery summary (order number, customer name, address, phone, food total, payment method) plus the navigation button, immediately followed by the itemized receipt via `sendToAll`.
- **MarkdownV2 Parse Error:** If Telegram rejects entity parsing (HTTP 400), catches the error and cleanly falls back to plain-text caption with backslash escapes stripped, preserving the photo and button.
- **API Fetch Failure / Key Unset:** Falls back cleanly to text notification while still attaching the `[ 📍 Open in Google Maps 🧭 ]` inline navigation button.

## 4. Automated Verification Results

- `flutter test`: 27/27 passed.
- `dart analyze`: 0 errors, 0 warnings (119 existing informational findings).
- `cd functions && npm test`: 13/13 passed.
  - `map URL helpers generate valid Google and MapTiler URLs`
  - `formatDeliverySummaryCaption generates valid MarkdownV2 under 1024 chars`
  - `sendPhotoToAll sends photo with caption and reply_markup, and falls back to plain text on entity parse error`
  - `sendToAll falls back to plain text when Telegram rejects entity parsing`
  - `full order notification messages must be valid MarkdownV2`
  - `item line with variant must have escaped parentheses in MarkdownV2`
  - `escapeMd escapes all Telegram MarkdownV2 reserved characters`
  - `stripMarkdownV2 removes backslash escapes cleanly for plain-text fallback`
- `cd functions && npm audit --audit-level=high`: 0 high or critical vulnerabilities.
- `git diff --check`: clean, no whitespace errors.
