import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';
import { requireStaff, validDocId, cleanStr } from '../util/security';

const VALID_STATUSES = ['Pending', 'Preparing', 'Ready', 'Completed', 'Cancelled'];

// #17: trimmed projection — only what the KDS screen renders. Never ...data.
const projectOrder = (id: string, d: FirebaseFirestore.DocumentData) => ({
  id,
  orderNumber: d.orderId || d.orderNumber || id,
  customerName: d.customerName || '',
  items: (Array.isArray(d.items) ? d.items : []).map((i: any) => ({
    name: String(i.name || ''),
    variant: String(i.variant || ''),
    qty: Number(i.quantity) || 0,
  })),
  itemsCount: Array.isArray(d.items) ? d.items.reduce((s: number, i: any) => s + (Number(i.quantity) || 0), 0) : 0,
  total: Number(d.totalAmount) || 0,
  type: String(d.type || ''),
  status: String(d.status || 'Pending'),
  timestamp: d.timestamp?.toDate?.()?.toISOString?.() || new Date().toISOString(),
});

export const getActiveOrders = onCall(async (request) => {
  requireStaff(request); // #6 + #7
  const db = getFirestore();
  try {
    const activeThreshold = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const snapshot = await db.collection('orders')
      .where('timestamp', '>=', activeThreshold)
      .orderBy('timestamp', 'asc')
      .limit(200)
      .get();

    const orders = [];
    for (const doc of snapshot.docs) {
      const data = doc.data();
      if ((data.status || 'Pending') !== 'Completed') orders.push(projectOrder(doc.id, data));
    }
    return { success: true, orders };
  } catch (error: any) {
    logger.error('Error fetching active orders:', error);
    throw new HttpsError('internal', 'Failed to fetch active orders');
  }
});

export const updateOrderStatus = onCall(async (request) => {
  requireStaff(request); // #6 + #7
  const orderId = validDocId(request.data?.orderId, 'orderId'); // #13
  const status = cleanStr(request.data?.status, 32, 'status'); // #14
  if (!VALID_STATUSES.includes(status)) throw new HttpsError('invalid-argument', 'Invalid status'); // #8

  const db = getFirestore();
  try {
    const orderRef = db.collection('orders').doc(orderId);
    if (!(await orderRef.get()).exists) throw new HttpsError('not-found', 'Order not found');
    await orderRef.update({ status });
    logger.info(`Order ${orderId} status updated to ${status}`);
    return { success: true };
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;
    logger.error(`Error updating order ${orderId} status:`, error);
    throw new HttpsError('internal', 'Failed to update order status');
  }
});
