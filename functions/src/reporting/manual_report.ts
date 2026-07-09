import { onCall } from 'firebase-functions/v2/https';
import { aggregateDailySales } from './aggregator';
import { sendToAll, escapeMd } from '../telegram_api';
import { logger } from 'firebase-functions';

export const triggerManualReport = onCall(async (request) => {
  logger.info("Manual report triggered");
  try {
    // Get date for PHT (today)
    const now = new Date();
    const phtDate = new Date(now.getTime() + (8 * 60 * 60 * 1000));
    const dateLabel = `${phtDate.getUTCFullYear()}-${(phtDate.getUTCMonth() + 1).toString().padStart(2, '0')}-${phtDate.getUTCDate().toString().padStart(2, '0')}`;
    
    logger.info(`Aggregating sales for ${dateLabel}`);
    const report = await aggregateDailySales(dateLabel);

    if (!report) {
      logger.info("No orders found for today");
      return { 
        success: false, 
        message: "No orders found for today" 
      };
    }

    const itemsList = report.topItems
      .slice(0, 10)
      .map(i => `  \u2022 ${escapeMd(i.name)}: *${i.qty}*`)
      .join('\n');

    const message = [
      `📊 *Manual Sales Report \u2014 ${escapeMd(report.date)}*`,
      `_\\(Triggered by Staff\\)_`,
      '',
      `💰 *Total Sales:* \u20B1*${escapeMd(report.totalSales.toString())}*`,
      `🛒 *Total Orders:* ${report.totalOrders}`,
      '',
      `🏷 *Breakdown:*`,
      `  \u2022 Kiosk Orders: \u20B1${escapeMd(report.kioskSales.toString())}`,
      `  \u2022 Walk\\-in/Staff: \u20B1${escapeMd(report.staffSales.toString())}`,
      '',
      `🔥 *Top Items:*`,
      itemsList,
    ].join('\n');

    logger.info("Sending report to Telegram");
    await sendToAll(message);
    
    return { 
      success: true, 
      message: "SUCCESS" 
    };
  } catch (error: any) {
    logger.error("Error in triggerManualReport", error);
    return { 
      success: false, 
      message: error?.message || "Internal server error" 
    };
  }
});
