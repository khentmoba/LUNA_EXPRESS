import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order.dart';

class OrderService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  static String getPHTDateLabel() {
    // Philippines is UTC+8
    final now = DateTime.now().toUtc().add(const Duration(hours: 8));
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
