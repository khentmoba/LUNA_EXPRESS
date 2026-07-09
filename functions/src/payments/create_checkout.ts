import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import { defineString } from 'firebase-functions/params';
import { logger } from 'firebase-functions';

export const paymongoSecretKey = defineString('PAYMONGO_SECRET_KEY');
const PAYMONGO_API = 'https://api.paymongo.com/v2/checkout_sessions';

export const createCheckoutSession = onCall(
  { secrets: [paymongoSecretKey] },
  async (request) => {
    const { orderId, amount, items, customerName, customerPhone } = request.data;

    if (!orderId || !amount || !items || !items.length) {
      throw new HttpsError('invalid-argument', 'Missing required fields: orderId, amount, items');
    }

    const lineItems = items.map((i: any) => ({
      name: i.name,
      amount: i.price * 100,
      currency: 'PHP',
      quantity: i.quantity,
    }));

    const auth = Buffer.from(`${paymongoSecretKey.value()}:`).toString('base64');

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

      const json: any = await response.json();

      if (!response.ok) {
        const errDetail = json.errors?.[0]?.detail || 'PayMongo API error';
        logger.error('PayMongo create checkout failed:', json.errors);
        throw new HttpsError('internal', errDetail);
      }

      const checkout = json.data;
      const checkoutUrl = checkout.attributes.checkout_url;

      const db = getFirestore();
      await db.collection('orders').doc(orderId).set(
        {
          checkoutSessionId: checkout.id,
          checkoutUrl: checkoutUrl,
          paymentMethod: 'GCash',
          paymentStatus: 'AWAITING_PAYMENT',
        },
        { merge: true }
      );

      logger.info(`Checkout session created for order ${orderId}: ${checkout.id}`);

      return {
        success: true,
        checkoutUrl: checkoutUrl,
        checkoutSessionId: checkout.id,
      };
    } catch (error: any) {
      logger.error('Error creating PayMongo checkout:', error);
      throw new HttpsError('internal', error?.message || 'Failed to create checkout session');
    }
  }
);
