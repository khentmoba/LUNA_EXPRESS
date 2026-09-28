import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';
import { paymongoSecret } from '../index';
import { cleanStr, optStr, cleanInt } from '../util/security';

const PAYMONGO_API = 'https://api.paymongo.com/v2/checkout_sessions';

// Server-side price list — single source of truth for payment verification.
// MUST match lib/data/menu_data.dart. Name → allowed prices (variants/collisions).
// #8: never trust client-supplied prices; they only pick name+variant+qty.
const MENU_PRICES: Record<string, number[]> = {
  'Shawarma Wrap': [99, 60], 'Shawarma All Meat': [80], 'Shawarma Rice Bowl': [50],
  'Shawarma Burger': [95], 'Shawarma Fries': [75], 'Shawarma Nachos': [75],
  'Shawarma Quesadilla': [99], 'Nachos & Fries Overload': [99],
  'Shawarma Wrap + Fries + Drinks': [128], 'Shawarma Burger + Shawarma Wrap + Drinks': [149],
  'Buy 1 Take 1 French Fries': [50], 'Large Fries': [75], 'Bucket Fries': [99], 'Terra Fries': [150],
  'Combo 1 – Burger + Fries': [60], 'Combo 2 – Hotdog + Fries': [60],
  'Super Combo 1 – Hotdog + Fries + Drink': [99], 'Super Combo 2 – Burger + Fries + Drink': [99],
  'Couple Snack Combo': [169], 'Combo Promo - Halo Halo + Fries + Shawarma Wrap': [149],
  'Quesadilla': [75], 'Ice Cream Halo-Halo': [49, 65],
  'Mango-Graham Ice Cream Overload': [65], 'Leche Flan': [20, 39],
  'Purple Taro': [39], 'Cookies N Cream': [39], 'Dark Chocolate': [39], 'Black Forest': [39],
  'Strawberry': [39, 49], 'Rocky Road': [39], 'Choco Kisses': [39], '3 for ₱100 Coolers': [100],
  'Classic Lemonade': [49], 'Lemon Yakult': [49], 'Lemon Strawberry': [49],
  'Lemon Cucumber': [49], 'Lemon Yogurt': [49],
  'Green Apple': [49], 'Sweet Orange': [49], 'Mixed Berries': [49], 'Four Seasons': [49],
  'Cookies & Cream Overload': [65], 'Chocolate Oreo': [65], 'Strawberry Oreo': [65], 'Milo Oreo Float': [65],
  'Milo Dinosaur': [59], 'Milo Float': [59], 'Milo Crunch': [59], 'Milo Oreo': [59],
  'Coke Float': [39, 49], 'Chuckie Float': [59], 'Cookies and Cream Float': [65],
  'Cafe Latte': [39, 49], 'Caramel Macchiato': [39, 49],
  'Ice Cappuccino': [39, 49], 'Chocolate Coffee': [39, 49],
  'Burger Patty': [55], 'Ham & Cheese': [55], 'Cheese Burger': [65],
  'Burger with Egg': [85], 'Egg & Cheese': [95], 'Hotdog Sandwich': [69],
};

const MAX_DELIVERY_FEE = 500; // distance-based fee is client-computed; cap it.

export const createCheckoutSession = onCall(
  { secrets: [paymongoSecret] }, // #1
  async (request) => {
    const d = request.data || {};
    const orderId = cleanStr(d.orderId, 64, 'orderId');
    const amount = cleanInt(d.amount, 1000000, 'amount');
    const customerName = optStr(d.customerName, 100);
    const customerPhone = optStr(d.customerPhone, 32);

    if (!Array.isArray(d.items) || d.items.length === 0 || d.items.length > 50) {
      throw new HttpsError('invalid-argument', 'Invalid items');
    }

    // #8 + #14: verify every line against server prices, recompute total.
    let itemsTotal = 0;
    const lineItems = d.items.map((i: any) => {
      const name = cleanStr(i?.name, 120, 'item name');
      const qty = cleanInt(i?.quantity ?? 1, 99, 'quantity') || 1;
      const allowed = MENU_PRICES[name];
      if (!allowed) throw new HttpsError('invalid-argument', `Unknown item: ${name}`);
      const price = Number(i?.price);
      if (!allowed.includes(price)) {
        throw new HttpsError('invalid-argument', `Price mismatch for ${name}`);
      }
      itemsTotal += price * qty;
      return { name, amount: price * 100, currency: 'PHP', quantity: qty };
    });

    // Amount must cover items; anything above is delivery fee (capped).
    if (amount < itemsTotal || amount > itemsTotal + MAX_DELIVERY_FEE) {
      throw new HttpsError('invalid-argument', 'Amount does not match order total');
    }

    const paymongoKey = paymongoSecret.value();
    if (!paymongoKey) throw new HttpsError('internal', 'Payment service not configured');
    const auth = Buffer.from(`${paymongoKey}:`).toString('base64');

    try {
      const response = await fetch(PAYMONGO_API, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Basic ${auth}` },
        body: JSON.stringify({
          data: {
            attributes: {
              line_items: lineItems,
              payment_method_types: ['gcash', 'paymaya'],
              success_url: 'https://lunaexpress.web.app/payment/success',
              cancel_url: 'https://lunaexpress.web.app/payment/cancel',
              reference_number: orderId,
              description: `Luna Express Order #${orderId}`,
              metadata: { order_id: orderId, customer_name: customerName, customer_phone: customerPhone },
            },
          },
        }),
      });

      const json: any = await response.json();
      if (!response.ok) {
        logger.error('PayMongo create checkout failed:', json.errors);
        throw new HttpsError('internal', 'Payment provider error'); // #17: don't leak provider detail
      }

      const checkout = json.data;
      await getFirestore().collection('orders').doc(orderId).set({
        checkoutSessionId: checkout.id,
        checkoutUrl: checkout.attributes.checkout_url,
        paymentMethod: 'GCash',
        paymentStatus: 'AWAITING_PAYMENT',
        verifiedTotal: itemsTotal,
      }, { merge: true });

      logger.info(`Checkout session created for order ${orderId}: ${checkout.id}`);
      // #17: only what the client needs to redirect.
      return { success: true, checkoutUrl: checkout.attributes.checkout_url, checkoutSessionId: checkout.id };
    } catch (error: any) {
      if (error instanceof HttpsError) throw error;
      logger.error('Error creating PayMongo checkout:', error);
      throw new HttpsError('internal', 'Failed to create checkout session');
    }
  }
);
