# Contract: Daily Sales Report

## Protocol: Telegram MarkdownV2
The system sends automated and on-demand reports via the Telegram Bot API.

### Template: Detailed Summary
```markdown
📊 *LUNA EXPRESS — DAILY SALES REPORT*
📅 *Date:* 2026-04-19 (Philippines Time)

💰 *FINANCIAL SUMMARY*
• Total Revenue: ₱12,450
• Total Orders: 42
• Kiosk Orders: 25
• Staff Walk-ins: 17

🛍️ *TOP SELLING ITEMS*
1. Shawarma Wrap (15)
2. Large Fries (12)
3. Coke Float (8)

🏷️ *TOP CATEGORIES*
1. Shawarma Classics
2. French Fries

✅ _Report generated at 22:00 PHT_
```

## Protocol: Firebase Cloud Functions
- **Scheduled**: `dailyReportCron`
  - Trigger: `every day 22:00` (Asia/Manila)
- **On-Demand**: `triggerManualReport`
  - Type: HTTPS Callable
  - Request: `{ "force": true }`
  - Response: `{ "status": "success", "message": "Report sent to Telegram" }`
