import { onRequest } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';
import { sendToAll, escapeMd } from '../telegram_api';
import { paymongoSecret, telegramToken, telegramChatIds } from '../index';

// Trust-but-verify: never mark PAID from the webhook payload alone.
// Re-fetch the checkout session from PayMongo with the secret key (#6/#8).
async function isSessionPaid(sessionId: string, auth: string): Promise<boolean> {
  const res = await fetch(`https://api.paymongo.com/v2/checkout_sessions/${sessionId}`, {
    headers: { Authorization: `Basic ${auth}` },
  });
  if (!res.ok) return false;
  const json: any = await res.json();
  const payments = json?.data?.attributes?.payments || [];
  return payments.some((p: any) => p?.attributes?.status === 'paid');
}

export const paymongoWebhook = onRequest(
  { secrets: [paymongoSecret, telegramToken, telegramChatIds] },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).send('Method Not Allowed');
      return;
    }
    if (!req.headers['paymongo-signature']) {
      logger.warn('PayMongo webhook missing signature');
      res.status(200).send('OK');
      return;
    }

    try {
      const event = req.body?.data;
      if (!event?.type || !event?.data?.id) {
        logger.warn('Invalid webhook payload');
        res.status(200).send('OK');
        return;
      }
      logger.info(`PayMongo webhook received: ${event.type}`);
      const sessionId = String(event.data.id);

      if (event.type === 'checkout_session.payment.paid') {
        const auth = Buffer.from(`${paymongoSecret.value()}:`).toString('base64');
        if (!(await isSessionPaid(sessionId, auth))) {
          logger.warn(`Webhook for ${sessionId} failed API verification — ignored`);
          res.status(200).send('OK');
          return;
        }
        const attrs = event.data.attributes || {};
        const refNumber = attrs.reference_number;
        const paymentId = attrs.payments?.[0]?.id || '';
        if (refNumber && /^[A-Za-z0-9_-]+$/.test(String(refNumber))) {
          const db = getFirestore();
          await db.collection('orders').doc(refNumber).update({
            paymentStatus: 'PAID',
            paymongoPaymentId: String(paymentId).slice(0, 128),
            paidAt: new Date().toISOString(),
          });
          try {
            const orderDoc = await db.collection('orders').doc(refNumber).get();
            if (orderDoc.exists) {
              const data = orderDoc.data()!;
              await sendToAll([
                `✅ *PAYMENT CONFIRMED*`,
                `📄 *Order:* ${escapeMd(refNumber)}`,
                `👤 *Customer:* ${escapeMd(String(data.customerName || ''))}`,
                `💰 *Amount:* \u20B1${escapeMd(String(data.totalAmount || 0))}`,
                `💳 *Payment:* GCash via PayMongo`,
                `📦 *Type:* ${escapeMd(String(data.type || ''))}`,
                `🕐 *Paid at:* ${new Date().toLocaleString('en-PH')}`,
              ].join('\n'));
            }
          } catch (notifErr) {
            logger.error('Failed to send payment confirmation to Telegram:', notifErr);
          }
          logger.info(`Order ${refNumber} marked as PAID via verified webhook`);
        }
      }

      if (event.type === 'checkout_session.payment.failed') {
        const refNumber = event.data?.attributes?.reference_number;
        if (refNumber && /^[A-Za-z0-9_-]+$/.test(String(refNumber))) {
          await getFirestore().collection('orders').doc(refNumber)
            .update({ paymentStatus: 'PAYMENT_FAILED' });
          logger.info(`Order ${refNumber} payment failed`);
        }
      }

      res.status(200).send('OK');
    } catch (error: any) {
      logger.error('Webhook handler error:', error);
      res.status(200).send('OK'); // always 200 — no info leak, no retry storm
    }
  }
);
