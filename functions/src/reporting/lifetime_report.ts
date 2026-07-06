import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';

interface LifeTimeReportParams {
  startDate?: string; // YYYY-MM-DD (optional, default: earliest order)
  endDate?: string;   // YYYY-MM-DD (optional, default: today)
}

export const getLifetimeSalesReport = onCall(async (request) => {
  const db = getFirestore();
  try {
    const params = request.data as LifeTimeReportParams;
    
    // Philippines is UTC+8
    const nowUtc = new Date();
    const phtNow = new Date(nowUtc.getTime() + 8 * 60 * 60 * 1000);
    const todayLabel = `${phtNow.getUTCFullYear()}-${String(phtNow.getUTCMonth() + 1).padStart(2, '0')}-${String(phtNow.getUTCDate()).padStart(2, '0')}`;

    // Default: all time (lifetime). If startDate not provided, use '2020-01-01' as earliest bound
    const effectiveStart = params.startDate || '2020-01-01';
    const effectiveEnd = params.endDate || todayLabel;

    logger.info(`Fetching lifetime sales report from ${effectiveStart} to ${effectiveEnd}`);

    // Firestore query — we use dateLabel range if start/end differ from defaults
    let query:
      | FirebaseFirestore.Query<FirebaseFirestore.DocumentData>
      | FirebaseFirestore.CollectionReference<FirebaseFirestore.DocumentData>;

    const ordersRef = db.collection('orders');

    // We need all orders in the range. Since dateLabel is a string in YYYY-MM-DD format,
    // we can use range queries on it.
    const isAllTime = params.startDate === undefined && params.endDate === undefined;

    if (isAllTime) {
      // Fetch all orders (lifetime) — no filter needed
      query = ordersRef;
    } else {
      // Filter by date range
      query = ordersRef
        .where('dateLabel', '>=', effectiveStart)
        .where('dateLabel', '<=', effectiveEnd);
    }

    const snapshot = await query.get();

    let totalRevenue = 0;
    let orderCount = 0;
    let walkInRevenue = 0;
    let walkInCount = 0;
    let deliveryRevenue = 0;
    let deliveryCount = 0;
    let pickupRevenue = 0;
    let pickupCount = 0;
    let kioskRevenue = 0;
    let kioskCount = 0;
    let staffRevenue = 0;
    let staffCount = 0;
    let cashRevenue = 0;
    let cashCount = 0;
    let gcashRevenue = 0;
    let gcashCount = 0;
    let totalItemsSold = 0;

    const itemCounts: { [key: string]: { name: string; variant: string; quantity: number; revenue: number } } = {};
    const dailyRevenue: { [dateLabel: string]: number } = {};
    const dailyOrders: { [dateLabel: string]: number } = {};

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const totalAmount = data.totalAmount || 0;
      const orderType = data.type || 'Pickup';
      const entryType = data.entryType || 'Kiosk';
      const paymentMethod = (data.paymentMethod || 'Cash') as string;
      const items = data.items || [];
      const dateLabel = data.dateLabel || 'unknown';

      totalRevenue += totalAmount;
      orderCount += 1;

      // Channel breakdown
      if (orderType === 'Walk-In') {
        walkInRevenue += totalAmount;
        walkInCount += 1;
      } else if (orderType === 'Delivery') {
        deliveryRevenue += totalAmount;
        deliveryCount += 1;
      } else {
        pickupRevenue += totalAmount;
        pickupCount += 1;
      }

      // Entry type breakdown
      if (entryType === 'Staff') {
        staffRevenue += totalAmount;
        staffCount += 1;
      } else {
        kioskRevenue += totalAmount;
        kioskCount += 1;
      }

      // Payment method breakdown
      if (paymentMethod.toLowerCase() === 'gcash') {
        gcashRevenue += totalAmount;
        gcashCount += 1;
      } else {
        cashRevenue += totalAmount;
        cashCount += 1;
      }

      // Daily aggregates
      dailyRevenue[dateLabel] = (dailyRevenue[dateLabel] || 0) + totalAmount;
      dailyOrders[dateLabel] = (dailyOrders[dateLabel] || 0) + 1;

      // Item aggregation
      for (const item of items) {
        const name = item.name || 'Unknown';
        const variant = item.variant || '';
        const qty = item.quantity || 1;
        const itemRevenue = (item.price || 0) * qty;
        totalItemsSold += qty;

        // Create a composite key that includes variant
        const key = variant ? `${name} (${variant})` : name;
        if (!itemCounts[key]) {
          itemCounts[key] = { name, variant, quantity: 0, revenue: 0 };
        }
        itemCounts[key].quantity += qty;
        itemCounts[key].revenue += itemRevenue;
      }
    }

    // Sort and rank top items
    const topItems = Object.values(itemCounts)
      .sort((a, b) => b.quantity - a.quantity)
      .slice(0, 20)
      .map((item, index) => ({
        rank: index + 1,
        name: item.variant ? `${item.name} (${item.variant})` : item.name,
        quantity: item.quantity,
        revenue: item.revenue,
      }));

    // Build daily time-series data (sorted by date)
    const dailySeries = Object.entries(dailyRevenue)
      .map(([date, revenue]) => ({
        date,
        revenue,
        orders: dailyOrders[date] || 0,
      }))
      .sort((a, b) => a.date.localeCompare(b.date));

    return {
      success: true,
      dateRange: {
        start: effectiveStart,
        end: effectiveEnd,
        isAllTime,
      },
      summary: {
        totalRevenue,
        orderCount,
        averageOrderValue: orderCount > 0 ? Math.round(totalRevenue / orderCount) : 0,
        totalItemsSold,
      },
      breakdown: {
        channel: {
          walkIn: { revenue: walkInRevenue, count: walkInCount },
          delivery: { revenue: deliveryRevenue, count: deliveryCount },
          pickup: { revenue: pickupRevenue, count: pickupCount },
        },
        entryType: {
          kiosk: { revenue: kioskRevenue, count: kioskCount },
          staff: { revenue: staffRevenue, count: staffCount },
        },
        paymentMethod: {
          cash: { revenue: cashRevenue, count: cashCount },
          gcash: { revenue: gcashRevenue, count: gcashCount },
        },
      },
      topItems,
      dailySeries,
    };
  } catch (error: any) {
    logger.error('Error getting lifetime sales report:', error);
    throw new HttpsError('internal', error?.message || 'Failed to retrieve lifetime sales report');
  }
});
