"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSalesAnalytics = exports.updateOrderStatus = exports.getActiveOrders = exports.sendOrderNotification = exports.verifyStaff = exports.triggerManualReport = exports.dailySalesReport = exports.telegramChatIds = exports.telegramToken = void 0;
const app_1 = require("firebase-admin/app");
const params_1 = require("firebase-functions/params");
(0, app_1.initializeApp)();
// Define params at the entry point for faster discovery
exports.telegramToken = (0, params_1.defineString)('TELEGRAM_TOKEN');
exports.telegramChatIds = (0, params_1.defineString)('TELEGRAM_CHAT_ID');
var daily_report_1 = require("./reporting/daily_report");
Object.defineProperty(exports, "dailySalesReport", { enumerable: true, get: function () { return daily_report_1.dailySalesReport; } });
var manual_report_1 = require("./reporting/manual_report");
Object.defineProperty(exports, "triggerManualReport", { enumerable: true, get: function () { return manual_report_1.triggerManualReport; } });
var verify_staff_1 = require("./auth/verify_staff");
Object.defineProperty(exports, "verifyStaff", { enumerable: true, get: function () { return verify_staff_1.verifyStaff; } });
var send_notification_1 = require("./orders/send_notification");
Object.defineProperty(exports, "sendOrderNotification", { enumerable: true, get: function () { return send_notification_1.sendOrderNotification; } });
var kds_1 = require("./orders/kds");
Object.defineProperty(exports, "getActiveOrders", { enumerable: true, get: function () { return kds_1.getActiveOrders; } });
Object.defineProperty(exports, "updateOrderStatus", { enumerable: true, get: function () { return kds_1.updateOrderStatus; } });
var analytics_1 = require("./reporting/analytics");
Object.defineProperty(exports, "getSalesAnalytics", { enumerable: true, get: function () { return analytics_1.getSalesAnalytics; } });
//# sourceMappingURL=index.js.map