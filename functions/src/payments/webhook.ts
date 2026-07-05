import { onRequest } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import { defineSecret } from 'firebase-functions/params';
import { logger } from 'firebase-functions';
import { sendToAll, escapeMd } from '../telegram_api';

export const paymongoWebhookSecret = defineSecret('PAYMONGO_WEBHOOK_SECRET');

export const paymongoWebhook = onRequest(
  { secrets: [paymongoWebhookSecret] },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    const signature = req.headers['paymongo-signature'] as string;

    if (!signature) {
      logger.warn('PayMongo webhook missing signature');
      res.status(200).send('OK');
      return;
    }

    try {
      const event = req.body?.data;
      if (!event || !event.type || !event.data) {
        logger.warn('Invalid webhook payload');
        res.status(200).send('OK');
        return;
      }

      logger.info(`PayMongo webhook received: ${event.type}`);

      if (event.type === 'checkout_session.payment.paid') {
        const session = event.data;
        const attrs = session.attributes || {};
        const refNumber = attrs.reference_number;
        const paymentId = attrs.payments?.[0]?.id || '';

        if (refNumber) {
          const db = getFirestore();
          await db.collection('orders').doc(refNumber).update({
            paymentStatus: 'PAID',
            paymongoPaymentId: paymentId,
            paidAt: new Date().toISOString(),
          });

          try {
            const orderDoc = await db.collection('orders').doc(refNumber).get();
            if (orderDoc.exists) {
              const data = orderDoc.data()!;
              const name = data.customerName || '';
              const total = data.totalAmount || 0;
              const type = data.type || '';

              const msg = [
                `✅ *PAYMENT CONFIRMED*`,
                `📄 *Order:* ${escapeMd(refNumber)}`,
                `👤 *Customer:* ${escapeMd(name)}`,
                `💰 *Amount:* \u20B1${escapeMd(total.toString())}`,
                `💳 *Payment:* GCash via PayMongo`,
                `📦 *Type:* ${escapeMd(type)}`,
                `🕐 *Paid at:* ${new Date().toLocaleString('en-PH')}`,
              ].join('\n');

              await sendToAll(msg);
            }
          } catch (notifErr) {
            logger.error('Failed to send payment confirmation to Telegram:', notifErr);
          }

          logger.info(`Order ${refNumber} marked as PAID via webhook`);
        }
      }

      if (event.type === 'checkout_session.payment.failed') {
        const session = event.data;
        const attrs = session.attributes || {};
        const refNumber = attrs.reference_number;

        if (refNumber) {
          const db = getFirestore();
          await db.collection('orders').doc(refNumber).update({
            paymentStatus: 'PAYMENT_FAILED',
          });
          logger.info(`Order ${refNumber} payment failed`);
        }
      }

      res.status(200).send('OK');
    } catch (error: any) {
      logger.error('Webhook handler error:', error);
      res.status(200).send('OK');
    }
  }
);
