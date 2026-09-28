import { initializeApp } from 'firebase-admin/app';
import { defineSecret } from 'firebase-functions/params';

initializeApp();

// Secrets (NOT params): values stay out of config/logs. Set via:
//   firebase functions:secrets:set TELEGRAM_TOKEN
//   firebase functions:secrets:set TELEGRAM_CHAT_ID
//   firebase functions:secrets:set PAYMONGO_SECRET_KEY
export const telegramToken = defineSecret('TELEGRAM_TOKEN');
export const telegramChatIds = defineSecret('TELEGRAM_CHAT_ID');
export const paymongoSecret = defineSecret('PAYMONGO_SECRET_KEY');

export { dailySalesReport } from './reporting/daily_report';
export { triggerManualReport } from './reporting/manual_report';
export { verifyStaff } from './auth/verify_staff';
export { manageRiderStatus } from './auth/manage_rider_status';
export { sendOrderNotification } from './orders/send_notification';
export { getActiveOrders, updateOrderStatus } from './orders/kds';
export { getSalesAnalytics } from './reporting/analytics';
export { getLifetimeSalesReport } from './reporting/lifetime_report';
export { createCheckoutSession } from './payments/create_checkout';
export { paymongoWebhook } from './payments/webhook';
