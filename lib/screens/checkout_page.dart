import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/kiosk/kiosk_theme.dart';
import '../widgets/kiosk/juicy_feedback.dart';
import '../models/cart.dart';
import '../services/cart_notifier.dart';
import '../services/telegram_service.dart';
import '../services/order_service.dart';
import '../services/session.dart';
import '../models/order.dart';
import 'map_picker_page.dart';
import 'receipt_page.dart';
import 'gcash_checkout_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  double _pinnedLat = 9.0205090;
  double _pinnedLng = 125.5175910;
  bool _locationPinned = false;
  int _deliveryFee = 0;
  double _distance = 0.0;
  String _paymentMethod = 'Cash';
  String _orderType = 'Pickup';
  bool _loading = false;

  static const _storeLat = 9.0205090;
  static const _storeLng = 125.5175910;
  static const _base2Lat = 9.1212590;
  static const _base2Lng = 125.5429739;

  @override
  void initState() {
    super.initState();
    if (session.isStaff) {
      _orderType = 'Walk-In';
      _paymentMethod = 'Cash';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _needsCoordinates => _orderType == 'Delivery';

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lng2 - lng1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _calculateDeliveryFee(double plat, double plng) {
    final distToStore = _haversine(_storeLat, _storeLng, plat, plng);
    final distToBase2 = _haversine(_base2Lat, _base2Lng, plat, plng);

    setState(() {
      _distance = distToStore <= distToBase2 ? distToStore : distToBase2;
      _deliveryFee = (_distance * 39).round();
    });
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
            builder: (_) => MapPickerPage(
                  initialAddress: _addressCtrl.text,
                  initialLat: _pinnedLat,
                  initialLng: _pinnedLng,
                )));
    if (result != null) {
      setState(() {
        _addressCtrl.text = result['address'] as String;
        _pinnedLat = result['lat'] as double;
        _pinnedLng = result['lng'] as double;
        _locationPinned = true;
      });
      _calculateDeliveryFee(_pinnedLat, _pinnedLng);
    }
  }

  Future<void> _submitOrder() async {
    final name = _nameCtrl.text.trim().isEmpty
        ? (session.isStaff ? 'Walk-in Customer' : '')
        : _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim().isEmpty
        ? (session.isStaff ? 'N/A' : '')
        : _phoneCtrl.text.trim();
    final address = _needsCoordinates ? _addressCtrl.text.trim() : _orderType;

    if (name.isEmpty || (_needsCoordinates && address.isEmpty) || (!session.isStaff && phone.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all required fields!'),
        backgroundColor: KioskTheme.lunaBrown,
      ));
      return;
    }
    setState(() => _loading = true);
    final orderNumber = TelegramService.generateOrderNumber();
    final items = List<CartItem>.from(cartNotifier.items);
    final total = cartNotifier.totalPrice + (_needsCoordinates ? _deliveryFee : 0);
    final now = DateTime.now();
    String pad(int n) => n.toString().padLeft(2, '0');
    final timeStr = '${now.year}-${pad(now.month)}-${pad(now.day)}  ${pad(now.hour)}:${pad(now.minute)}';

    final paymentStatus = session.isStaff
        ? 'PAID'
        : (_paymentMethod == 'GCash' ? 'AWAITING_PAYMENT' : 'NOT PAID');

    final telegramSent = await TelegramService.sendOrder(
      orderNumber: orderNumber,
      customerName: name,
      customerAddress: address,
      customerPhone: phone,
      items: items,
      total: total,
      timeStr: timeStr,
      orderType: _orderType,
      deliveryFee: _needsCoordinates ? _deliveryFee : 0,
      paymentMethod: _paymentMethod,
      paymentStatus: paymentStatus,
      lat: _needsCoordinates ? _pinnedLat : null,
      lng: _needsCoordinates ? _pinnedLng : null,
    );

    await OrderService.saveOrder(OrderModel(
      orderId: orderNumber,
      items: items.map((i) => OrderItem(name: i.name, variant: i.variant, price: i.price, quantity: i.quantity)).toList(),
      totalAmount: total,
      timestamp: now,
      dateLabel: OrderService.getPHTDateLabel(),
      type: _orderType,
      entryType: session.isStaff ? 'Staff' : 'Kiosk',
      customerName: name,
      customerPhone: phone,
      customerAddress: address,
      lat: _needsCoordinates ? _pinnedLat : null,
      lng: _needsCoordinates ? _pinnedLng : null,
      deliveryFee: _needsCoordinates ? _deliveryFee : 0,
      totalDistance: _needsCoordinates ? _distance : 0.0,
      paymentMethod: _paymentMethod,
      paymentStatus: paymentStatus,
      status: 'Pending',
    ));

    // Record in-memory order history for admin dashboard
    orderHistory.add({
      'orderNumber': orderNumber,
      'customerName': name,
      'items': items.map((i) => {
        'name': i.name, 'variant': i.variant,
        'qty': i.quantity, 'price': i.price,
      }).toList(),
      'itemsCount': items.fold(0, (s, i) => s + i.quantity),
      'total': total,
      'time': timeStr,
      'type': _orderType,
      'isWalkIn': session.isStaff,
    });

    cartNotifier.clear();
    setState(() => _loading = false);
    if (!mounted) return;

    // Show Telegram notification status on screen
    TelegramService.showTelegramStatus(context, telegramSent, orderNumber);

    if (_paymentMethod == 'GCash' && !session.isStaff) {
      final serializedItems = items
          .map((i) => {
                'name': i.name,
                'variant': i.variant,
                'price': i.price,
                'quantity': i.quantity,
              })
          .toList();

      final paid = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => GCashCheckoutPage(
            orderId: orderNumber,
            amount: total,
            items: serializedItems,
            customerName: name,
            customerPhone: phone,
          ),
        ),
      );

      if (!mounted) return;
      if (paid == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptPage(
              orderNumber: orderNumber,
              customerName: name,
              customerAddress: address,
              customerPhone: phone,
              items: items,
              total: total,
              timeStr: timeStr,
              isWalkIn: false,
              orderType: _orderType,
              deliveryFee: _needsCoordinates ? _deliveryFee : 0,
            ),
          ),
          (route) => route.isFirst,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('GCash payment was cancelled or failed. Your order is saved but not yet paid.'),
          backgroundColor: KioskTheme.error,
          duration: Duration(seconds: 5),
        ));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CheckoutPage()),
          (route) => route.isFirst,
        );
      }
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptPage(
            orderNumber: orderNumber,
            customerName: name,
            customerAddress: address,
            customerPhone: phone,
            items: items,
            total: total,
            timeStr: timeStr,
            isWalkIn: session.isStaff,
            orderType: _orderType,
            deliveryFee: _needsCoordinates ? _deliveryFee : 0,
          ),
        ),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KioskTheme.lunaCream,
      appBar: AppBar(
        title: Text(
          session.isStaff ? 'POS CHECKOUT' : 'CHECKOUT',
          style: KioskTheme.headerSmall.copyWith(color: KioskTheme.textOnPrimary, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: KioskTheme.lunaBrown,
        foregroundColor: KioskTheme.textOnPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'ORDER SUMMARY',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...cartNotifier.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text('${item.quantity}x', style: KioskTheme.titleMedium.copyWith(fontSize: 15)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text('${item.name}${item.variant.isNotEmpty ? ' (${item.variant})' : ''}',
                                    style: KioskTheme.bodyLarge.copyWith(fontSize: 15),
                                    overflow: TextOverflow.ellipsis)),
                            Text('\u20B1${item.price * item.quantity}', style: KioskTheme.titleMedium.copyWith(fontSize: 15)),
                          ],
                        ),
                      )),
                  KioskTheme.divider(),
                  const SizedBox(height: 16),
                  if (_needsCoordinates && _locationPinned) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('DELIVERY FEE (${_distance.toStringAsFixed(1)}km)',
                            style: KioskTheme.bodyMedium.copyWith(fontSize: 14)),
                        Text('\u20B1$_deliveryFee', style: KioskTheme.titleMedium.copyWith(fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL', style: KioskTheme.headerSmall.copyWith(letterSpacing: 1.5)),
                      Text('\u20B1${cartNotifier.totalPrice + (_needsCoordinates ? _deliveryFee : 0)}',
                          style: KioskTheme.headerLarge.copyWith(fontSize: 32)),
                    ],
                  ),

                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionLabel('ORDER TYPE'),
            const SizedBox(height: 16),
            Row(
              children: [
                if (session.isStaff) ...[
                  Expanded(
                    child: _typeBtn(
                      label: 'Walk-In',
                      icon: Icons.point_of_sale_rounded,
                      selected: _orderType == 'Walk-In',
                      onTap: () => setState(() => _orderType = 'Walk-In'),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: _typeBtn(
                    label: 'Pickup',
                    icon: Icons.storefront_rounded,
                    selected: _orderType == 'Pickup',
                    onTap: () => setState(() => _orderType = 'Pickup'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _typeBtn(
                    label: 'Delivery',
                    icon: Icons.motorcycle_rounded,
                    selected: _orderType == 'Delivery',
                    onTap: () => setState(() => _orderType = 'Delivery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionLabel('PAYMENT METHOD'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _typeBtn(
                    label: 'Cash',
                    icon: Icons.payments_rounded,
                    selected: _paymentMethod == 'Cash',
                    onTap: () => setState(() => _paymentMethod = 'Cash'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _typeBtn(
                    label: 'GCash',
                    icon: Icons.phone_android_rounded,
                    selected: _paymentMethod == 'GCash',
                    onTap: () => setState(() => _paymentMethod = 'GCash'),
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _paymentMethod == 'Cash'
                  ? const SizedBox.shrink()
                  : Container(
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007DFE).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(KioskTheme.radiusLg),
                        border: Border.all(color: const Color(0xFF007DFE).withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.payment_rounded, color: Color(0xFF007DFE)),
                              const SizedBox(width: 12),
                              Text('GCASH VIA PAYMONGO', style: KioskTheme.labelLarge.copyWith(color: const Color(0xFF007DFE))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'You will be redirected to a secure GCash checkout page after confirming your order.',
                            style: KioskTheme.bodyLarge.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Select GCash as your payment method in the checkout page and authorize the payment in the GCash app.',
                            style: KioskTheme.bodyMedium.copyWith(fontSize: 13, color: KioskTheme.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
                              border: Border.all(color: const Color(0xFF007DFE).withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lock_rounded, size: 16, color: Color(0xFF007DFE)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Secured by PayMongo. Funds settle to the merchant\'s bank account.',
                                    style: KioskTheme.bodySmall.copyWith(fontSize: 11, color: KioskTheme.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 32),
            Text(
              _needsCoordinates ? 'DELIVERY DETAILS' : 'CUSTOMER DETAILS',
              style: KioskTheme.labelLarge.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _field(
              ctrl: _nameCtrl,
              label: session.isStaff ? 'FULL NAME (OPTIONAL FOR POS)' : 'FULL NAME',
              icon: Icons.person_rounded,
              hint: session.isStaff ? 'e.g. Walk-in Customer (Default)' : 'e.g. Juan Dela Cruz',
            ),
            const SizedBox(height: 16),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: !_needsCoordinates
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _openMapPicker,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            decoration: BoxDecoration(
                              color: _locationPinned ? KioskTheme.lunaBrown.withOpacity(0.05) : Colors.white,
                              borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
                              border: Border.all(color: _locationPinned ? KioskTheme.lunaBrown : Colors.grey[200]!, width: 2),
                            ),
                            child: Row(
                              children: [
                                Icon(_locationPinned ? Icons.location_on : Icons.add_location_alt_outlined, color: KioskTheme.lunaBrown, size: 24),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _locationPinned ? 'Location pinned on map' : 'Tap to pin your location on map',
                                    style: GoogleFonts.outfit(
                                        color: KioskTheme.lunaBrown, fontSize: 15, fontWeight: _locationPinned ? FontWeight.w900 : FontWeight.w600),
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: KioskTheme.lunaBrown, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _addressCtrl,
                          maxLines: 2,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: KioskTheme.textPrimary),
                          decoration: KioskTheme.inputDecoration(
                            hint: 'Address auto-fills from map...',
                            icon: Icons.edit_location_alt,
                          ).copyWith(
                            prefixIcon: const Icon(Icons.edit_location_alt, color: KioskTheme.lunaBrown, size: 20),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
            ),
            _field(
              ctrl: _phoneCtrl,
              label: session.isStaff ? 'CONTACT NUMBER (OPTIONAL FOR POS)' : 'CONTACT NUMBER',
              icon: Icons.phone_rounded,
              hint: 'e.g. 09XX XXX XXXX',
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 48),
            Builder(
              builder: (context) {
                final isBlocked = _needsCoordinates && !_locationPinned;
                final label = _orderType == 'Walk-In'
                    ? 'CONFIRM POS ORDER'
                    : (_orderType == 'Pickup' ? 'CONFIRM PICKUP ORDER' : 'PLACE DELIVERY ORDER');

                return JuicyFeedback(
                  onPressed: (_loading || isBlocked) ? null : _submitOrder,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: (_loading || isBlocked) ? Colors.grey[400] : KioskTheme.lunaBrown,
                      borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
                      boxShadow: (_loading || isBlocked) ? [] : KioskTheme.shadowPrimary,
                    ),
                    child: Center(
                      child: _loading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text(label, style: KioskTheme.labelLarge.copyWith(color: KioskTheme.textOnPrimary, fontSize: 18)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: KioskTheme.cardWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: KioskTheme.labelLarge.copyWith(fontSize: 16)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: KioskTheme.labelLarge.copyWith(fontSize: 16));
  }

  Widget _typeBtn({required String label, required IconData icon, required bool selected, required VoidCallback onTap}) {
    return JuicyFeedback(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? KioskTheme.lunaBrown : Colors.white,
          borderRadius: BorderRadius.circular(KioskTheme.radiusLg),
          border: Border.all(color: selected ? KioskTheme.lunaBrown : Colors.grey[200]!, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: selected ? Colors.white : KioskTheme.lunaBrown),
            const SizedBox(height: 8),
            Text(label.toUpperCase(), style: GoogleFonts.outfit(color: selected ? Colors.white : KioskTheme.lunaBrown, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }

  Widget _field({required TextEditingController ctrl, required String label, required IconData icon, required String hint, TextInputType keyboard = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: KioskTheme.labelLarge.copyWith(fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: KioskTheme.textPrimary),
          decoration: KioskTheme.inputDecoration(hint: hint, icon: icon),
        ),
      ],
    );
  }
}
