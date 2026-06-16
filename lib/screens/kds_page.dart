import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/kiosk/kiosk_theme.dart';
import '../widgets/kiosk/juicy_feedback.dart';

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
    // Auto-refresh every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchActiveOrders(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchActiveOrders({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('getActiveOrders');
      final result = await callable.call();
      final data = result.data as Map<dynamic, dynamic>;

      if (data['success'] == true) {
        setState(() {
          _orders = data['orders'] as List<dynamic>;
          _loading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Failed to load active orders.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error connecting to server. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    setState(() => _loading = true);
    try {
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('updateOrderStatus');
      final result = await callable.call({
        'orderId': orderId,
        'status': newStatus,
      });
      final data = result.data as Map<dynamic, dynamic>;

      if (data['success'] == true) {
        // Refresh local list
        await _fetchActiveOrders(silent: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order status updated to $newStatus', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        setState(() => _loading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${data['message']}', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status. Connection error.', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    
    // Categorize orders
    final pendingOrders = _orders.where((o) => o['status'] == 'Pending').toList();
    final preparingOrders = _orders.where((o) => o['status'] == 'Preparing').toList();
    final readyOrders = _orders.where((o) => o['status'] == 'Ready').toList();

    return Scaffold(
      backgroundColor: KioskTheme.lunaCream,
      appBar: AppBar(
        title: Text(
          'KITCHEN DISPLAY BOARD (KDS)',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            color: KioskTheme.lunaTan,
            fontSize: 20,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: KioskTheme.lunaBrown,
        foregroundColor: KioskTheme.lunaTan,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Active Orders',
            onPressed: () => _fetchActiveOrders(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading && _orders.isEmpty
          ? const Center(child: CircularProgressIndicator(color: KioskTheme.lunaBrown))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: GoogleFonts.outfit(color: KioskTheme.lunaBrown, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _fetchActiveOrders(),
                        style: ElevatedButton.styleFrom(backgroundColor: KioskTheme.lunaBrown),
                        child: Text('Retry', style: GoogleFonts.outfit(color: Colors.white)),
                      )
                    ],
                  ),
                )
              : isMobile
                  ? DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: KioskTheme.lunaBrown,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: KioskTheme.lunaBrown,
                            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
                            tabs: [
                              Tab(text: 'PENDING (${pendingOrders.length})'),
                              Tab(text: 'PREPARING (${preparingOrders.length})'),
                              Tab(text: 'READY (${readyOrders.length})'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildOrderColumnList(pendingOrders, 'Pending'),
                                _buildOrderColumnList(preparingOrders, 'Preparing'),
                                _buildOrderColumnList(readyOrders, 'Ready'),
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
                          Expanded(child: _buildKDSColumn('PENDING QUEUE', pendingOrders, 'Pending', Colors.red.withOpacity(0.08))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildKDSColumn('PREPARING NOW', preparingOrders, 'Preparing', Colors.blue.withOpacity(0.08))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildKDSColumn('READY FOR PICKUP', readyOrders, 'Ready', Colors.green.withOpacity(0.08))),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildKDSColumn(String title, List<dynamic> orders, String columnStatus, Color headerColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: KioskTheme.lunaBrown,
                    letterSpacing: 1.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: KioskTheme.lunaBrown,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                )
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
              style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
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

    // Parse time
    String displayTime = 'Just now';
    try {
      final parsed = DateTime.parse(timestampStr).toLocal();
      displayTime = '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
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

    // Action config
    String actionLabel = '';
    String nextStatus = '';
    Color actionColor = KioskTheme.lunaBrown;

    if (status == 'Pending') {
      actionLabel = 'START PREPARING';
      nextStatus = 'Preparing';
      actionColor = Colors.blue;
    } else if (status == 'Preparing') {
      actionLabel = 'MARK AS READY';
      nextStatus = 'Ready';
      actionColor = Colors.green;
    } else if (status == 'Ready') {
      actionLabel = 'COMPLETE ORDER';
      nextStatus = 'Completed';
      actionColor = KioskTheme.lunaBrown;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: KioskTheme.lunaBrown.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: KioskTheme.lunaBrown,
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                  style: GoogleFonts.outfit(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w700,
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
                  style: GoogleFonts.outfit(
                    color: typeColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: paymentStatus == 'PAID' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    paymentStatus,
                    style: GoogleFonts.outfit(
                      color: paymentStatus == 'PAID' ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            Text(
              customerName,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: KioskTheme.lunaBrown,
              ),
            ),
            const SizedBox(height: 12),
            // Items List
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
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        color: KioskTheme.lunaBrown,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              color: KioskTheme.lunaBrown,
                              fontSize: 13,
                            ),
                          ),
                          if (variant != null && variant.isNotEmpty)
                            Text(
                              variant,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            // Action Button
            JuicyFeedback(
              onPressed: () => _updateStatus(orderId, nextStatus),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: actionColor,
                  borderRadius: BorderRadius.circular(16),
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
            )
          ],
        ),
      ),
    );
  }
}
