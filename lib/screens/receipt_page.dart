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
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, color: KioskTheme.lunaBrown, letterSpacing: 2),
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
              decoration: BoxDecoration(
                color: KioskTheme.lunaBrown,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: KioskTheme.lunaBrown.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
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
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: KioskTheme.lunaBrown.withOpacity(0.05),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: KioskTheme.lunaTan.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: Column(
                      children: [
                        Text('LUNA EXPRESS', style: GoogleFonts.outfit(color: KioskTheme.lunaBrown, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 4)),
                        Text('Luna Bites & Delights', style: GoogleFonts.outfit(color: KioskTheme.lunaBrown.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(color: KioskTheme.lunaBrown, borderRadius: BorderRadius.circular(50)),
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
                          _row('👤 NAME', customerName),
                          const SizedBox(height: 12),
                          if (!_isPickup) ...[
                            _row('📍 ADDRESS', customerAddress),
                            const SizedBox(height: 12),
                          ],
                          _row('📞 PHONE', customerPhone),
                          const SizedBox(height: 12),
                        ],
                        _row('🕐 TIME', timeStr),
                        const SizedBox(height: 24),
                        const Divider(height: 1),
                        const SizedBox(height: 24),
                        Text('ITEMS ORDERED', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.grey, letterSpacing: 2)),
                        const SizedBox(height: 16),
                        ...items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${item.quantity}x', style: GoogleFonts.outfit(color: KioskTheme.lunaBrown, fontWeight: FontWeight.w900, fontSize: 16)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: KioskTheme.lunaBrown)),
                                        if (item.variant.isNotEmpty) Text(item.variant, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500])),
                                      ],
                                    ),
                                  ),
                                  Text('₱${item.price * item.quantity}', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: KioskTheme.lunaBrown)),
                                ],
                              ),
                            )),
                        const Divider(height: 32, thickness: 1),
                        if (!_isPickup && deliveryFee > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('DELIVERY FEE', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.grey[500], letterSpacing: 1)),
                              Text('₱$deliveryFee', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: KioskTheme.lunaBrown)),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('GRAND TOTAL', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: KioskTheme.lunaBrown, letterSpacing: 1)),
                            Text('₱$total', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 36, color: KioskTheme.lunaBrown)),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: KioskTheme.lunaTan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: KioskTheme.lunaTan.withOpacity(0.5)),
                          ),
                          child: Center(
                            child: Text(
                              isWalkIn
                                  ? 'Please show this to the staff.'
                                  : _isPickup
                                      ? 'Please pick up your order at the counter.'
                                      : 'Screenshot this for your records!',
                              style: GoogleFonts.outfit(fontSize: 14, color: KioskTheme.lunaBrown, fontWeight: FontWeight.w700),
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
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: KioskTheme.lunaBrown.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
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
          SizedBox(width: 120, child: Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w900, letterSpacing: 1))),
          Expanded(child: Text(value, style: GoogleFonts.outfit(fontSize: 14, color: KioskTheme.lunaBrown, fontWeight: FontWeight.w700))),
        ],
      );
}
