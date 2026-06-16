import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../models/cart.dart';

class TelegramService {
  static String generateOrderNumber() {
    final r = Random();
    final n = 10000 + r.nextInt(90000);
    return 'LU-$n';
  }

  static Future<void> sendOrder({
    required String orderNumber,
    required String customerName,
    required String customerAddress,
    required String customerPhone,
    required List<CartItem> items,
    required int total,
    required String timeStr,
    required String orderType,
    int deliveryFee = 0,
    String paymentMethod = 'Cash',
    String paymentStatus = 'NOT PAID',
    double? lat,
    double? lng,
  }) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable(
            'sendOrderNotification',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
          );

      // Serialize items
      final serializedItems = items.map((i) => {
        'name': i.name,
        'variant': i.variant,
        'price': i.price,
        'quantity': i.quantity,
      }).toList();

      await callable.call({
        'orderNumber': orderNumber,
        'customerName': customerName,
        'customerAddress': customerAddress,
        'customerPhone': customerPhone,
        'items': serializedItems,
        'total': total,
        'timeStr': timeStr,
        'orderType': orderType,
        'deliveryFee': deliveryFee,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'lat': lat,
        'lng': lng,
      });
      debugPrint('Telegram notification sent successfully via Cloud Function');
    } catch (e) {
      debugPrint('Telegram error: $e');
    }
  }
}
