import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { sendToAll, escapeMd } from '../telegram_api';
import { logger } from 'firebase-functions';

const itemLines = (items: any[]): string =>
  items
    .map((i: any) => {
      const variantText = i.variant?.length > 0 ? ` \(${escapeMd(i.variant)}\)` : ''; // single backslashes: matches original output exactly
      return `  • ${i.quantity}x ${escapeMd(i.name)}${variantText} — ₱${escapeMd((i.price * i.quantity).toString())}`;
    })
    .join('\n');

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

  const isWalkIn = orderType === 'Walk-In';
  const isPickup = orderType === 'Pickup';
  const lines = itemLines(items);

  const message = isWalkIn
    ? [
      `🔔 *WALK\\-IN ORDER — ${escapeMd(orderNumber)}*`,
      `🏪 *Type:* Walk\\-In  \\[STAFF ENTRY\\]`,
      '',
      `👤 *Name:* ${escapeMd(customerName)}`,
      `📞 *Phone:* ${escapeMd(customerPhone || '')}`,
      '',
      `🛒 *Items:*`,
      lines,
      '',
      `💳 *Payment:* ${escapeMd(paymentMethod || 'Cash')}  \\-  ✅ *${escapeMd(paymentStatus || 'PAID')}*`,
      '',
      `💰 *TOTAL:* ₱*${escapeMd(total.toString())}*`,
      `🕐 *Time:* ${escapeMd(timeStr || '')}`,
      '',
      `✅ _Walk\\-in complete — paid at POS\\._`
    ].join('\n')
    : [
      `🔔 *NEW ORDER — ${escapeMd(orderNumber)}*`,
      `${isPickup ? '🏪' : '🛵'} *Type:* ${escapeMd(orderType || '')}`,
      '',
      `👤 *Name:* ${escapeMd(customerName)}`,
      ...(isPickup ? [] : [`📍 *Address:* ${escapeMd(customerAddress || '')}`]),
      ...(!isPickup && lat != null && lng != null
        ? [`🗺 [View on Google Maps](https://www.google.com/maps?q=${lat},${lng})`]
        : []),
      `📞 *Phone:* ${escapeMd(customerPhone || '')}`,
      '',
      `🛒 *Items:*`,
      lines,
      '',
      `🚚 *Delivery Fee:* ₱${escapeMd((deliveryFee || 0).toString())}`,
      `💳 *Payment Method:* ${escapeMd(paymentMethod || 'Cash')}`,
      `📝 *Payment Status:* ${escapeMd(paymentStatus || 'NOT PAID')}${paymentStatus === 'AWAITING_PAYMENT' ? ' \\(GCash\\)' : ''}`,
      '',
      `💰 *TOTAL:* ₱*${escapeMd(total.toString())}*`,
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
