"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.paymongoWebhook = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-admin/firestore");
const firebase_functions_1 = require("firebase-functions");
const telegram_api_1 = require("../telegram_api");
const index_1 = require("../index");
// Trust-but-verify: never mark PAID from the webhook payload alone.
// Re-fetch the checkout session from PayMongo with the secret key (#6/#8).
async function isSessionPaid(sessionId, auth) {
    const res = await fetch(`https://api.paymongo.com/v2/checkout_sessions/${sessionId}`, {
        headers: { Authorization: `Basic ${auth}` },
    });
    if (!res.ok)
        return false;
    const json = await res.json();
    const payments = json?.data?.attributes?.payments || [];
    return payments.some((p) => p?.attributes?.status === 'paid');
}
exports.paymongoWebhook = (0, https_1.onRequest)({ secrets: [index_1.paymongoSecret, index_1.telegramToken, index_1.telegramChatIds] }, async (req, res) => {
    if (req.method !== 'POST') {
        res.status(405).send('Method Not Allowed');
        return;
    }
    if (!req.headers['paymongo-signature']) {
        firebase_functions_1.logger.warn('PayMongo webhook missing signature');
        res.status(200).send('OK');
        return;
    }
    try {
        const event = req.body?.data;
        if (!event?.type || !event?.data?.id) {
            firebase_functions_1.logger.warn('Invalid webhook payload');
            res.status(200).send('OK');
            return;
        }
        firebase_functions_1.logger.info(`PayMongo webhook received: ${event.type}`);
        const sessionId = String(event.data.id);
        if (event.type === 'checkout_session.payment.paid') {
            const auth = Buffer.from(`${index_1.paymongoSecret.value()}:`).toString('base64');
            if (!(await isSessionPaid(sessionId, auth))) {
                firebase_functions_1.logger.warn(`Webhook for ${sessionId} failed API verification — ignored`);
                res.status(200).send('OK');
                return;
            }
            const attrs = event.data.attributes || {};
            const refNumber = attrs.reference_number;
            const paymentId = attrs.payments?.[0]?.id || '';
            if (refNumber && /^[A-Za-z0-9_-]+$/.test(String(refNumber))) {
                const db = (0, firestore_1.getFirestore)();
                await db.collection('orders').doc(refNumber).update({
                    paymentStatus: 'PAID',
                    paymongoPaymentId: String(paymentId).slice(0, 128),
                    paidAt: new Date().toISOString(),
                });
                try {
                    const orderDoc = await db.collection('orders').doc(refNumber).get();
                    if (orderDoc.exists) {
                        const data = orderDoc.data();
                        await (0, telegram_api_1.sendToAll)([
                            `✅ *PAYMENT CONFIRMED*`,
                            `📄 *Order:* ${(0, telegram_api_1.escapeMd)(refNumber)}`,
                            `👤 *Customer:* ${(0, telegram_api_1.escapeMd)(String(data.customerName || ''))}`,
                            `💰 *Amount:* \u20B1${(0, telegram_api_1.escapeMd)(String(data.totalAmount || 0))}`,
                            `💳 *Payment:* GCash via PayMongo`,
                            `📦 *Type:* ${(0, telegram_api_1.escapeMd)(String(data.type || ''))}`,
                            `🕐 *Paid at:* ${new Date().toLocaleString('en-PH')}`,
                        ].join('\n'));
                    }
                }
                catch (notifErr) {
                    firebase_functions_1.logger.error('Failed to send payment confirmation to Telegram:', notifErr);
                }
                firebase_functions_1.logger.info(`Order ${refNumber} marked as PAID via verified webhook`);
            }
        }
        if (event.type === 'checkout_session.payment.failed') {
            const refNumber = event.data?.attributes?.reference_number;
            if (refNumber && /^[A-Za-z0-9_-]+$/.test(String(refNumber))) {
                await (0, firestore_1.getFirestore)().collection('orders').doc(refNumber)
                    .update({ paymentStatus: 'PAYMENT_FAILED' });
                firebase_functions_1.logger.info(`Order ${refNumber} payment failed`);
            }
        }
        res.status(200).send('OK');
    }
    catch (error) {
        firebase_functions_1.logger.error('Webhook handler error:', error);
        res.status(200).send('OK'); // always 200 — no info leak, no retry storm
    }
});
//# sourceMappingURL=webhook.js.map