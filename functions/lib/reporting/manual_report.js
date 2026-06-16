"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.triggerManualReport = void 0;
const https_1 = require("firebase-functions/v2/https");
const aggregator_1 = require("./aggregator");
const telegram_api_1 = require("../telegram_api");
const firebase_functions_1 = require("firebase-functions");
exports.triggerManualReport = (0, https_1.onCall)(async (request) => {
    firebase_functions_1.logger.info("Manual report triggered");
    try {
        // Get date for PHT (today)
        const now = new Date();
        const phtDate = new Date(now.getTime() + (8 * 60 * 60 * 1000));
        const dateLabel = `${phtDate.getUTCFullYear()}-${(phtDate.getUTCMonth() + 1).toString().padStart(2, '0')}-${phtDate.getUTCDate().toString().padStart(2, '0')}`;
        firebase_functions_1.logger.info(`Aggregating sales for ${dateLabel}`);
        const report = await (0, aggregator_1.aggregateDailySales)(dateLabel);
        if (!report) {
            firebase_functions_1.logger.info("No orders found for today");
            return {
                success: false,
                message: "No orders found for today"
            };
        }
        const itemsList = report.topItems
            .slice(0, 10)
            .map(i => `  \u2022 ${(0, telegram_api_1.escapeMd)(i.name)}: *${i.qty}*`)
            .join('\n');
        const message = [
            `📊 *Manual Sales Report \u2014 ${(0, telegram_api_1.escapeMd)(report.date)}*`,
            `_(Triggered by Staff)_`,
            '',
            `💰 *Total Sales:* \u20B1*${(0, telegram_api_1.escapeMd)(report.totalSales.toString())}*`,
            `🛒 *Total Orders:* ${report.totalOrders}`,
            '',
            `🏷 *Breakdown:*`,
            `  \u2022 Kiosk Orders: \u20B1${(0, telegram_api_1.escapeMd)(report.kioskSales.toString())}`,
            `  \u2022 Walk\\-in/Staff: \u20B1${(0, telegram_api_1.escapeMd)(report.staffSales.toString())}`,
            '',
            `🔥 *Top Items:*`,
            itemsList,
        ].join('\n');
        firebase_functions_1.logger.info("Sending report to Telegram");
        await (0, telegram_api_1.sendToAll)(message);
        return {
            success: true,
            message: "SUCCESS"
        };
    }
    catch (error) {
        firebase_functions_1.logger.error("Error in triggerManualReport", error);
        return {
            success: false,
            message: error?.message || "Internal server error"
        };
    }
});
//# sourceMappingURL=manual_report.js.map