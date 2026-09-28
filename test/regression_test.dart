import 'package:flutter_test/flutter_test.dart';
import 'package:luna_express/services/delivery.dart';
import 'package:luna_express/services/cart_notifier.dart';
import 'package:luna_express/models/cart.dart';
import 'package:luna_express/utils/format.dart';
import 'package:luna_express/models/order.dart';
import 'package:luna_express/features/pasugo/models/errand.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

CartItem item({
  String id = '1',
  String variant = 'Solo',
  int price = 100,
  int qty = 1,
}) => CartItem(
  id: id,
  name: 'Burger',
  emoji: '🍔',
  imageUrl: '',
  variant: variant,
  price: price,
  quantity: qty,
);

void main() {
  group('delivery math', () {
    test('same point = zero distance', () {
      expect(
        haversine(storeLat, storeLng, storeLat, storeLng),
        closeTo(0, 1e-6),
      );
    });

    test('known distance sane (~11km between kitchens)', () {
      expect(
        haversine(storeLat, storeLng, base2Lat, base2Lng),
        inInclusiveRange(9, 14),
      );
    });

    test('quote at store = zero fee', () {
      final q = deliveryQuote(storeLat, storeLng);
      expect(q.distance, closeTo(0, 1e-6));
      expect(q.fee, 0);
    });

    test('quote uses nearer kitchen + ₱39/km', () {
      final q = deliveryQuote(base2Lat, base2Lng);
      expect(q.distance, closeTo(0, 1e-6));
      expect(q.fee, 0);
      final mid = deliveryQuote(
        (storeLat + base2Lat) / 2,
        (storeLng + base2Lng) / 2,
      );
      expect(mid.fee, (mid.distance * feePerKm).round());
      expect(
        mid.distance,
        lessThan(haversine(storeLat, storeLng, base2Lat, base2Lng)),
      );
    });
  });

  group('cart', () {
    test('add merges same name+variant, totals correct', () {
      final cart = CartNotifier();
      cart.add(item(qty: 2));
      cart.add(item(qty: 3)); // same variant -> merge
      cart.add(item(id: '2', variant: 'Combo', price: 200));
      expect(cart.items.length, 2);
      expect(cart.totalCount, 6);
      expect(cart.totalPrice, 5 * 100 + 200);
    });

    test('increment/decrement/remove/clear', () {
      final cart = CartNotifier();
      cart.add(item());
      cart.increment('1');
      expect(cart.items.first.quantity, 2);
      cart.decrement('1');
      expect(cart.items.first.quantity, 1);
      cart.decrement('1'); // qty 1 -> removed
      expect(cart.items, isEmpty);
      cart.add(item());
      cart.remove('1');
      expect(cart.items, isEmpty);
      cart.add(item());
      cart.clear();
      expect(cart.totalCount, 0);
      expect(cart.totalPrice, 0);
    });
  });

  group('format', () {
    test('phtDateLabel pads correctly', () {
      expect(phtDateLabel(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('localStamp format', () {
      expect(localStamp(DateTime(2026, 9, 28, 9, 5)), '2026-09-28  09:05');
    });

    test('timeAgo buckets', () {
      final now = DateTime.now();
      expect(timeAgo(now), 'Just now');
      expect(timeAgo(now.subtract(const Duration(minutes: 5))), '5m ago');
      expect(timeAgo(now.subtract(const Duration(hours: 3))), '3h ago');
      expect(timeAgo(now.subtract(const Duration(days: 2))), '2d ago');
    });
  });

  group('order serialization', () {
    test('OrderItem total = price * qty', () {
      final j = OrderItem(
        name: 'Fries',
        variant: 'Solo',
        price: 50,
        quantity: 3,
      ).toJson();
      expect(j['total'], 150);
    });

    test('OrderModel round-trips all fields', () {
      final ts = DateTime(2026, 9, 28, 12);
      final j = OrderModel(
        orderId: 'LX-1',
        items: [
          OrderItem(name: 'Burger', variant: 'Solo', price: 100, quantity: 2),
        ],
        totalAmount: 200,
        timestamp: ts,
        dateLabel: '2026-09-28',
        type: 'Delivery',
        entryType: 'Kiosk',
        customerName: 'Juan',
        customerPhone: '0917',
        customerAddress: 'Butuan',
      ).toJson();
      expect(j['orderId'], 'LX-1');
      expect((j['items'] as List).length, 1);
      expect(j['totalAmount'], 200);
      expect((j['timestamp'] as Timestamp).toDate(), ts);
      expect(j['paymentStatus'], 'NOT PAID'); // defaults preserved
      expect(j['status'], 'Pending');
    });
  });

  group('errand serialization', () {
    test('status round-trips', () {
      for (final s in ErrandStatus.values) {
        expect(ErrandStatus.fromJson(s.toJson()), s);
      }
    });

    test('missing status defaults to available', () {
      expect(ErrandStatus.fromJson('available'), ErrandStatus.available);
      final e = Errand.fromMap({
        'customerName': 'A',
        'customerPhone': '1',
        'phoneHash': 'h',
        'pinHash': 'p',
        'message': 'x',
        'createdAt': Timestamp.now(),
        'expiresAt': Timestamp.now(),
      });
      expect(e.status, ErrandStatus.available);
    });

    test('toFirestore/fromMap round-trip', () {
      final now = DateTime(2026, 9, 28, 12);
      final e = Errand(
        customerName: 'Ana',
        customerPhone: '0918',
        phoneHash: 'h',
        pinHash: 'p',
        message: 'buy milk',
        locationPin: const GeoPoint(9.0, 125.5),
        status: ErrandStatus.accepted,
        createdAt: now,
        expiresAt: now,
      );
      final back = Errand.fromMap(e.toFirestore(), id: 'abc');
      expect(back.id, 'abc');
      expect(back.customerName, 'Ana');
      expect(back.status, ErrandStatus.accepted);
      expect(back.locationPin, const GeoPoint(9.0, 125.5));
      expect(back.createdAt, now);
    });
  });
}
