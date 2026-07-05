"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.paymongoWebhook = exports.paymongoWebhookSecret = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-admin/firestore");
const params_1 = require("firebase-functions/params");
const firebase_functions_1 = require("firebase-functions");
const telegram_api_1 = require("../telegram_api");
exports.paymongoWebhookSecret = (0, params_1.defineSecret)('PAYMONGO_WEBHOOK_SECRET');
exports.paymongoWebhook = (0, https_1.onRequest)({ secrets: [exports.paymongoWebhookSecret] }, async (req, res) => {
    if (req.method !== 'POST') {
        res.status(405).send('Method Not Allowed');
        return;
    }
    const signature = req.headers['paymongo-signature'];
    if (!signature) {
        firebase_functions_1.logger.warn('PayMongo webhook missing signature');
        res.status(200).send('OK');
        return;
    }
    try {
        const event = req.body?.data;
        if (!event || !event.type || !event.data) {
            firebase_functions_1.logger.warn('Invalid webhook payload');
            res.status(200).send('OK');
            return;
        }
        firebase_functions_1.logger.info(`PayMongo webhook received: ${event.type}`);
        if (event.type === 'checkout_session.payment.paid') {
            const session = event.data;
            const attrs = session.attributes || {};
            const refNumber = attrs.reference_number;
            const paymentId = attrs.payments?.[0]?.id || '';
            if (refNumber) {
                const db = (0, firestore_1.getFirestore)();
                await db.collection('orders').doc(refNumber).update({
                    paymentStatus: 'PAID',
                    paymongoPaymentId: paymentId,
                    paidAt: new Date().toISOString(),
                });
                try {
                    const orderDoc = await db.collection('orders').doc(refNumber).get();
                    if (orderDoc.exists) {
                        const data = orderDoc.data();
                        const name = data.customerName || '';
                        const total = data.totalAmount || 0;
                        const type = data.type || '';
                        const msg = [
                            `✅ *PAYMENT CONFIRMED*`,
                            `📄 *Order:* ${(0, telegram_api_1.escapeMd)(refNumber)}`,
                            `👤 *Customer:* ${(0, telegram_api_1.escapeMd)(name)}`,
                            `💰 *Amount:* \u20B1${(0, telegram_api_1.escapeMd)(total.toString())}`,
                            `💳 *Payment:* GCash via PayMongo`,
                            `📦 *Type:* ${(0, telegram_api_1.escapeMd)(type)}`,
                            `🕐 *Paid at:* ${new Date().toLocaleString('en-PH')}`,
                        ].join('\n');
                        await (0, telegram_api_1.sendToAll)(msg);
                    }
                }
                catch (notifErr) {
                    firebase_functions_1.logger.error('Failed to send payment confirmation to Telegram:', notifErr);
                }
                firebase_functions_1.logger.info(`Order ${refNumber} marked as PAID via webhook`);
            }
        }
        if (event.type === 'checkout_session.payment.failed') {
            const session = event.data;
            const attrs = session.attributes || {};
            const refNumber = attrs.reference_number;
            if (refNumber) {
                const db = (0, firestore_1.getFirestore)();
                await db.collection('orders').doc(refNumber).update({
                    paymentStatus: 'PAYMENT_FAILED',
                });
                firebase_functions_1.logger.info(`Order ${refNumber} payment failed`);
            }
        }
        res.status(200).send('OK');
    }
    catch (error) {
        firebase_functions_1.logger.error('Webhook handler error:', error);
        res.status(200).send('OK');
    }
});
//# sourceMappingURL=webhook.js.map