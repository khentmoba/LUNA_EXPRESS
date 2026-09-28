import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/functions.dart';
import '../widgets/kiosk/kiosk_theme.dart';
import '../widgets/kiosk/juicy_feedback.dart';
import '../widgets/report/report_widgets.dart';

class KdsPage extends StatefulWidget {
  const KdsPage({super.key});

  @override
  State<KdsPage> createState() => _KdsPageState();
}

class _KdsPageState extends State<KdsPage> {
  bool _loading = false;
  List<dynamic> _orders = [];
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchActiveOrders();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchActiveOrders(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchActiveOrders({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    setState(() => _error = null);
    try {
      final data = await callFn('getActiveOrders');
      setState(() {
        if (data['success'] == true) {
          _orders = data['orders'] as List<dynamic>;
        } else {
          _error = data['message'] ?? 'Failed to load active orders.';
        }
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Error connecting to server. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    setState(() => _loading = true);
    try {
      final data = await callFn('updateOrderStatus', {
        'orderId': orderId,
        'status': newStatus,
      });
      if (data['success'] == true) {
        await _fetchActiveOrders(silent: true);
        if (mounted)
          _snack('Order status updated to $newStatus', KioskTheme.success);
      } else {
        setState(() => _loading = false);
        if (mounted) _snack('Error: ${data['message']}', KioskTheme.warning);
      }
    } catch (_) {
      setState(() => _loading = false);
      if (mounted) {
        _snack('Failed to update status. Connection error.', KioskTheme.error);
      }
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final pending = _orders.where((o) => o['status'] == 'Pending').toList();
    final preparing = _orders.where((o) => o['status'] == 'Preparing').toList();
    final ready = _orders.where((o) => o['status'] == 'Ready').toList();

    return ReportScaffold(
      title: 'KITCHEN DISPLAY BOARD (KDS)',
      loading: _loading && _orders.isEmpty,
      error: _error,
      onRetry: _fetchActiveOrders,
      onRefresh: _fetchActiveOrders,
      refreshTooltip: 'Refresh Active Orders',
      body: isMobile
          ? DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: KioskTheme.lunaBrown,
                    unselectedLabelColor: KioskTheme.textMuted,
                    indicatorColor: KioskTheme.lunaBrown,
                    labelStyle: KioskTheme.labelLarge.copyWith(fontSize: 14),
                    tabs: [
                      Tab(text: 'PENDING (${pending.length})'),
                      Tab(text: 'PREPARING (${preparing.length})'),
                      Tab(text: 'READY (${ready.length})'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildOrderColumnList(pending, 'Pending'),
                        _buildOrderColumnList(preparing, 'Preparing'),
                        _buildOrderColumnList(ready, 'Ready'),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildKDSColumn(
                      'PENDING QUEUE',
                      pending,
                      'Pending',
                      KioskTheme.warning.withOpacity(0.08),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildKDSColumn(
                      'PREPARING NOW',
                      preparing,
                      'Preparing',
                      KioskTheme.info.withOpacity(0.08),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildKDSColumn(
                      'READY FOR PICKUP',
                      ready,
                      'Ready',
                      KioskTheme.success.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildKDSColumn(
    String title,
    List<dynamic> orders,
    String columnStatus,
    Color headerColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KioskTheme.radiusLg),
        border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(23),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: KioskTheme.labelLarge.copyWith(fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: KioskTheme.badgeBrown,
                  child: Text(
                    '${orders.length}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildOrderColumnList(orders, columnStatus)),
        ],
      ),
    );
  }

  Widget _buildOrderColumnList(List<dynamic> orders, String columnStatus) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              columnStatus == 'Pending'
                  ? Icons.hourglass_empty_rounded
                  : columnStatus == 'Preparing'
                  ? Icons.restaurant_rounded
                  : Icons.done_all_rounded,
              color: Colors.grey[300],
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No orders in this phase',
              style: KioskTheme.bodySmall.copyWith(
                color: Colors.grey[400],
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final orderId = order['id'] as String;
    final orderNum = order['orderId'] as String;
    final customerName = order['customerName'] as String? ?? 'Walk-in Customer';
    final type = order['type'] as String? ?? 'Walk-In';
    final paymentStatus = order['paymentStatus'] as String? ?? 'NOT PAID';
    final status = order['status'] as String;
    final timestampStr = order['timestamp'] as String;
    final items = order['items'] as List<dynamic>? ?? [];

    String displayTime = 'Just now';
    try {
      final parsed = DateTime.parse(timestampStr).toLocal();
      displayTime =
          '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    Color typeColor = Colors.orange;
    IconData typeIcon = Icons.point_of_sale_rounded;
    if (type == 'Delivery') {
      typeColor = Colors.purple;
      typeIcon = Icons.motorcycle_rounded;
    } else if (type == 'Pickup') {
      typeColor = Colors.blue;
      typeIcon = Icons.storefront_rounded;
    }

    String actionLabel = '';
    String nextStatus = '';
    Color actionColor = KioskTheme.lunaBrown;
    if (status == 'Pending') {
      actionLabel = 'START PREPARING';
      nextStatus = 'Preparing';
      actionColor = KioskTheme.info;
    } else if (status == 'Preparing') {
      actionLabel = 'MARK AS READY';
      nextStatus = 'Ready';
      actionColor = KioskTheme.success;
    } else if (status == 'Ready') {
      actionLabel = 'COMPLETE ORDER';
      nextStatus = 'Completed';
      actionColor = KioskTheme.lunaBrown;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
        side: BorderSide(color: KioskTheme.lunaBrown.withOpacity(0.08)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: KioskTheme.badgeBrown,
                  child: Text(
                    '#$orderNum',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  displayTime,
                  style: KioskTheme.bodySmall.copyWith(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(typeIcon, color: typeColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  type.toUpperCase(),
                  style: KioskTheme.labelSmall.copyWith(
                    color: typeColor,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: paymentStatus == 'PAID'
                        ? KioskTheme.success.withOpacity(0.1)
                        : KioskTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
                  ),
                  child: Text(
                    paymentStatus,
                    style: KioskTheme.labelSmall.copyWith(
                      color: paymentStatus == 'PAID'
                          ? KioskTheme.success
                          : KioskTheme.warning,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            KioskTheme.divider(),
            const SizedBox(height: 8),
            Text(
              customerName,
              style: KioskTheme.titleLarge.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 12),
            ...items.map((item) {
              final name = item['name'] as String;
              final qty = item['quantity'] as int;
              final variant = item['variant'] as String?;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${qty}x',
                      style: KioskTheme.titleMedium.copyWith(fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: KioskTheme.bodyLarge.copyWith(fontSize: 13),
                          ),
                          if (variant != null && variant.isNotEmpty)
                            Text(
                              variant,
                              style: KioskTheme.bodySmall.copyWith(
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            JuicyFeedback(
              onPressed: () => _updateStatus(orderId, nextStatus),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: actionColor,
                  borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: actionColor.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    actionLabel,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
