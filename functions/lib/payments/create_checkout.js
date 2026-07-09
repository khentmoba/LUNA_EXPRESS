"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createCheckoutSession = exports.paymongoSecretKey = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-admin/firestore");
const params_1 = require("firebase-functions/params");
const firebase_functions_1 = require("firebase-functions");
exports.paymongoSecretKey = (0, params_1.defineString)('PAYMONGO_SECRET_KEY');
const PAYMONGO_API = 'https://api.paymongo.com/v2/checkout_sessions';
exports.createCheckoutSession = (0, https_1.onCall)({ secrets: [exports.paymongoSecretKey] }, async (request) => {
    const { orderId, amount, items, customerName, customerPhone } = request.data;
    if (!orderId || !amount || !items || !items.length) {
        throw new https_1.HttpsError('invalid-argument', 'Missing required fields: orderId, amount, items');
    }
    const lineItems = items.map((i) => ({
        name: i.name,
        amount: i.price * 100,
        currency: 'PHP',
        quantity: i.quantity,
    }));
    const auth = Buffer.from(`${exports.paymongoSecretKey.value()}:`).toString('base64');
    try {
        const response = await fetch(PAYMONGO_API, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Basic ${auth}`,
            },
            body: JSON.stringify({
                data: {
                    attributes: {
                        line_items: lineItems,
                        payment_method_types: ['gcash', 'paymaya'],
                        success_url: 'https://lunaexpress.web.app/payment/success',
                        cancel_url: 'https://lunaexpress.web.app/payment/cancel',
                        reference_number: orderId,
                        description: `Luna Express Order #${orderId}`,
                        metadata: {
                            order_id: orderId,
                            customer_name: customerName || '',
                            customer_phone: customerPhone || '',
                        },
                    },
                },
            }),
        });
        const json = await response.json();
        if (!response.ok) {
            const errDetail = json.errors?.[0]?.detail || 'PayMongo API error';
            firebase_functions_1.logger.error('PayMongo create checkout failed:', json.errors);
            throw new https_1.HttpsError('internal', errDetail);
        }
        const checkout = json.data;
        const checkoutUrl = checkout.attributes.checkout_url;
        const db = (0, firestore_1.getFirestore)();
        await db.collection('orders').doc(orderId).set({
            checkoutSessionId: checkout.id,
            checkoutUrl: checkoutUrl,
            paymentMethod: 'GCash',
            paymentStatus: 'AWAITING_PAYMENT',
        }, { merge: true });
        firebase_functions_1.logger.info(`Checkout session created for order ${orderId}: ${checkout.id}`);
        return {
            success: true,
            checkoutUrl: checkoutUrl,
            checkoutSessionId: checkout.id,
        };
    }
    catch (error) {
        firebase_functions_1.logger.error('Error creating PayMongo checkout:', error);
        throw new https_1.HttpsError('internal', error?.message || 'Failed to create checkout session');
    }
});
//# sourceMappingURL=create_checkout.js.map