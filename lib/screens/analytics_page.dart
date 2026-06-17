import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/kiosk/kiosk_theme.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _loading = false;
  Map<String, dynamic> _data = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('getSalesAnalytics');
      final result = await callable.call();
      final responseData = result.data as Map<dynamic, dynamic>;

      if (responseData['success'] == true) {
        setState(() {
          _data = Map<String, dynamic>.from(responseData);
          _loading = false;
        });
      } else {
        setState(() {
          _error = responseData['message'] ?? 'Failed to load analytics.';
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: KioskTheme.lunaCream,
      appBar: AppBar(
        title: Text(
          'SALES DASHBOARD',
          style: KioskTheme.headerSmall.copyWith(color: KioskTheme.textOnPrimary, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: KioskTheme.lunaBrown,
        foregroundColor: KioskTheme.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Metrics',
            onPressed: _loading ? null : _fetchAnalytics,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: KioskTheme.lunaBrown))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: KioskTheme.error, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: KioskTheme.bodyLarge.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _fetchAnalytics,
                        style: KioskTheme.primaryButton,
                        child: Text('Retry', style: GoogleFonts.outfit(color: Colors.white)),
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TODAY\'S REVENUE METRICS',
                                style: KioskTheme.labelMedium.copyWith(color: KioskTheme.textMuted, fontSize: 14),
                              ),
                              Text(
                                _data['dateLabel'] ?? 'Date loading...',
                                style: KioskTheme.headerMedium.copyWith(fontSize: 24),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: KioskTheme.badgeSuccess,
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: KioskTheme.success, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'LIVE SYNCED',
                                  style: KioskTheme.labelSmall.copyWith(color: KioskTheme.success, fontSize: 11),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 32),
                      isMobile
                          ? Column(
                              children: [
                                _buildMetricCard('TOTAL REVENUE', '\u20B1${_data['totalRevenue'] ?? 0}', Icons.monetization_on_rounded, KioskTheme.success),
                                const SizedBox(height: 16),
                                _buildMetricCard('TICKET COUNT', '${_data['orderCount'] ?? 0}', Icons.receipt_long_rounded, KioskTheme.info),
                                const SizedBox(height: 16),
                                _buildMetricCard('AVG TICKET', '\u20B1${_data['averageOrderValue'] ?? 0}', Icons.analytics_rounded, Colors.purple),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(child: _buildMetricCard('TOTAL REVENUE', '\u20B1${_data['totalRevenue'] ?? 0}', Icons.monetization_on_rounded, KioskTheme.success)),
                                const SizedBox(width: 20),
                                Expanded(child: _buildMetricCard('TICKET COUNT', '${_data['orderCount'] ?? 0}', Icons.receipt_long_rounded, KioskTheme.info)),
                                const SizedBox(width: 20),
                                Expanded(child: _buildMetricCard('AVG TICKET', '\u20B1${_data['averageOrderValue'] ?? 0}', Icons.analytics_rounded, Colors.purple)),
                              ],
                            ),
                      const SizedBox(height: 32),
                      isMobile
                          ? Column(
                              children: [
                                _buildSplitCard(),
                                const SizedBox(height: 32),
                                _buildTopItemsCard(),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _buildSplitCard()),
                                const SizedBox(width: 24),
                                Expanded(flex: 2, child: _buildTopItemsCard()),
                              ],
                            ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KioskTheme.radiusLg),
        border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.08)),
        boxShadow: KioskTheme.shadowMd,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: KioskTheme.labelMedium.copyWith(color: KioskTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: KioskTheme.headerMedium.copyWith(fontSize: 28),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSplitCard() {
    final breakdown = _data['breakdown'] as Map<dynamic, dynamic>? ?? {};
    final walkIn = breakdown['walkIn'] as Map<dynamic, dynamic>? ?? {'revenue': 0, 'count': 0};
    final delivery = breakdown['delivery'] as Map<dynamic, dynamic>? ?? {'revenue': 0, 'count': 0};
    final pickup = breakdown['pickup'] as Map<dynamic, dynamic>? ?? {'revenue': 0, 'count': 0};

    final walkInRev = walkIn['revenue'] as int? ?? 0;
    final deliveryRev = delivery['revenue'] as int? ?? 0;
    final pickupRev = pickup['revenue'] as int? ?? 0;

    final maxRev = [walkInRev, deliveryRev, pickupRev].reduce((curr, next) => curr > next ? curr : next);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KioskTheme.radiusLg),
        border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHANNEL SALES SPLIT',
            style: KioskTheme.labelLarge.copyWith(fontSize: 15),
          ),
          KioskTheme.divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChartBar('Walk-In', walkInRev, maxRev, Colors.orange),
              _buildChartBar('Pickup', pickupRev, maxRev, KioskTheme.info),
              _buildChartBar('Delivery', deliveryRev, maxRev, Colors.purple),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildChartBar(String label, int value, int maxValue, Color barColor) {
    final double heightFactor = maxValue > 0 ? (value / maxValue) : 0.05;
    final double barHeight = 15.0 + (heightFactor * 135.0);

    return Column(
      children: [
        Text(
          '\u20B1$value',
          style: KioskTheme.titleMedium.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          width: 48,
          height: barHeight,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(KioskTheme.radiusSm)),
            boxShadow: [
              BoxShadow(
                color: barColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: KioskTheme.labelMedium.copyWith(color: KioskTheme.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTopItemsCard() {
    final topItems = _data['topItems'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KioskTheme.radiusLg),
        border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOP Menu ITEMS',
            style: KioskTheme.labelLarge.copyWith(fontSize: 15),
          ),
          KioskTheme.divider(),
          if (topItems.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  'No item sales recorded today',
                  style: KioskTheme.bodySmall.copyWith(color: Colors.grey[400], fontSize: 13),
                ),
              ),
            )
          else
            ...topItems.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final item = entry.value;
              final name = item['name'] as String;
              final count = item['count'] as int;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: KioskTheme.lunaBrown.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$idx',
                          style: KioskTheme.labelSmall.copyWith(color: KioskTheme.textPrimary, fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: KioskTheme.titleMedium.copyWith(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: KioskTheme.lunaBrown.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
                      ),
                      child: Text(
                        '$count sold',
                        style: KioskTheme.labelSmall.copyWith(color: KioskTheme.textPrimary, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
