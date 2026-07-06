import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/session.dart';
import '../services/cart_notifier.dart';
import '../widgets/kiosk/kiosk_theme.dart';
import '../widgets/kiosk/juicy_feedback.dart';
import 'menu_page.dart';
import 'analytics_page.dart';
import 'lifetime_analytics_page.dart';
import 'kds_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  void _logout() {
    session.logout();
    cartNotifier.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _goToWalkIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const KioskMenuPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final recentOrders = orderHistory.reversed.take(10).toList();

    return Scaffold(
      backgroundColor: KioskTheme.lunaCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              _buildSectionTitle("TODAY'S OVERVIEW"),
              const SizedBox(height: 16),
              _buildStatsGrid(),
              const SizedBox(height: 32),
              _buildWalkInButton(),
              const SizedBox(height: 32),
              _buildSectionTitle('QUICK ACTIONS'),
              const SizedBox(height: 16),
              _buildQuickActions(context, isMobile),
              const SizedBox(height: 32),
              _buildSectionTitle('RECENT ORDERS'),
              const SizedBox(height: 16),
              if (recentOrders.isEmpty)
                _buildEmptyState()
              else
                ...recentOrders.map((o) => _buildOrderTile(o)),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: KioskTheme.brandGradient,
        borderRadius: BorderRadius.circular(KioskTheme.radiusLg),
        boxShadow: KioskTheme.shadowPrimary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                ),
                child: const Center(child: Text('🌙', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Luna Bites & Delights',
                      style: GoogleFonts.outfit(
                        color: KioskTheme.textOnPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Welcome, ${session.username}!',
                      style: GoogleFonts.outfit(
                        color: KioskTheme.textOnPrimary.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              JuicyFeedback(
                onPressed: _logout,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.white.withOpacity(0.9), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Logout',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
            ),
            child: Text(
              'ADMIN DASHBOARD',
              style: GoogleFonts.outfit(
                color: KioskTheme.textOnPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Title ──────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: KioskTheme.labelLarge.copyWith(
        color: KioskTheme.textMuted,
        fontSize: 13,
      ),
    );
  }

  // ── Stats Grid ─────────────────────────────────────────────
  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (_, constraints) => Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          _statCard(
            '💰 Today\'s Sales',
            '₱${todayRevenue}',
            Icons.trending_up_rounded,
            KioskTheme.success,
            (constraints.maxWidth - 14) / 2,
          ),
          _statCard(
            '📋 Orders',
            '${todayOrderCount}',
            Icons.receipt_long_rounded,
            KioskTheme.info,
            (constraints.maxWidth - 14) / 2,
          ),
          _statCard(
            '📊 Avg Order',
            '₱${avgOrderValue.toStringAsFixed(0)}',
            Icons.analytics_rounded,
            Colors.purple,
            (constraints.maxWidth - 14) / 2,
          ),
          _statCard(
            '🛒 Items Sold',
            '$todayItemsSold',
            Icons.shopping_bag_rounded,
            const Color(0xFFFF8C00),
            (constraints.maxWidth - 14) / 2,
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, double cardWidth) {
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
        border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.06)),
        boxShadow: KioskTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: KioskTheme.headerMedium.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: KioskTheme.bodySmall.copyWith(
              fontSize: 11,
              color: KioskTheme.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Walk-in Button ─────────────────────────────────────────
  Widget _buildWalkInButton() {
    return JuicyFeedback(
      onPressed: _goToWalkIn,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(KioskTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
              ),
              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              'New Walk-in Order',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Quick Actions ──────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context, bool isMobile) {
    final actions = [
      _ActionItem(
        icon: Icons.bar_chart_rounded,
        title: 'Sales Report',
        subtitle: 'View detailed analytics',
        color: KioskTheme.info,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnalyticsPage()),
          );
        },
      ),
      _ActionItem(
        icon: Icons.receipt_long_rounded,
        title: 'Order History',
        subtitle: 'All today\'s orders',
        color: Colors.purple,
        onTap: () {
          final orders = orderHistory.reversed.toList();
          if (orders.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No orders yet today.', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                backgroundColor: KioskTheme.lunaBrown,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KioskTheme.radiusMd)),
              ),
            );
            return;
          }
          _showOrdersSheet(context, orders);
        },
      ),
      _ActionItem(
        icon: Icons.menu_book_rounded,
        title: 'Menu Manager',
        subtitle: 'View menu items',
        color: KioskTheme.success,
        onTap: () => _goToWalkIn(),
      ),
      _ActionItem(
        icon: Icons.tv_rounded,
        title: 'KDS Display',
        subtitle: 'Kitchen display system',
        color: const Color(0xFFFF8C00),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KdsPage()),
          );
        },
      ),
    ];

    return Column(
      children: [
        LayoutBuilder(
          builder: (_, constraints) => Wrap(
            spacing: 14,
            runSpacing: 14,
            children: actions.map((a) => _actionCard(a, (constraints.maxWidth - 14) / 2)).toList(),
          ),
        ),
        const SizedBox(height: 14),
        _buildLifetimeReportButton(),
      ],
    );
  }

  Widget _buildLifetimeReportButton() {
    return JuicyFeedback(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LifetimeAnalyticsPage()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [KioskTheme.lunaBrown, KioskTheme.lunaDarkBrown],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
          boxShadow: KioskTheme.shadowPrimary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
              ),
              child: const Icon(Icons.leaderboard_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIFETIME SALES REPORT',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Full history \u00B7 Best sellers \u00B7 Date filters',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.75),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_rounded, color: Colors.white.withOpacity(0.8), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(_ActionItem item, double cardWidth) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
          border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.06)),
          boxShadow: KioskTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: KioskTheme.labelLarge.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle,
              style: KioskTheme.bodySmall.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
        border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.06)),
        boxShadow: KioskTheme.shadowSm,
      ),
      child: Column(
        children: [
          Text('🛵', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No orders yet today',
            style: KioskTheme.titleMedium.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Start by placing a walk-in order!',
            style: KioskTheme.bodySmall.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Order Tile ─────────────────────────────────────────────
  Widget _buildOrderTile(Map<String, dynamic> order) {
    final type = order['isWalkIn'] == true ? 'Walk-In' : (order['type'] as String);
    final isWalkIn = order['isWalkIn'] == true;
    final typeIcon = isWalkIn ? '🧾' : (type == 'Pickup' ? '🏪' : '🛵');
    final typeColor = isWalkIn
        ? KioskTheme.success
        : (type == 'Pickup' ? const Color(0xFFFF8C00) : KioskTheme.info);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
        border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.06)),
        boxShadow: KioskTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
            ),
            child: Center(child: Text(typeIcon, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      order['orderNumber'] as String,
                      style: KioskTheme.titleMedium.copyWith(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
                      ),
                      child: Text(
                        type,
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${order['customerName']}  ·  ${order['time']}',
                  style: KioskTheme.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '₱${order['total']}',
            style: KioskTheme.headerSmall.copyWith(fontSize: 20, color: KioskTheme.lunaBrown),
          ),
        ],
      ),
    );
  }

  // ── Orders Bottom Sheet ────────────────────────────────────
  void _showOrdersSheet(BuildContext context, List<Map<String, dynamic>> orders) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(KioskTheme.radiusXl)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 14, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Row(
                children: [
                  Text(
                    '📋  All Orders',
                    style: KioskTheme.headerSmall.copyWith(fontSize: 18),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: KioskTheme.lunaBrown.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
                    ),
                    child: Text(
                      '${orders.length} total',
                      style: KioskTheme.labelSmall.copyWith(
                        color: KioskTheme.lunaBrown,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            KioskTheme.divider(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: orders.length,
                itemBuilder: (_, i) => _buildOrderTile(orders[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action Item Model ────────────────────────────────────────
class _ActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
