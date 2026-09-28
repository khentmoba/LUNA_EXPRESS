"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendOrderNotification = void 0;
const https_1 = require("firebase-functions/v2/https");
const telegram_api_1 = require("../telegram_api");
const index_1 = require("../index");
const firebase_functions_1 = require("firebase-functions");
const security_1 = require("../util/security");
const ORDER_TYPES = ['Walk-In', 'Pickup', 'Delivery'];
const MAX_ITEMS = 50;
const itemLines = (items) => items
    .map((i) => {
    const variantText = i.variant?.length > 0 ? ` \(${(0, telegram_api_1.escapeMd)(i.variant)}\)` : '';
    return `  • ${i.quantity}x ${(0, telegram_api_1.escapeMd)(i.name)}${variantText} — ₱${(0, telegram_api_1.escapeMd)((i.price * i.quantity).toString())}`;
})
    .join('\n');
// Public kiosk endpoint: strict validation + sanitization instead of auth (#14).
exports.sendOrderNotification = (0, https_1.onCall)({ secrets: [index_1.telegramToken, index_1.telegramChatIds] }, // #1: secrets server-side only
async (request) => {
    const d = request.data || {};
    const orderNumber = (0, security_1.cleanStr)(d.orderNumber, 32, 'orderNumber');
    const customerName = (0, security_1.cleanStr)(d.customerName, 100, 'customerName');
    const customerAddress = (0, security_1.optStr)(d.customerAddress);
    const customerPhone = (0, security_1.optStr)(d.customerPhone, 32);
    const total = (0, security_1.cleanInt)(d.total, 1000000, 'total');
    const timeStr = (0, security_1.optStr)(d.timeStr, 64);
    const orderType = ORDER_TYPES.includes(d.orderType) ? d.orderType : 'Pickup'; // #8
    const deliveryFee = (0, security_1.cleanInt)(d.deliveryFee ?? 0, 5000, 'deliveryFee');
    const paymentMethod = (0, security_1.optStr)(d.paymentMethod, 32);
    const paymentStatus = (0, security_1.optStr)(d.paymentStatus, 32);
    if (!Array.isArray(d.items) || d.items.length === 0 || d.items.length > MAX_ITEMS) {
        throw new https_1.HttpsError('invalid-argument', 'Invalid items');
    }
    const items = d.items.map((i) => ({
        name: (0, security_1.cleanStr)(i?.name, 120, 'item name'),
        variant: (0, security_1.optStr)(i?.variant, 120),
        price: (0, security_1.cleanInt)(i?.price, 100000, 'item price'),
        quantity: (0, security_1.cleanInt)(i?.quantity ?? 1, 99, 'item quantity') || 1,
    }));
    // Coordinates must be real numbers or omitted (no string injection into map URL).
    const lat = (typeof d.lat === 'number' && Math.abs(d.lat) <= 90) ? d.lat : null;
    const lng = (typeof d.lng === 'number' && Math.abs(d.lng) <= 180) ? d.lng : null;
    const isWalkIn = orderType === 'Walk-In';
    const isPickup = orderType === 'Pickup';
    const lines = itemLines(items);
    const message = isWalkIn
        ? [
            `🔔 *WALK\\-IN ORDER — ${(0, telegram_api_1.escapeMd)(orderNumber)}*`,
            `🏪 *Type:* Walk\\-In  \\[STAFF ENTRY\\]`,
            '',
            `👤 *Name:* ${(0, telegram_api_1.escapeMd)(customerName)}`,
            `📞 *Phone:* ${(0, telegram_api_1.escapeMd)(customerPhone || '')}`,
            '',
            `🛒 *Items:*`,
            lines,
            '',
            `💳 *Payment:* ${(0, telegram_api_1.escapeMd)(paymentMethod || 'Cash')}  \\-  ✅ *${(0, telegram_api_1.escapeMd)(paymentStatus || 'PAID')}*`,
            '',
            `💰 *TOTAL:* ₱*${(0, telegram_api_1.escapeMd)(total.toString())}*`,
            `🕐 *Time:* ${(0, telegram_api_1.escapeMd)(timeStr || '')}`,
            '',
            `✅ _Walk\\-in complete — paid at POS\\._`
        ].join('\n')
        : [
            `🔔 *NEW ORDER — ${(0, telegram_api_1.escapeMd)(orderNumber)}*`,
            `${isPickup ? '🏪' : '🛵'} *Type:* ${(0, telegram_api_1.escapeMd)(orderType || '')}`,
            '',
            `👤 *Name:* ${(0, telegram_api_1.escapeMd)(customerName)}`,
            ...(isPickup ? [] : [`📍 *Address:* ${(0, telegram_api_1.escapeMd)(customerAddress || '')}`]),
            ...(!isPickup && lat != null && lng != null
                ? [`🗺 [View on Google Maps](https://www.google.com/maps?q=${lat},${lng})`]
                : []),
            `📞 *Phone:* ${(0, telegram_api_1.escapeMd)(customerPhone || '')}`,
            '',
            `🛒 *Items:*`,
            lines,
            '',
            `🚚 *Delivery Fee:* ₱${(0, telegram_api_1.escapeMd)((deliveryFee || 0).toString())}`,
            `💳 *Payment Method:* ${(0, telegram_api_1.escapeMd)(paymentMethod || 'Cash')}`,
            `📝 *Payment Status:* ${(0, telegram_api_1.escapeMd)(paymentStatus || 'NOT PAID')}${paymentStatus === 'AWAITING_PAYMENT' ? ' \\(GCash\\)' : ''}`,
            '',
            `💰 *TOTAL:* ₱*${(0, telegram_api_1.escapeMd)(total.toString())}*`,
            `🕐 *Time:* ${(0, telegram_api_1.escapeMd)(timeStr || '')}`,
            '',
            `✅ _Please prepare this order\\!_`
        ].join('\n');
    firebase_functions_1.logger.info(`Sending order notification for ${orderNumber} to Telegram`);
    try {
        await (0, telegram_api_1.sendToAll)(message);
        return { success: true };
    }
    catch (error) {
        firebase_functions_1.logger.error(`Error sending Telegram notification for ${orderNumber}`, error);
        throw new https_1.HttpsError('internal', 'Failed to send Telegram notification');
    }
});
//# sourceMappingURL=send_notification.js.map