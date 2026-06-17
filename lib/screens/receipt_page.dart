import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cart.dart';
import '../widgets/kiosk/kiosk_theme.dart';

class ReceiptPage extends StatelessWidget {
  final String orderNumber, customerName, customerAddress, customerPhone, timeStr, orderType;
  final List<CartItem> items;
  final int total;
  final int deliveryFee;
  final bool isWalkIn;
  const ReceiptPage({
    super.key,
    required this.orderNumber,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    required this.items,
    required this.total,
    required this.timeStr,
    required this.isWalkIn,
    required this.orderType,
    this.deliveryFee = 0,
  });

  bool get _isPickup => orderType == 'Pickup';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KioskTheme.lunaTan,
      appBar: AppBar(
        title: Text(
          'RECEIPT',
          style: KioskTheme.headerSmall.copyWith(letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: KioskTheme.lunaBrown,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: KioskTheme.cardBrown,
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 48)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isWalkIn
                        ? 'ORDER COMPLETE'
                        : _isPickup
                            ? 'PICKUP CONFIRMED!'
                            : 'ORDER PLACED!',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isWalkIn
                        ? 'Thank you for dining with us!'
                        : _isPickup
                            ? 'Your order will be ready for pickup soon.'
                            : 'We are preparing your delivery now!',
                    style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(KioskTheme.radiusXl),
                boxShadow: KioskTheme.shadowLg,
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: KioskTheme.lunaTan.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(KioskTheme.radiusXl)),
                    ),
                    child: Column(
                      children: [
                        Text('LUNA EXPRESS', style: KioskTheme.headerMedium.copyWith(letterSpacing: 4)),
                        Text('Luna Bites & Delights', style: KioskTheme.bodyMedium),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: KioskTheme.badgeBrown,
                          child: Text('ORDER # $orderNumber', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 2)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isWalkIn) ...[
                          _row('FULL NAME', customerName),
                          const SizedBox(height: 12),
                          if (!_isPickup) ...[
                            _row('ADDRESS', customerAddress),
                            const SizedBox(height: 12),
                          ],
                          _row('PHONE', customerPhone),
                          const SizedBox(height: 12),
                        ],
                        _row('TIME', timeStr),
                        const SizedBox(height: 24),
                        KioskTheme.divider(),
                        const SizedBox(height: 24),
                        Text('ITEMS ORDERED', style: KioskTheme.labelMedium.copyWith(color: KioskTheme.textMuted, fontSize: 14)),
                        const SizedBox(height: 16),
                        ...items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${item.quantity}x', style: KioskTheme.titleMedium.copyWith(fontSize: 16)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, style: KioskTheme.titleLarge.copyWith(fontSize: 16)),
                                        if (item.variant.isNotEmpty) Text(item.variant, style: KioskTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  Text('\u20B1${item.price * item.quantity}', style: KioskTheme.titleMedium.copyWith(fontSize: 16)),
                                ],
                              ),
                            )),
                        KioskTheme.divider(),
                        const SizedBox(height: 32),
                        if (!_isPickup && deliveryFee > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('DELIVERY FEE', style: KioskTheme.bodyMedium.copyWith(letterSpacing: 1)),
                              Text('\u20B1$deliveryFee', style: KioskTheme.titleMedium.copyWith(fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('GRAND TOTAL', style: KioskTheme.headerSmall.copyWith(letterSpacing: 1)),
                            Text('\u20B1$total', style: KioskTheme.headerLarge.copyWith(fontSize: 36)),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: KioskTheme.lunaTan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
                            border: Border.all(color: KioskTheme.lunaTan.withOpacity(0.5)),
                          ),
                          child: Center(
                            child: Text(
                              isWalkIn
                                  ? 'Please show this to the staff.'
                                  : _isPickup
                                      ? 'Please pick up your order at the counter.'
                                      : 'Screenshot this for your records!',
                              style: KioskTheme.bodyLarge.copyWith(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: KioskTheme.lunaBrown,
                  borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
                  boxShadow: KioskTheme.shadowPrimary,
                ),
                child: Center(
                  child: Text(
                    isWalkIn ? 'NEW WALK-IN ORDER' : 'ORDER AGAIN',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: KioskTheme.labelMedium.copyWith(color: KioskTheme.textMuted))),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: KioskTheme.bodyLarge.copyWith(fontSize: 14))),
        ],
      );
}
