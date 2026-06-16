"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendOrderNotification = void 0;
const https_1 = require("firebase-functions/v2/https");
const telegram_api_1 = require("../telegram_api");
const firebase_functions_1 = require("firebase-functions");
exports.sendOrderNotification = (0, https_1.onCall)(async (request) => {
    const { orderNumber, customerName, customerAddress, customerPhone, items, total, timeStr, orderType, deliveryFee, paymentMethod, paymentStatus, lat, lng } = request.data;
    if (!orderNumber || !customerName || !items || !total) {
        throw new https_1.HttpsError('invalid-argument', 'Missing required order fields');
    }
    const isPickup = orderType === 'Pickup';
    const typeEmoji = isPickup ? '🏪' : '🛵';
    const addressLine = isPickup ? '' : `📍 *Address:* ${(0, telegram_api_1.escapeMd)(customerAddress || '')}\n`;
    // Create map link if coordinates are available
    const mapLink = (!isPickup && lat != null && lng != null)
        ? `🗺 [View on Google Maps](https://www.google.com/maps?q=${lat},${lng})\n`
        : '';
    // Form items list lines
    const itemLines = items
        .map((i) => {
        const variantText = i.variant && i.variant.length > 0 ? ` (${(0, telegram_api_1.escapeMd)(i.variant)})` : '';
        return `  \u2022 ${i.quantity}x ${(0, telegram_api_1.escapeMd)(i.name)}${variantText} \u2014 \u20B1${(0, telegram_api_1.escapeMd)((i.price * i.quantity).toString())}`;
    })
        .join('\n');
    const message = [
        `🔔 *NEW ORDER \u2014 ${(0, telegram_api_1.escapeMd)(orderNumber)}*`,
        `${typeEmoji} *Type:* ${(0, telegram_api_1.escapeMd)(orderType || '')}`,
        '',
        `👤 *Name:* ${(0, telegram_api_1.escapeMd)(customerName)}`,
        `${addressLine}${mapLink}📞 *Phone:* ${(0, telegram_api_1.escapeMd)(customerPhone || '')}`,
        '',
        `🛒 *Items:*`,
        itemLines,
        '',
        `🚚 *Delivery Fee:* \u20B1${(0, telegram_api_1.escapeMd)((deliveryFee || 0).toString())}`,
        `💳 *Payment Method:* ${(0, telegram_api_1.escapeMd)(paymentMethod || 'Cash')}`,
        `📝 *Payment Status:* ${(0, telegram_api_1.escapeMd)(paymentStatus || 'NOT PAID')}`,
        '',
        `💰 *TOTAL:* \u20B1*${(0, telegram_api_1.escapeMd)(total.toString())}*`,
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
        return { success: false, error: error?.message || 'Failed to send message' };
    }
});
//# sourceMappingURL=send_notification.js.map