import { getFirestore } from 'firebase-admin/firestore';

export async function aggregateDailySales(dateLabel: string) {
  const db = getFirestore();
  const ordersRef = db.collection('orders');
  
  const snapshot = await ordersRef
    .where('dateLabel', '==', dateLabel)
    .get();

  if (snapshot.empty) {
    return null;
  }

  let totalSales = 0;
  let kioskSales = 0;
  let staffSales = 0;
  let totalOrders = 0;
  const itemCounts: { [key: string]: number } = {};

  snapshot.forEach(doc => {
    const data = doc.data();
    const amount = data.totalAmount || 0;
    
    totalSales += amount;
    totalOrders++;

    if (data.entryType === 'Staff') {
      staffSales += amount;
    } else {
      kioskSales += amount;
    }

    // Aggregate items
    if (data.items && Array.isArray(data.items)) {
      data.items.forEach((item: any) => {
        const key = `${item.name}${item.variant ? ` (${item.variant})` : ''}`;
        itemCounts[key] = (itemCounts[key] || 0) + (item.quantity || 1);
      });
    }
  });

  return {
    date: dateLabel,
    totalSales,
    kioskSales,
    staffSales,
    totalOrders,
    topItems: Object.entries(itemCounts)
      .map(([name, qty]) => ({ name, qty }))
      .sort((a, b) => b.qty - a.qty)
  };
}
