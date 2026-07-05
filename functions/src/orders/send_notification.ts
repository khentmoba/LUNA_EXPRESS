import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { sendToAll, escapeMd } from '../telegram_api';
import { logger } from 'firebase-functions';

export const sendOrderNotification = onCall(async (request) => {
  const {
    orderNumber,
    customerName,
    customerAddress,
    customerPhone,
    items,
    total,
    timeStr,
    orderType,
    deliveryFee,
    paymentMethod,
    paymentStatus,
    lat,
    lng
  } = request.data;

  if (!orderNumber || !customerName || !items || !total) {
    throw new HttpsError('invalid-argument', 'Missing required order fields');
  }

  const isPickup = orderType === 'Pickup';
  const typeEmoji = isPickup ? '🏪' : '🛵';
  const addressLine = isPickup ? '' : `📍 *Address:* ${escapeMd(customerAddress || '')}\n`;

  // Create map link if coordinates are available
  const mapLink = (!isPickup && lat != null && lng != null)
    ? `🗺 [View on Google Maps](https://www.google.com/maps?q=${lat},${lng})\n`
    : '';

  // Form items list lines
  const itemLines = items
    .map((i: any) => {
      const variantText = i.variant && i.variant.length > 0 ? ` (${escapeMd(i.variant)})` : '';
      return `  \u2022 ${i.quantity}x ${escapeMd(i.name)}${variantText} \u2014 \u20B1${escapeMd((i.price * i.quantity).toString())}`;
    })
    .join('\n');

  const message = [
    `🔔 *NEW ORDER \u2014 ${escapeMd(orderNumber)}*`,
    `${typeEmoji} *Type:* ${escapeMd(orderType || '')}`,
    '',
    `👤 *Name:* ${escapeMd(customerName)}`,
    `${addressLine}${mapLink}📞 *Phone:* ${escapeMd(customerPhone || '')}`,
    '',
    `🛒 *Items:*`,
    itemLines,
    '',
    `🚚 *Delivery Fee:* \u20B1${escapeMd((deliveryFee || 0).toString())}`,
    `💳 *Payment Method:* ${escapeMd(paymentMethod || 'Cash')}`,
    `📝 *Payment Status:* ${escapeMd(paymentStatus || 'NOT PAID')}${paymentStatus === 'AWAITING_PAYMENT' ? ' (GCash)' : ''}`,
    '',
    `💰 *TOTAL:* \u20B1*${escapeMd(total.toString())}*`,
    `🕐 *Time:* ${escapeMd(timeStr || '')}`,
    '',
    `✅ _Please prepare this order\\!_`
  ].join('\n');

  logger.info(`Sending order notification for ${orderNumber} to Telegram`);
  try {
    await sendToAll(message);
    return { success: true };
  } catch (error: any) {
    logger.error(`Error sending Telegram notification for ${orderNumber}`, error);
    throw new HttpsError('internal', error?.message || 'Failed to send Telegram notification');
  }
});
