# Quickstart: Staff Mode & Reporting Setup

## 1. Telegram Side
1. Open [@BotFather](https://t.me/botfather) and create a new bot (e.g., `LunaExpressReportBot`).
2. Copy the **Bot Token**.
3. Create a Telegram Group with the owner/staff.
4. Add the bot to the group.
5. Get the **Chat ID** of the group (using a bot like `@raw_data_bot` or checking the URL in Telegram Web).

## 2. Firebase Side (Functions)
1. Ensure you have the Firebase CLI installed (`npm install -g firebase-tools`).
2. Login: `firebase login`.
3. Initialize Functions in the project root: `firebase init functions`.
   - Projects: Select `luna-express-kiosk`.
   - Language: `TypeScript` or `JavaScript`.
4. Install dependency: `npm install node-telegram-bot-api` inside the `functions` directory.
5. Configure secrets:
   ```bash
   firebase functions:secrets:set TELEGRAM_TOKEN
   ```
6. Deploy: `firebase deploy --only functions`.

## 3. Flutter Side
1. Enter the triple-tap gesture on the Kiosk Landing Page (Bottom-Right corner).
2. The UI will indicate "Staff Mode" is active.
3. Perform a test order; verify it appears in Firestore with `entryType: "Staff"`.
4. Use the "Staff Information" button to trigger a manual report and verify Telegram delivery.
