import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/functions.dart';
import '../services/session.dart';
import '../services/audio_alert_service.dart';
import '../services/url_helper.dart';
import '../widgets/kiosk/kiosk_theme.dart';
import '../widgets/kiosk/juicy_feedback.dart';
import 'admin_dashboard.dart';
import 'menu_page.dart';
import 'staff_login_dialog.dart';

class KdsPage extends StatefulWidget {
  const KdsPage({super.key});

  @override
  State<KdsPage> createState() => _KdsPageState();
}

class _KdsPageState extends State<KdsPage> with SingleTickerProviderStateMixin {
  bool _loading = false;
  List<dynamic> _orders = [];
  String? _error;
  Timer? _refreshTimer;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  int _secondsUntilSync = 10;
  String _typeFilter = 'ALL'; // ALL, Delivery, Pickup, Walk-In
  bool _showCompleted = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  Set<String> _knownPendingOrderIds = {};
  bool _hasInitialFetchDone = false;
  final Set<String> _checkedItemKeys = {};

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchActiveOrders();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsUntilSync > 1) {
          _secondsUntilSync--;
        } else {
          _secondsUntilSync = 10;
          _fetchActiveOrders(silent: true);
        }
      });
    });

    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _clockTimer?.cancel();
    _tabController?.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchActiveOrders({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    setState(() => _error = null);

    try {
      final data = await callFn('getActiveOrders', {
        'includeCompleted': _showCompleted,
      });

      if (!mounted) return;

      if (data['success'] == true) {
        final freshOrders = (data['orders'] as List<dynamic>?) ?? [];
        _checkNewOrdersAndChime(freshOrders);
        setState(() {
          _orders = freshOrders;
          _loading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Failed to load active orders.';
          _loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (_orders.isEmpty) {
          _orders = _sampleKdsOrders();
        }
        _loading = false;
      });
    }
  }

  static List<dynamic> _sampleKdsOrders() => [
    {
      'id': 'ord_del_101',
      'orderNumber': '2026-10-24-001',
      'customerName': 'Maria Santos',
      'customerPhone': '09171234567',
      'customerAddress': 'Purok 5, Magallanes (Near 7/11)',
      'lat': 9.0163,
      'lng': 125.5186,
      'deliveryFee': 0,
      'paymentMethod': 'GCash',
      'paymentStatus': 'PAID',
      'type': 'Delivery',
      'status': 'Pending',
      'timestamp': DateTime.now()
          .subtract(const Duration(minutes: 3))
          .toIso8601String(),
      'total': 198,
      'items': [
        {
          'name': 'Shawarma Rice Bowl',
          'quantity': 2,
          'variant': 'Spicy',
          'price': 50,
        },
        {
          'name': 'Fries & Nachos Overload',
          'quantity': 1,
          'variant': 'Buddy (1-2 pax)',
          'price': 98,
        },
      ],
    },
    {
      'id': 'ord_prep_102',
      'orderNumber': '2026-10-24-002',
      'customerName': 'Juan Dela Cruz',
      'customerPhone': '09289876543',
      'customerAddress': '',
      'lat': null,
      'lng': null,
      'deliveryFee': 0,
      'paymentMethod': 'Cash',
      'paymentStatus': 'NOT PAID',
      'type': 'Pickup',
      'status': 'Preparing',
      'timestamp': DateTime.now()
          .subtract(const Duration(minutes: 9))
          .toIso8601String(),
      'total': 99,
      'items': [
        {
          'name': 'Buy 1 Take 1 Burger Favorites',
          'quantity': 1,
          'variant': 'Regular',
          'price': 99,
        },
      ],
    },
    {
      'id': 'ord_rdy_103',
      'orderNumber': '2026-10-24-003',
      'customerName': 'Counter Customer',
      'customerPhone': '',
      'customerAddress': '',
      'lat': null,
      'lng': null,
      'deliveryFee': 0,
      'paymentMethod': 'Cash',
      'paymentStatus': 'PAID',
      'type': 'Walk-In',
      'entryType': 'Staff',
      'status': 'Ready',
      'timestamp': DateTime.now()
          .subtract(const Duration(minutes: 14))
          .toIso8601String(),
      'total': 98,
      'items': [
        {
          'name': 'Solo Halo-Halo Special',
          'quantity': 2,
          'variant': '',
          'price': 49,
        },
      ],
    },
  ];

  void _checkNewOrdersAndChime(List<dynamic> freshOrders) {
    final pendingOrders = freshOrders
        .where((o) => o['status'] == 'Pending')
        .toList();
    final freshPendingIds = pendingOrders
        .map((o) => (o['id'] ?? o['orderNumber']).toString())
        .toSet();

    if (_hasInitialFetchDone) {
      final newArrivals = freshPendingIds.difference(_knownPendingOrderIds);
      if (newArrivals.isNotEmpty) {
        AudioAlertService.playOrderChime();
        if (mounted) {
          _snack(
            '🔔 NEW ORDER RECEIVED (${newArrivals.length} incoming)!',
            KioskTheme.warning,
          );
        }
      }
    }
    _knownPendingOrderIds = freshPendingIds;
    _hasInitialFetchDone = true;
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    setState(() => _loading = true);
    try {
      final data = await callFn('updateOrderStatus', {
        'orderId': orderId,
        'status': newStatus,
      });

      if (!mounted) return;

      if (data['success'] == true) {
        await _fetchActiveOrders(silent: true);
        if (mounted) {
          _snack('Order updated: $newStatus', KioskTheme.success);
        }
      } else {
        setState(() => _loading = false);
        if (mounted) {
          _snack('Error: ${data['message']}', KioskTheme.warning);
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('Failed to update status. Connection error.', KioskTheme.error);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatElapsed(String timestampStr) {
    try {
      final orderTime = DateTime.parse(timestampStr).toLocal();
      final diff = _now.difference(orderTime);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      final hours = diff.inHours;
      final remMins = diff.inMinutes % 60;
      return '${hours}h ${remMins}m ago';
    } catch (_) {
      return '';
    }
  }

  Color _getElapsedColor(String timestampStr) {
    try {
      final orderTime = DateTime.parse(timestampStr).toLocal();
      final diff = _now.difference(orderTime);
      if (diff.inMinutes >= 15) return KioskTheme.error;
      if (diff.inMinutes >= 8) return Colors.orange[800]!;
      return Colors.grey[700]!;
    } catch (_) {
      return Colors.grey[700]!;
    }
  }

  List<dynamic> _filterOrders(List<dynamic> list) {
    var res = list;
    if (_typeFilter != 'ALL') {
      res = res.where((o) {
        final type = (o['type'] as String? ?? '').toLowerCase();
        if (_typeFilter == 'Delivery') return type.contains('delivery');
        if (_typeFilter == 'Pickup') return type.contains('pickup');
        if (_typeFilter == 'Walk-In') {
          final entryType = (o['entryType'] as String? ?? '').toLowerCase();
          return type.contains('walk-in') || entryType.contains('staff');
        }
        return true;
      }).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      res = res.where((o) {
        final num = (o['orderNumber'] as String? ?? '').toLowerCase();
        final name = (o['customerName'] as String? ?? '').toLowerCase();
        final phone = (o['customerPhone'] as String? ?? '').toLowerCase();
        final addr = (o['customerAddress'] as String? ?? '').toLowerCase();
        final items = (o['items'] as List<dynamic>? ?? [])
            .map((i) => (i['name'] as String? ?? '').toLowerCase())
            .join(' ');
        return num.contains(q) ||
            name.contains(q) ||
            phone.contains(q) ||
            addr.contains(q) ||
            items.contains(q);
      }).toList();
    }
    return res;
  }

  void _copyRiderDispatchNote(dynamic order) {
    final orderNum = order['orderNumber'] ?? order['id'];
    final name = order['customerName'] ?? 'Customer';
    final phone = (order['customerPhone'] as String?)?.trim() ?? '';
    final addr = (order['customerAddress'] as String?)?.trim() ?? '';
    final lat = order['lat'];
    final lng = order['lng'];
    final total = order['total'] ?? 0;
    final paymentMethod = order['paymentMethod'] ?? 'Cash';
    final isPaid =
        (order['paymentStatus'] as String? ?? '').toUpperCase() == 'PAID';
    final items = (order['items'] as List<dynamic>? ?? [])
        .map(
          (i) =>
              '  • ${(i['quantity'] ?? i['qty'] ?? 1)}x ${i['name']}${i['variant'] != null && (i['variant'] as String).isNotEmpty ? ' (${i['variant']})' : ''}',
        )
        .join('\n');

    final mapsLink = (lat != null && lng != null)
        ? 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'
        : '';

    final note = [
      '🛵 *LUNA EXPRESS DELIVERY — #$orderNum*',
      '👤 Customer: $name',
      if (phone.isNotEmpty) '📞 Phone: $phone',
      if (addr.isNotEmpty) '📍 Address: $addr',
      if (mapsLink.isNotEmpty) '🗺 Navigation: $mapsLink',
      '',
      '🛒 *Items:*',
      items,
      '',
      '💰 Food Total: ₱$total (${isPaid ? 'PAID ($paymentMethod)' : 'COLLECT ₱$total'})',
      '🚚 Delivery fee: Confirmed by rider upon delivery',
    ].join('\n');

    Clipboard.setData(ClipboardData(text: note));
    _snack(
      '📋 Delivery dispatch note copied to clipboard!',
      KioskTheme.success,
    );
  }

  void _showPrintTicketDialog(dynamic order) {
    final orderNum = order['orderNumber'] ?? order['id'];
    final name = order['customerName'] ?? 'Customer';
    final phone = (order['customerPhone'] as String?)?.trim() ?? '';
    final addr = (order['customerAddress'] as String?)?.trim() ?? '';
    final type = (order['type'] as String? ?? 'Walk-In').toUpperCase();
    final total = order['total'] ?? 0;
    final paymentStatus = (order['paymentStatus'] as String? ?? 'NOT PAID')
        .toUpperCase();
    final paymentMethod = order['paymentMethod'] ?? 'Cash';
    final items = order['items'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
        ),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: KioskTheme.lunaBrown),
            const SizedBox(width: 8),
            Text(
              'Kitchen Slip Ticket',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'LUNA BITES & DELIGHTS',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Purok 5, Magallanes · KITCHEN SLIP',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '#$orderNum',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      type,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: Colors.purple[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '--------------------------------',
                textAlign: TextAlign.center,
              ),
              Text(
                'Customer: $name',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              if (phone.isNotEmpty)
                Text('Phone: $phone', style: GoogleFonts.outfit(fontSize: 11)),
              if (addr.isNotEmpty)
                Text('Address: $addr', style: GoogleFonts.outfit(fontSize: 11)),
              const Text(
                '--------------------------------',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              ...items.map(
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i['quantity'] ?? i['qty'] ?? 1}x ',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              i['name'] ?? '',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            if (i['variant'] != null &&
                                (i['variant'] as String).isNotEmpty)
                              Text(
                                i['variant'],
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '--------------------------------',
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL:',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '₱$total ($paymentStatus)',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                'Payment: $paymentMethod',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: KioskTheme.lunaBrown,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              openUrlInBrowser('javascript:window.print()');
              _snack('Print dialog opened', KioskTheme.success);
            },
            icon: const Icon(
              Icons.print_rounded,
              color: Colors.white,
              size: 16,
            ),
            label: const Text('Print', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionWatcher = context.watch<Session>();

    // If staff is not logged in, prompt authentication immediately
    if (!sessionWatcher.isStaff) {
      return _buildStaffAuthGate();
    }

    final isMobile = MediaQuery.of(context).size.width < 960;
    final filtered = _filterOrders(_orders);

    final pending = filtered.where((o) => o['status'] == 'Pending').toList();
    final preparing = filtered
        .where((o) => o['status'] == 'Preparing')
        .toList();
    final ready = filtered.where((o) => o['status'] == 'Ready').toList();
    final completed = filtered
        .where((o) => o['status'] == 'Completed' || o['status'] == 'Cancelled')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EE),
      appBar: _buildAppBar(
        context,
        pending.length,
        preparing.length,
        ready.length,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildControlBar(pending.length, preparing.length, ready.length),
            if (_error != null) _buildErrorBanner(),
            Expanded(
              child: isMobile
                  ? _buildMobileTabViews(pending, preparing, ready, completed)
                  : _buildDesktopKanbanBoard(pending, preparing, ready),
            ),
          ],
        ),
      ),
    );
  }

  // ── Staff Auth Gate ─────────────────────────────────────────
  Widget _buildStaffAuthGate() {
    return const Scaffold(
      backgroundColor: Color(0xFF1B130D),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: StaffLoginDialog(),
        ),
      ),
    );
  }

  // ── Top Navigation App Bar ──────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    int pendingCount,
    int prepCount,
    int readyCount,
  ) {
    final sessionWatcher = context.watch<Session>();
    return AppBar(
      backgroundColor: const Color(0xFF241A12),
      foregroundColor: const Color(0xFFF7EEDD),
      elevation: 2,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFDEC995).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🌙', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LUNA LIVE OPERATIONS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: const Color(0xFFF7EEDD),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Purok 5 Kiosk · Syncing in ${_secondsUntilSync}s',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: const Color(0xFFDEC995).withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: sessionWatcher.isAdmin
                            ? const Color(0xFFEAB308).withValues(alpha: 0.2)
                            : const Color(0xFF22C55E).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          KioskTheme.radiusSm,
                        ),
                        border: Border.all(
                          color: sessionWatcher.isAdmin
                              ? const Color(0xFFEAB308)
                              : const Color(0xFF22C55E),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        sessionWatcher.isAdmin ? '👑 ADMIN' : 'STAFF',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: sessionWatcher.isAdmin
                              ? const Color(0xFFFDE047)
                              : const Color(0xFF86EFAC),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Sound Chime Toggle & Test
        IconButton(
          tooltip: AudioAlertService.soundEnabled
              ? 'Audio Alerts: ON (Tap to Mute)'
              : 'Audio Alerts: MUTED (Tap to Enable)',
          icon: Icon(
            AudioAlertService.soundEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            color: AudioAlertService.soundEnabled
                ? const Color(0xFFDEC995)
                : Colors.grey,
            size: 22,
          ),
          onPressed: () {
            setState(() {
              AudioAlertService.soundEnabled = !AudioAlertService.soundEnabled;
            });
            if (AudioAlertService.soundEnabled) {
              AudioAlertService.playOrderChime();
              _snack('Audio Alert Enabled (Chime tested)', KioskTheme.success);
            } else {
              _snack('Audio Alert Muted', Colors.grey[700]!);
            }
          },
        ),

        // Manual Refresh
        IconButton(
          tooltip: 'Sync Orders Now',
          icon: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFDEC995),
                  ),
                )
              : const Icon(
                  Icons.sync_rounded,
                  color: Color(0xFFDEC995),
                  size: 22,
                ),
          onPressed: _loading
              ? null
              : () {
                  _secondsUntilSync = 10;
                  _fetchActiveOrders();
                },
        ),

        const SizedBox(width: 4),

        // Walk-in Order Button
        JuicyFeedback(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KioskMenuPage()),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.point_of_sale_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'POS WALK-IN',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Admin Dashboard Link
        IconButton(
          tooltip: 'Sales Analytics & Admin',
          icon: const Icon(
            Icons.bar_chart_rounded,
            color: Color(0xFFF7EEDD),
            size: 22,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
          },
        ),

        // Logout
        IconButton(
          tooltip: 'Exit Staff Portal',
          icon: Icon(Icons.logout_rounded, color: Colors.red[300], size: 20),
          onPressed: () {
            session.logout();
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Filter and Summary Control Bar ──────────────────────────
  Widget _buildControlBar(int pendingCount, int prepCount, int readyCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          // Filter Chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('ALL'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Delivery', icon: Icons.motorcycle_rounded),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pickup', icon: Icons.storefront_rounded),
                  const SizedBox(width: 8),
                  _buildFilterChip('Walk-In', icon: Icons.shopping_bag_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Search box
          Container(
            width: 160,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: GoogleFonts.outfit(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search orders...',
                hintStyle: GoogleFonts.outfit(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(
                          Icons.clear_rounded,
                          size: 14,
                          color: Colors.grey,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Completed toggle
          InkWell(
            onTap: () {
              setState(() {
                _showCompleted = !_showCompleted;
              });
              _fetchActiveOrders();
            },
            borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _showCompleted
                    ? KioskTheme.lunaBrown.withValues(alpha: 0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
                border: Border.all(
                  color: _showCompleted
                      ? KioskTheme.lunaBrown
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _showCompleted
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    size: 16,
                    color: _showCompleted
                        ? KioskTheme.lunaBrown
                        : KioskTheme.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'History',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _showCompleted
                          ? KioskTheme.lunaBrown
                          : KioskTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {IconData? icon}) {
    final isSelected = _typeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _typeFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF241A12) : Colors.grey[100],
          borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? const Color(0xFFDEC995) : Colors.grey[600],
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isSelected ? const Color(0xFFF7EEDD) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: KioskTheme.error.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: KioskTheme.error,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: GoogleFonts.outfit(
                color: KioskTheme.error,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _fetchActiveOrders(),
            child: Text(
              'RETRY',
              style: GoogleFonts.outfit(
                color: KioskTheme.error,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Desktop 3-Column Kanban Board Layout ────────────────────
  Widget _buildDesktopKanbanBoard(
    List<dynamic> pending,
    List<dynamic> preparing,
    List<dynamic> ready,
  ) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Pending Queue
          Expanded(
            child: _buildColumnContainer(
              title: '1. PENDING QUEUE',
              orders: pending,
              columnStatus: 'Pending',
              headerBg: const Color(0xFFFFF7ED),
              accentColor: const Color(0xFFEA580C),
              icon: Icons.hourglass_top_rounded,
            ),
          ),
          const SizedBox(width: 16),

          // 2. Preparing Now
          Expanded(
            child: _buildColumnContainer(
              title: '2. PREPARING NOW',
              orders: preparing,
              columnStatus: 'Preparing',
              headerBg: const Color(0xFFEFF6FF),
              accentColor: const Color(0xFF2563EB),
              icon: Icons.outdoor_grill_rounded,
            ),
          ),
          const SizedBox(width: 16),

          // 3. Ready For Pickup / Rider
          Expanded(
            child: _buildColumnContainer(
              title: '3. READY FOR PICKUP / RIDER',
              orders: ready,
              columnStatus: 'Ready',
              headerBg: const Color(0xFFF0FDF4),
              accentColor: const Color(0xFF16A34A),
              icon: Icons.done_all_rounded,
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile / Tablet Segmented Tab Views ─────────────────────
  Widget _buildMobileTabViews(
    List<dynamic> pending,
    List<dynamic> preparing,
    List<dynamic> ready,
    List<dynamic> completed,
  ) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF241A12),
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: const Color(0xFFA3301A),
            indicatorWeight: 3,
            labelStyle: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('PENDING'),
                    const SizedBox(width: 6),
                    _buildCountBadge(pending.length, const Color(0xFFEA580C)),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('COOKING'),
                    const SizedBox(width: 6),
                    _buildCountBadge(preparing.length, const Color(0xFF2563EB)),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('READY'),
                    const SizedBox(width: 6),
                    _buildCountBadge(ready.length, const Color(0xFF16A34A)),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('DONE'),
                    const SizedBox(width: 6),
                    _buildCountBadge(completed.length, Colors.grey[600]!),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(pending, 'Pending'),
              _buildOrdersList(preparing, 'Preparing'),
              _buildOrdersList(ready, 'Ready'),
              _buildOrdersList(completed, 'Completed'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }

  // ── Column Container ────────────────────────────────────────
  Widget _buildColumnContainer({
    required String title,
    required List<dynamic> orders,
    required String columnStatus,
    required Color headerBg,
    required Color accentColor,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
              border: Border(
                bottom: BorderSide(color: accentColor.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1,
                      color: accentColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
                  ),
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
          // Scrollable Orders List
          Expanded(child: _buildOrdersList(orders, columnStatus)),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<dynamic> orders, String columnStatus) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                columnStatus == 'Pending'
                    ? Icons.hourglass_empty_rounded
                    : columnStatus == 'Preparing'
                    ? Icons.outdoor_grill_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.grey[300],
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                columnStatus == 'Pending'
                    ? 'No pending orders waiting.'
                    : columnStatus == 'Preparing'
                    ? 'Grill & fryer are clear.'
                    : 'No orders ready for pickup.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.grey[500],
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  // ── Order Card Component ────────────────────────────────────
  Widget _buildOrderCard(dynamic order) {
    final orderId = order['id'] as String;
    final orderNum = order['orderNumber'] as String? ?? orderId;
    final customerName =
        (order['customerName'] as String?)?.trim() ?? 'Customer';
    final customerPhone = (order['customerPhone'] as String?)?.trim() ?? '';
    final customerAddress = (order['customerAddress'] as String?)?.trim() ?? '';
    final lat = order['lat'] as double?;
    final lng = order['lng'] as double?;
    final type = order['type'] as String? ?? 'Walk-In';
    final paymentStatus = (order['paymentStatus'] as String? ?? 'NOT PAID')
        .toUpperCase();
    final paymentMethod = order['paymentMethod'] as String? ?? 'Cash';
    final status = order['status'] as String? ?? 'Pending';
    final timestampStr = order['timestamp'] as String? ?? '';
    final items = order['items'] as List<dynamic>? ?? [];
    final total = order['total'] ?? 0;

    final isDelivery = type.toLowerCase().contains('delivery');
    final isPickup = type.toLowerCase().contains('pickup');

    final elapsedText = _formatElapsed(timestampStr);
    final elapsedColor = _getElapsedColor(timestampStr);

    final isPaid = paymentStatus == 'PAID';
    final isDelayed =
        status == 'Pending' &&
        _now.difference(DateTime.tryParse(timestampStr) ?? _now).inMinutes >=
            10;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
        border: Border.all(
          color: isDelayed
              ? const Color(0xFFD8452A)
              : status == 'Pending'
              ? const Color(0xFFEA580C).withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.08),
          width: isDelayed
              ? 2.0
              : status == 'Pending'
              ? 1.5
              : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Order # and Elapsed Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF241A12),
                        borderRadius: BorderRadius.circular(
                          KioskTheme.radiusSm,
                        ),
                      ),
                      child: Text(
                        '#$orderNum',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFF7EEDD),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Kitchen Slip Ticket',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 26,
                        minHeight: 26,
                      ),
                      icon: const Icon(
                        Icons.receipt_long_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onPressed: () => _showPrintTicketDialog(order),
                    ),
                    if (isDelivery)
                      IconButton(
                        tooltip: 'Copy Delivery Dispatch Note',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 26,
                          minHeight: 26,
                        ),
                        icon: const Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: Colors.grey,
                        ),
                        onPressed: () => _copyRiderDispatchNote(order),
                      ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDelayed
                        ? KioskTheme.error.withValues(alpha: 0.15)
                        : elapsedColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
                    border: isDelayed
                        ? Border.all(
                            color: KioskTheme.error.withValues(alpha: 0.4),
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDelayed
                            ? Icons.warning_amber_rounded
                            : Icons.access_time_rounded,
                        size: 13,
                        color: isDelayed ? KioskTheme.error : elapsedColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isDelayed ? 'DELAYED ($elapsedText)' : elapsedText,
                        style: GoogleFonts.outfit(
                          color: isDelayed ? KioskTheme.error : elapsedColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Order Type & Payment Status Badge
            Row(
              children: [
                // Type Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDelivery
                        ? Colors.purple.withValues(alpha: 0.1)
                        : isPickup
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDelivery
                            ? Icons.motorcycle_rounded
                            : isPickup
                            ? Icons.storefront_rounded
                            : Icons.shopping_bag_rounded,
                        size: 13,
                        color: isDelivery
                            ? Colors.purple[800]
                            : isPickup
                            ? Colors.blue[800]
                            : Colors.green[800],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        type.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: isDelivery
                              ? Colors.purple[800]
                              : isPickup
                              ? Colors.blue[800]
                              : Colors.green[800],
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Payment Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                        : const Color(0xFFEA580C).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
                  ),
                  child: Text(
                    isPaid
                        ? 'PAID ($paymentMethod)'
                        : 'UNPAID · COLLECT ₱$total',
                    style: GoogleFonts.outfit(
                      color: isPaid
                          ? const Color(0xFF15803D)
                          : const Color(0xFFC2410C),
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Customer Name & Phone
            Row(
              children: [
                Expanded(
                  child: Text(
                    customerName,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF241A12),
                    ),
                  ),
                ),
                if (customerPhone.isNotEmpty)
                  InkWell(
                    onTap: () => openUrlInBrowser('tel:$customerPhone'),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone_rounded,
                            size: 14,
                            color: Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            customerPhone,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Delivery Address & Maps Button (if Delivery)
            if (isDelivery && customerAddress.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 15,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        customerAddress,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (lat != null && lng != null)
                      InkWell(
                        onTap: () => openUrlInBrowser(
                          'https://www.google.com/maps?q=$lat,$lng',
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'MAP',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 10),

            // Item Checklist
            ...items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final name = item['name'] as String? ?? 'Item';
              final qty = (item['quantity'] ?? item['qty'] ?? 1) as int;
              final variant = item['variant'] as String?;
              final itemKey = '${orderId}_$idx';
              final isChecked = _checkedItemKeys.contains(itemKey);

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isChecked) {
                      _checkedItemKeys.remove(itemKey);
                    } else {
                      _checkedItemKeys.add(itemKey);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isChecked
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        size: 18,
                        color: isChecked
                            ? const Color(0xFF16A34A)
                            : Colors.grey[400],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${qty}x',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isChecked
                              ? Colors.grey[400]
                              : const Color(0xFF241A12),
                          decoration: isChecked
                              ? TextDecoration.lineThrough
                              : null,
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
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isChecked
                                    ? Colors.grey[400]
                                    : const Color(0xFF241A12),
                                decoration: isChecked
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (variant != null && variant.isNotEmpty)
                              Text(
                                variant,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: isChecked
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 14),

            // Order Total and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isDelivery ? 'FOOD TOTAL: ₱$total' : 'TOTAL: ₱$total',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF241A12),
                  ),
                ),
                if (status == 'Pending')
                  TextButton(
                    onPressed: () => _confirmCancelOrder(orderId, orderNum),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.outfit(
                        color: Colors.red[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Primary Flow Status Button
            _buildStatusActionButton(orderId, status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusActionButton(String orderId, String currentStatus) {
    String label = '';
    String nextStatus = '';
    Color buttonColor = const Color(0xFFA3301A);
    IconData icon = Icons.arrow_forward_rounded;

    if (currentStatus == 'Pending') {
      label = 'START PREPARING';
      nextStatus = 'Preparing';
      buttonColor = const Color(0xFF2563EB); // Blue
      icon = Icons.outdoor_grill_rounded;
    } else if (currentStatus == 'Preparing') {
      label = 'MARK AS READY';
      nextStatus = 'Ready';
      buttonColor = const Color(0xFF16A34A); // Green
      icon = Icons.done_all_rounded;
    } else if (currentStatus == 'Ready') {
      label = 'COMPLETE & DISPATCH';
      nextStatus = 'Completed';
      buttonColor = const Color(0xFF241A12); // Dark brown
      icon = Icons.task_alt_rounded;
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        child: Text(
          'ORDER $currentStatus',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      );
    }

    return JuicyFeedback(
      onPressed: () => _updateStatus(orderId, nextStatus),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancelOrder(String orderId, String orderNum) {
    String selectedReason = 'Item Out of Stock';
    final reasons = [
      'Item Out of Stock',
      'Customer Requested Cancellation',
      'Duplicate / Test Order',
      'Store Closing / Capacity',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            'Cancel Order #$orderNum?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select cancellation reason:',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              ...reasons.map(
                (r) => RadioListTile<String>(
                  title: Text(r, style: GoogleFonts.outfit(fontSize: 13)),
                  value: r,
                  groupValue: selectedReason,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedReason = v);
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Back'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: KioskTheme.error,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _updateStatus(orderId, 'Cancelled');
              },
              child: const Text(
                'Confirm Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
