import 'package:flutter/material.dart';
import '../models/order.dart';
import '../utils/format.dart';
import 'functions.dart';

class TelegramService {
  /// Display number in PHT: `LU-YYMMDD-HHMMSS`.
  ///
  /// Time-based rather than random: two kiosks cannot issue the same number in
  /// the same second, and the sequence is readable to staff. Uniqueness of the
  /// record itself comes from the Firestore document id, not from this string.
  static String generateOrderNumber() => orderNumberFor(phtNow());

  static String orderNumberFor(DateTime phtTime) {
    String two(int n) => n.toString().padLeft(2, '0');
    final yy = two(phtTime.year % 100);
    final date = '$yy${two(phtTime.month)}${two(phtTime.day)}';
    final clock =
        '${two(phtTime.hour)}${two(phtTime.minute)}${two(phtTime.second)}';
    return 'LU-$date-$clock';
  }

  /// Sends an order notification to Telegram. Returns true on success.
  ///
  /// [orderDocId] lets the function record whether the notification actually
  /// went out, so staff can find orders that were saved but never announced.
  static Future<bool> sendOrder({
    required OrderModel order,
    required String timeStr,
    required String orderDocId,
  }) async {
    try {
      final data = await callFn('sendOrderNotification', {
        'orderDocId': orderDocId,
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
