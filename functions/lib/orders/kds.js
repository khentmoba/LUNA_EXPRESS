"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateOrderStatus = exports.getActiveOrders = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-admin/firestore");
const firebase_functions_1 = require("firebase-functions");
const security_1 = require("../util/security");
const VALID_STATUSES = ['Pending', 'Preparing', 'Ready', 'Completed', 'Cancelled'];
// #17: trimmed projection — only what the KDS screen renders. Never ...data.
const projectOrder = (id, d) => ({
    id,
    orderNumber: d.orderId || d.orderNumber || id,
    customerName: d.customerName || '',
    items: (Array.isArray(d.items) ? d.items : []).map((i) => ({
        name: String(i.name || ''),
        variant: String(i.variant || ''),
        qty: Number(i.quantity) || 0,
    })),
    itemsCount: Array.isArray(d.items) ? d.items.reduce((s, i) => s + (Number(i.quantity) || 0), 0) : 0,
    total: Number(d.totalAmount) || 0,
    type: String(d.type || ''),
    status: String(d.status || 'Pending'),
    timestamp: d.timestamp?.toDate?.()?.toISOString?.() || new Date().toISOString(),
});
exports.getActiveOrders = (0, https_1.onCall)(async (request) => {
    (0, security_1.requireStaff)(request); // #6 + #7
    const db = (0, firestore_1.getFirestore)();
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
            if ((data.status || 'Pending') !== 'Completed')
                orders.push(projectOrder(doc.id, data));
        }
        return { success: true, orders };
    }
    catch (error) {
        firebase_functions_1.logger.error('Error fetching active orders:', error);
        throw new https_1.HttpsError('internal', 'Failed to fetch active orders');
    }
});
exports.updateOrderStatus = (0, https_1.onCall)(async (request) => {
    (0, security_1.requireStaff)(request); // #6 + #7
    const orderId = (0, security_1.validDocId)(request.data?.orderId, 'orderId'); // #13
    const status = (0, security_1.cleanStr)(request.data?.status, 32, 'status'); // #14
    if (!VALID_STATUSES.includes(status))
        throw new https_1.HttpsError('invalid-argument', 'Invalid status'); // #8
    const db = (0, firestore_1.getFirestore)();
    try {
        const orderRef = db.collection('orders').doc(orderId);
        if (!(await orderRef.get()).exists)
            throw new https_1.HttpsError('not-found', 'Order not found');
        await orderRef.update({ status });
        firebase_functions_1.logger.info(`Order ${orderId} status updated to ${status}`);
        return { success: true };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError)
            throw error;
        firebase_functions_1.logger.error(`Error updating order ${orderId} status:`, error);
        throw new https_1.HttpsError('internal', 'Failed to update order status');
    }
});
//# sourceMappingURL=kds.js.map