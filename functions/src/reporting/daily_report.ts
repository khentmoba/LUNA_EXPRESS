import { onSchedule } from 'firebase-functions/v2/scheduler';
import { aggregateDailySales } from './aggregator';
import { sendToAll, escapeMd } from '../telegram_api';
import { logger } from 'firebase-functions';

export const dailySalesReport = onSchedule({
  schedule: '0 22 * * *', // 10 PM
  timeZone: 'Asia/Manila',
  memory: '256MiB',
}, async (event) => {
  // Get date for PHT (today)
  const now = new Date();
  const phtDate = new Date(now.getTime() + (8 * 60 * 60 * 1000));
  const dateLabel = `${phtDate.getUTCFullYear()}-${(phtDate.getUTCMonth() + 1).toString().padStart(2, '0')}-${phtDate.getUTCDate().toString().padStart(2, '0')}`;
  
  logger.info(`Running daily report for ${dateLabel}`);
  
  const report = await aggregateDailySales(dateLabel);

  if (!report) {
    await sendToAll(`📊 *Daily Sales Report \u2014 ${escapeMd(dateLabel)}*\n\n_No orders recorded today\\._`);
    return;
  }

  const itemsList = report.topItems
    .slice(0, 10)
    .map(i => `  \u2022 ${escapeMd(i.name)}: *${i.qty}*`)
    .join('\n');

  const message = [
    `📊 *Daily Sales Report \u2014 ${escapeMd(report.date)}*`,
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
    '',
    `✅ _All records persisted to Firestore_`
  ].join('\n');

  await sendToAll(message);
});
