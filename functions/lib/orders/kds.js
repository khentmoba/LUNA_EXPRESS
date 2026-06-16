"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateOrderStatus = exports.getActiveOrders = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-admin/firestore");
const firebase_functions_1 = require("firebase-functions");
exports.getActiveOrders = (0, https_1.onCall)(async (request) => {
    const db = (0, firestore_1.getFirestore)();
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
    }
    catch (error) {
        firebase_functions_1.logger.error('Error fetching active orders:', error);
        throw new https_1.HttpsError('internal', error?.message || 'Failed to fetch active orders');
    }
});
exports.updateOrderStatus = (0, https_1.onCall)(async (request) => {
    const { orderId, status } = request.data;
    if (!orderId || !status) {
        throw new https_1.HttpsError('invalid-argument', 'Missing orderId or status');
    }
    const db = (0, firestore_1.getFirestore)();
    try {
        const orderRef = db.collection('orders').doc(orderId);
        const orderDoc = await orderRef.get();
        if (!orderDoc.exists) {
            throw new https_1.HttpsError('not-found', 'Order not found');
        }
        await orderRef.update({ status });
        firebase_functions_1.logger.info(`Order ${orderId} status updated to ${status}`);
        return { success: true };
    }
    catch (error) {
        firebase_functions_1.logger.error(`Error updating order ${orderId} status:`, error);
        throw new https_1.HttpsError('internal', error?.message || 'Failed to update order status');
    }
});
//# sourceMappingURL=kds.js.map