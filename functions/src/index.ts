import { initializeApp } from 'firebase-admin/app';
import { defineString } from 'firebase-functions/params';

initializeApp();

// Define params at the entry point for faster discovery
export const telegramToken = defineString('TELEGRAM_TOKEN');
export const telegramChatIds = defineString('TELEGRAM_CHAT_ID');

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

