import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';

export const getActiveOrders = onCall(async (request) => {
  const db = getFirestore();
  try {
    // Only get orders from the last 24 hours to keep the display snappy and performant.
    const activeThreshold = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const snapshot = await db.collection('orders')
      .where('timestamp', '>=', activeThreshold)
      .orderBy('timestamp', 'asc')
      .get();

    const orders = [];
    for (const doc of snapshot.docs) {
      const data = doc.data();
      const status = data.status || 'Pending';
      if (status !== 'Completed') {
        orders.push({
          id: doc.id,
          ...data,
          status,
          timestamp: data.timestamp ? data.timestamp.toDate().toISOString() : new Date().toISOString(),
        });
      }
    }
    return { success: true, orders };
  } catch (error: any) {
    logger.error('Error fetching active orders:', error);
    throw new HttpsError('internal', error?.message || 'Failed to fetch active orders');
  }
});

export const updateOrderStatus = onCall(async (request) => {
  const { orderId, status } = request.data;
  if (!orderId || !status) {
    throw new HttpsError('invalid-argument', 'Missing orderId or status');
  }

  const db = getFirestore();
  try {
    const orderRef = db.collection('orders').doc(orderId);
    const orderDoc = await orderRef.get();
    if (!orderDoc.exists) {
      throw new HttpsError('not-found', 'Order not found');
    }

    await orderRef.update({ status });
    logger.info(`Order ${orderId} status updated to ${status}`);
    return { success: true };
  } catch (error: any) {
    logger.error(`Error updating order ${orderId} status:`, error);
    throw new HttpsError('internal', error?.message || 'Failed to update order status');
  }
});
