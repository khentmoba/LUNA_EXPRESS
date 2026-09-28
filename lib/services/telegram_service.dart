import 'dart:math';
import 'package:flutter/material.dart';
import '../models/order.dart';
import 'functions.dart';

class TelegramService {
  static String generateOrderNumber() {
    final n = 10000 + Random().nextInt(90000);
    return 'LU-$n';
  }

  /// Sends an order notification to Telegram. Returns true on success.
  static Future<bool> sendOrder({
    required OrderModel order,
    required String timeStr,
  }) async {
    try {
      final data = await callFn('sendOrderNotification', {
        'orderNumber': order.orderId,
        'customerName': order.customerName,
        'customerAddress': order.customerAddress,
        'customerPhone': order.customerPhone,
        'items': order.items
            .map(
              (i) => {
                'name': i.name,
                'variant': i.variant,
                'price': i.price,
                'quantity': i.quantity,
              },
            )
            .toList(),
        'total': order.totalAmount,
        'timeStr': timeStr,
        'orderType': order.type,
        'deliveryFee': order.deliveryFee,
        'paymentMethod': order.paymentMethod,
        'paymentStatus': order.paymentStatus,
        'lat': order.lat,
        'lng': order.lng,
      });
      if (data['success'] != true) {
        debugPrint(
          'ALERT: Telegram notification failed for order ${order.orderId}',
        );
        return false;
      }
      debugPrint('Telegram notification sent for ${order.orderId}');
      return true;
    } catch (e) {
      debugPrint(
        'ALERT: Telegram notification error for order ${order.orderId}: $e',
      );
      return false;
    }
  }

  /// Shows a snackbar when the Telegram notification failed.
  static void showTelegramStatus(
    BuildContext context,
    bool success,
    String orderNumber,
  ) {
    if (success) return;
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
