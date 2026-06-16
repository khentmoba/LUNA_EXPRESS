"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSalesAnalytics = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-admin/firestore");
const firebase_functions_1 = require("firebase-functions");
exports.getSalesAnalytics = (0, https_1.onCall)(async (request) => {
    const db = (0, firestore_1.getFirestore)();
    try {
        // Philippines is UTC+8
        const nowUtc = new Date();
        const phtTime = new Date(nowUtc.getTime() + 8 * 60 * 60 * 1000);
        const dateLabel = `${phtTime.getUTCFullYear()}-${String(phtTime.getUTCMonth() + 1).padStart(2, '0')}-${String(phtTime.getUTCDate()).padStart(2, '0')}`;
        firebase_functions_1.logger.info(`Fetching sales analytics for dateLabel: ${dateLabel}`);
        const snapshot = await db.collection('orders')
            .where('dateLabel', '==', dateLabel)
            .get();
        let totalRevenue = 0;
        let orderCount = 0;
        let walkInRevenue = 0;
        let walkInCount = 0;
        let deliveryRevenue = 0;
        let deliveryCount = 0;
        let pickupRevenue = 0;
        let pickupCount = 0;
        const itemCounts = {};
        for (const doc of snapshot.docs) {
            const data = doc.data();
            const totalAmount = data.totalAmount || 0;
            const orderType = data.type || 'Pickup'; // 'Delivery', 'Pickup', 'Walk-In'
            const items = data.items || [];
            totalRevenue += totalAmount;
            orderCount += 1;
            if (orderType === 'Walk-In') {
                walkInRevenue += totalAmount;
                walkInCount += 1;
            }
            else if (orderType === 'Delivery') {
                deliveryRevenue += totalAmount;
                deliveryCount += 1;
            }
            else {
                // Pickup is default
                pickupRevenue += totalAmount;
                pickupCount += 1;
            }
            for (const item of items) {
                const name = item.name || 'Unknown';
                const qty = item.quantity || 1;
                itemCounts[name] = (itemCounts[name] || 0) + qty;
            }
        }
        const topItems = Object.entries(itemCounts)
            .map(([name, count]) => ({ name, count }))
            .sort((a, b) => b.count - a.count)
            .slice(0, 5);
        return {
            success: true,
            dateLabel,
            totalRevenue,
            orderCount,
            averageOrderValue: orderCount > 0 ? Math.round(totalRevenue / orderCount) : 0,
            breakdown: {
                walkIn: { revenue: walkInRevenue, count: walkInCount },
                delivery: { revenue: deliveryRevenue, count: deliveryCount },
                pickup: { revenue: pickupRevenue, count: pickupCount }
            },
            topItems
        };
    }
    catch (error) {
        firebase_functions_1.logger.error('Error getting sales analytics:', error);
        throw new https_1.HttpsError('internal', error?.message || 'Failed to retrieve sales analytics');
    }
});
//# sourceMappingURL=analytics.js.map