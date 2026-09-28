import { onCall } from 'firebase-functions/v2/https';
import { aggregateDailySales, salesReportMessage } from './aggregator';
import { sendToAll } from '../telegram_api';
import { phtDateLabel } from '../util';
import { logger } from 'firebase-functions';

export const triggerManualReport = onCall(async () => {
  logger.info("Manual report triggered");
  try {
    const dateLabel = phtDateLabel();
    logger.info(`Aggregating sales for ${dateLabel}`);
    const report = await aggregateDailySales(dateLabel);

    if (!report) {
      logger.info("No orders found for today");
      return { success: false, message: "No orders found for today" };
    }

    logger.info("Sending report to Telegram");
    await sendToAll(salesReportMessage(report, {
      title: 'Manual Sales Report',
      subtitle: '_\\(Triggered by Staff\\)_',
    }));

    return { success: true, message: "SUCCESS" };
  } catch (error: any) {
    logger.error("Error in triggerManualReport", error);
    return { success: false, message: error?.message || "Internal server error" };
  }
});
