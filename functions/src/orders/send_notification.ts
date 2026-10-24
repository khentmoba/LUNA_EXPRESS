import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import { sendToAll, escapeMd } from '../telegram_api';
import { telegramToken, telegramChatIds } from '../index';
import { logger } from 'firebase-functions';
import { cleanStr, optStr, cleanInt } from '../util/security';

const ORDER_TYPES = ['Walk-In', 'Pickup', 'Delivery'];
const MAX_ITEMS = 50;
const DOC_ID = /^[A-Za-z0-9]{1,64}$/;

/** Records notification outcome on the order. Never fails the request. */
async function markNotified(orderDocId: string | null, sent: boolean) {
  if (!orderDocId) return;
  try {
    await getFirestore().collection('orders').doc(orderDocId)
      .set({ telegramSent: sent }, { merge: true });
  } catch (error: any) {
    logger.warn(`Could not record notification status for ${orderDocId}`, error);
  }
}

export const itemLines = (items: any[]): string =>
  items
    .map((i: any) => {
      const variantText = i.variant?.length > 0 ? ` \\(${escapeMd(i.variant)}\\)` : '';
      return `  • ${i.quantity}x ${escapeMd(i.name)}${variantText} — ₱${escapeMd((i.price * i.quantity).toString())}`;
    })
    .join('\n');

export interface OrderNotificationData {
  orderNumber: string;
  customerName: string;
  customerAddress?: string;
  customerPhone?: string;
  items: Array<{ name: string; variant?: string; price: number; quantity: number }>;
  total: number;
  timeStr?: string;
  orderType: string;
  deliveryFee?: number;
  paymentMethod?: string;
  paymentStatus?: string;
  lat?: number | null;
  lng?: number | null;
}

export function formatOrderNotification(data: OrderNotificationData): string {
  const isWalkIn = data.orderType === 'Walk-In';
  const isPickup = data.orderType === 'Pickup';
  const lines = itemLines(data.items);

  return isWalkIn
    ? [
      `🔔 *WALK\\-IN ORDER — ${escapeMd(data.orderNumber)}*`,
      `🏪 *Type:* Walk\\-In  \\[STAFF ENTRY\\]`,
      '',
      `👤 *Name:* ${escapeMd(data.customerName)}`,
      `📞 *Phone:* ${escapeMd(data.customerPhone || '')}`,
      '',
      `🛒 *Items:*`,
      lines,
      '',
      `💳 *Payment:* ${escapeMd(data.paymentMethod || 'Cash')}  \\-  ✅ *${escapeMd(data.paymentStatus || 'PAID')}*`,
      '',
      `💰 *TOTAL:* ₱*${escapeMd(data.total.toString())}*`,
      `🕐 *Time:* ${escapeMd(data.timeStr || '')}`,
      '',
      `✅ _Walk\\-in complete — paid at POS\\._`
    ].join('\n')
    : [
      `🔔 *NEW ORDER — ${escapeMd(data.orderNumber)}*`,
      `${isPickup ? '🏪' : '🛵'} *Type:* ${escapeMd(data.orderType || '')}`,
      '',
      `👤 *Name:* ${escapeMd(data.customerName)}`,
      ...(isPickup ? [] : [`📍 *Address:* ${escapeMd(data.customerAddress || '')}`]),
      ...(!isPickup && data.lat != null && data.lng != null
        ? [`🗺 [View on Google Maps](https://www.google.com/maps?q=${data.lat},${data.lng})`]
        : []),
      `📞 *Phone:* ${escapeMd(data.customerPhone || '')}`,
      '',
      `🛒 *Items:*`,
      lines,
      '',
      ...(isPickup ? [] : ['🚚 *Delivery Fee:* Confirmed by rider; charged separately']),
      `💳 *Payment Method:* ${escapeMd(data.paymentMethod || 'Cash')}`,
      `📝 *Payment Status:* ${escapeMd(data.paymentStatus || 'NOT PAID')}${data.paymentStatus === 'AWAITING_PAYMENT' ? ' \\(GCash\\)' : ''}`,
      '',
      `💰 *${isPickup ? 'TOTAL' : 'FOOD TOTAL'}:* ₱*${escapeMd(data.total.toString())}*`,
      `🕐 *Time:* ${escapeMd(data.timeStr || '')}`,
      '',
      `✅ _Please prepare this order\\!_`
    ].join('\n');
}

// Public kiosk endpoint: strict validation + sanitization instead of auth (#14).
export const sendOrderNotification = onCall(
  { secrets: [telegramToken, telegramChatIds] }, // #1: secrets server-side only
  async (request) => {
    const d = request.data || {};
    const orderDocId =
      typeof d.orderDocId === 'string' && DOC_ID.test(d.orderDocId) ? d.orderDocId : null;
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

    const message = formatOrderNotification({
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
      lng,
    });

    logger.info(`Sending order notification for ${orderNumber} to Telegram`);
    try {
      await sendToAll(message);
      await markNotified(orderDocId, true);
      return { success: true };
    } catch (error: any) {
      await markNotified(orderDocId, false);
      logger.error(`Error sending Telegram notification for ${orderNumber}`, error);
      throw new HttpsError('internal', 'Failed to send Telegram notification');
    }
  });
