"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.dailySalesReport = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const aggregator_1 = require("./aggregator");
const telegram_api_1 = require("../telegram_api");
const firebase_functions_1 = require("firebase-functions");
exports.dailySalesReport = (0, scheduler_1.onSchedule)({
    schedule: '0 22 * * *', // 10 PM
    timeZone: 'Asia/Manila',
    memory: '256MiB',
}, async (event) => {
    // Get date for PHT (today)
    const now = new Date();
    const phtDate = new Date(now.getTime() + (8 * 60 * 60 * 1000));
    const dateLabel = `${phtDate.getUTCFullYear()}-${(phtDate.getUTCMonth() + 1).toString().padStart(2, '0')}-${phtDate.getUTCDate().toString().padStart(2, '0')}`;
    firebase_functions_1.logger.info(`Running daily report for ${dateLabel}`);
    const report = await (0, aggregator_1.aggregateDailySales)(dateLabel);
    if (!report) {
        const noOrdersMsg = `📊 *Daily Sales Report \u2014 ${(0, telegram_api_1.escapeMd)(dateLabel)}*\n\n_No orders recorded today\\._`;
        await (0, telegram_api_1.sendToAll)(noOrdersMsg);
        return;
    }
    const itemsList = report.topItems
        .slice(0, 10)
        .map(i => `  \u2022 ${(0, telegram_api_1.escapeMd)(i.name)}: *${i.qty}*`)
        .join('\n');
    const message = [
        `📊 *Daily Sales Report \u2014 ${(0, telegram_api_1.escapeMd)(report.date)}*`,
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
        '',
        `✅ _All records persisted to Firestore_`
    ].join('\n');
    await (0, telegram_api_1.sendToAll)(message);
});
//# sourceMappingURL=daily_report.js.map