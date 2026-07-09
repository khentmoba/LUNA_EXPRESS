import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../models/cart.dart';

class TelegramService {
  static String generateOrderNumber() {
    final r = Random();
    final n = 10000 + r.nextInt(90000);
    return 'LU-$n';
  }

  /// Sends an order notification to Telegram.
  /// Returns `true` if the notification was sent successfully, `false` otherwise.
  static Future<bool> sendOrder({
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

      final result = await callable.call({
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

      final data = result.data as Map<String, dynamic>;
      if (data['success'] != true) {
        debugPrint('ALERT: Telegram notification failed for order $orderNumber: ${data['error'] ?? 'unknown error'}');
        return false;
      } else {
        debugPrint('Telegram notification sent for $orderNumber');
        return true;
      }
    } catch (e) {
      debugPrint('ALERT: Telegram notification error for order $orderNumber: $e');
      return false;
    }
  }

  /// Shows a snackbar notification about Telegram status.
  static void showTelegramStatus(BuildContext context, bool success, String orderNumber) {
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Order saved! Telegram notification could not be sent. Please inform a staff member.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }
}
