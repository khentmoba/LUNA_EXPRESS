import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../utils/format.dart';
import 'telegram_service.dart';

class OrderService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Full order pipeline: Telegram notify → Firestore save → in-memory
  /// history for the admin dashboard. Returns whether Telegram succeeded.
  static Future<bool> placeOrder(OrderModel order, String timeStr) async {
    final telegramSent = await TelegramService.sendOrder(
      order: order,
      timeStr: timeStr,
    );
    await saveOrder(order);
    orderHistory.add({
      'orderNumber': order.orderId,
      'customerName': order.customerName,
      'items': order.items
          .map(
            (i) => {
              'name': i.name,
              'variant': i.variant,
              'qty': i.quantity,
              'price': i.price,
            },
          )
          .toList(),
      'itemsCount': order.items.fold(0, (s, i) => s + i.quantity),
      'total': order.totalAmount,
      'time': timeStr,
      'type': order.type,
      'isWalkIn': order.entryType == 'Staff',
    });
    return telegramSent;
  }

  static Future<bool> saveOrder(OrderModel order) async {
    try {
      await _db.collection('orders').add(order.toJson());
      debugPrint('Order ${order.orderId} saved to Firestore');
      return true;
    } catch (e) {
      debugPrint('Error saving order: $e');
      return false;
    }
  }
}

// ── In-memory order history for the admin dashboard ──
final List<Map<String, dynamic>> orderHistory = [];

int get todayRevenue => _todayOrders.fold(0, (s, o) => s + (o['total'] as int));
int get todayOrderCount => _todayOrders.length;
int get todayItemsSold =>
    _todayOrders.fold(0, (s, o) => s + (o['itemsCount'] as int));
double get avgOrderValue =>
    todayOrderCount > 0 ? todayRevenue / todayOrderCount : 0;

List<Map<String, dynamic>> get _todayOrders => orderHistory.where((o) {
  final t = o['time'] as String;
  return t.startsWith(phtDateLabel(DateTime.now()));
}).toList();
