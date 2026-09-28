import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { sendToAll, escapeMd } from '../telegram_api';
import { telegramToken, telegramChatIds } from '../index';
import { logger } from 'firebase-functions';
import { cleanStr, optStr, cleanInt } from '../util/security';

const ORDER_TYPES = ['Walk-In', 'Pickup', 'Delivery'];
const MAX_ITEMS = 50;

const itemLines = (items: any[]): string =>
  items
    .map((i: any) => {
      const variantText = i.variant?.length > 0 ? ` \(${escapeMd(i.variant)}\)` : '';
      return `  • ${i.quantity}x ${escapeMd(i.name)}${variantText} — ₱${escapeMd((i.price * i.quantity).toString())}`;
    })
    .join('\n');

// Public kiosk endpoint: strict validation + sanitization instead of auth (#14).
export const sendOrderNotification = onCall(
  { secrets: [telegramToken, telegramChatIds] }, // #1: secrets server-side only
  async (request) => {
    const d = request.data || {};
    const orderNumber = cleanStr(d.orderNumber, 32, 'orderNumber');
    const customerName = cleanStr(d.customerName, 100, 'customerName');
    const customerAddress = optStr(d.customerAddress);
    const customerPhone = optStr(d.customerPhone, 32);
    const total = cleanInt(d.total, 1000000, 'total');
    const timeStr = optStr(d.timeStr, 64);
    const orderType = ORDER_TYPES.includes(d.orderType) ? d.orderType : 'Pickup'; // #8
    const deliveryFee = cleanInt(d.deliveryFee ?? 0, 5000, 'deliveryFee');
    const paymentMethod = optStr(d.paymentMethod, 32);
    const paymentStatus = optStr(d.paymentStatus, 32);

    if (!Array.isArray(d.items) || d.items.length === 0 || d.items.length > MAX_ITEMS) {
      throw new HttpsError('invalid-argument', 'Invalid items');
    }
    const items = d.items.map((i: any) => ({
      name: cleanStr(i?.name, 120, 'item name'),
      variant: optStr(i?.variant, 120),
      price: cleanInt(i?.price, 100000, 'item price'),
      quantity: cleanInt(i?.quantity ?? 1, 99, 'item quantity') || 1,
    }));

    // Coordinates must be real numbers or omitted (no string injection into map URL).
    const lat = (typeof d.lat === 'number' && Math.abs(d.lat) <= 90) ? d.lat : null;
    const lng = (typeof d.lng === 'number' && Math.abs(d.lng) <= 180) ? d.lng : null;

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
      throw new HttpsError('internal', 'Failed to send Telegram notification');
    }
  });
