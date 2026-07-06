import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/kiosk/kiosk_theme.dart';

/// Quick date-range preset for the lifetime report.
enum DateRangePreset {
  allTime('All Time', null, null),
  today('Today', null, null),     // resolved dynamically
  thisWeek('This Week', null, null),
  thisMonth('This Month', null, null),
  thisYear('This Year', null, null),
  custom('Custom', null, null);

  final String label;
  final String? fixedStart;
  final String? fixedEnd;
  const DateRangePreset(this.label, this.fixedStart, this.fixedEnd);
}

class LifetimeAnalyticsPage extends StatefulWidget {
  const LifetimeAnalyticsPage({super.key});

  @override
  State<LifetimeAnalyticsPage> createState() => _LifetimeAnalyticsPageState();
}

class _LifetimeAnalyticsPageState extends State<LifetimeAnalyticsPage> {
  bool _loading = false;
  Map<String, dynamic> _data = {};
  String? _error;

  DateRangePreset _selectedPreset = DateRangePreset.allTime;
  DateTime? _customStart;
  DateTime? _customEnd;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  // ── Date Helpers (PHT = UTC+8) ──────────────────────────────
  String _phtDateLabel([DateTime? dt]) {
    final d = dt ?? DateTime.now().toUtc().add(const Duration(hours: 8));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _computeStartDate() {
    if (_selectedPreset == DateRangePreset.custom && _customStart != null) {
      return _phtDateLabel(_customStart);
    }
    if (_selectedPreset.fixedStart != null) return _selectedPreset.fixedStart!;

    final nowPht = DateTime.now().toUtc().add(const Duration(hours: 8));
    final today = DateTime(nowPht.year, nowPht.month, nowPht.day);

    switch (_selectedPreset) {
      case DateRangePreset.today:
        return _phtDateLabel();
      case DateRangePreset.thisWeek:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return _phtDateLabel(startOfWeek);
      case DateRangePreset.thisMonth:
        return _phtDateLabel(DateTime(today.year, today.month, 1));
      case DateRangePreset.thisYear:
        return _phtDateLabel(DateTime(today.year, 1, 1));
      default:
        return '2020-01-01'; // all time
    }
  }

  String _computeEndDate() {
    if (_selectedPreset == DateRangePreset.custom && _customEnd != null) {
      return _phtDateLabel(_customEnd);
    }
    if (_selectedPreset.fixedEnd != null) return _selectedPreset.fixedEnd!;
    return _phtDateLabel(); // today
  }

  // ── Fetch ───────────────────────────────────────────────────
  Future<void> _fetchReport() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('getLifetimeSalesReport');
      final result = await callable.call({
        'startDate': _computeStartDate(),
        'endDate': _computeEndDate(),
      });
      final responseData = result.data as Map<dynamic, dynamic>;

      if (responseData['success'] == true) {
        setState(() {
          _data = Map<String, dynamic>.from(responseData);
          _loading = false;
        });
      } else {
        setState(() {
          _error = responseData['message'] ?? 'Failed to load report.';
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

  // ── Date range label for header ─────────────────────────────
  String get _rangeLabel {
    final dateRange = _data['dateRange'] as Map<dynamic, dynamic>?;
    if (dateRange?['isAllTime'] == true) return 'LIFETIME (ALL TIME)';
    return '${dateRange?['start'] ?? '?'}  →  ${dateRange?['end'] ?? '?'}';
  }

  // ── Build ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: KioskTheme.lunaCream,
      appBar: AppBar(
        title: Text(
          'LIFETIME SALES REPORT',
          style: KioskTheme.headerSmall.copyWith(color: KioskTheme.textOnPrimary, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: KioskTheme.lunaBrown,
        foregroundColor: KioskTheme.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loading ? null : _fetchReport,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: KioskTheme.lunaBrown))
          : _error != null
              ? _buildError()
              : Column(
                  children: [
                    _buildDateFilterBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRangeHeader(),
                            const SizedBox(height: 24),
                            _buildSummaryRow(isMobile),
                            const SizedBox(height: 24),
                            _buildDailyRevenueChart(),
                            const SizedBox(height: 24),
                            isMobile
                                ? Column(
                                    children: [
                                      _buildChannelBreakdownCard(),
                                      const SizedBox(height: 20),
                                      _buildEntryTypeCard(),
                                      const SizedBox(height: 20),
                                      _buildPaymentMethodCard(),
                                      const SizedBox(height: 20),
                                      _buildTopItemsCard(),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(flex: 2, child: _buildChannelBreakdownCard()),
                                      const SizedBox(width: 20),
                                      Expanded(flex: 1, child: _buildEntryTypeCard()),
                                    ],
                                  ),
                            if (!isMobile) const SizedBox(height: 20),
                            if (!isMobile)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 1, child: _buildPaymentMethodCard()),
                                  const SizedBox(width: 20),
                                  Expanded(flex: 2, child: _buildTopItemsCard()),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  // ── Error ───────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: KioskTheme.error, size: 48),
          const SizedBox(height: 16),
          Text(_error!, style: KioskTheme.bodyLarge.copyWith(fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchReport,
            style: KioskTheme.primaryButton,
            child: Text('Retry', style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Date Filter Bar ─────────────────────────────────────────
  Widget _buildDateFilterBar() {
    final presets = DateRangePreset.values;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: KioskTheme.lunaBrown.withOpacity(0.06))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: presets.map((preset) {
            final selected = _selectedPreset == preset;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _onPresetTap(preset),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? KioskTheme.lunaBrown : Colors.transparent,
                    borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
                    border: Border.all(
                      color: selected ? KioskTheme.lunaBrown : KioskTheme.textMuted.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    preset.label,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : KioskTheme.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _onPresetTap(DateRangePreset preset) async {
    if (preset == DateRangePreset.custom) {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020, 1, 1),
        lastDate: DateTime.now().toUtc().add(const Duration(hours: 8)),
        initialDateRange: _customStart != null && _customEnd != null
            ? DateTimeRange(start: _customStart!, end: _customEnd!)
            : DateTimeRange(
                start: DateTime.now().subtract(const Duration(days: 30)),
                end: DateTime.now(),
              ),
        builder: (ctx, child) {
          return Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: Theme.of(ctx).colorScheme.copyWith(
                    primary: KioskTheme.lunaBrown,
                    onPrimary: Colors.white,
                  ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        setState(() {
          _customStart = picked.start;
          _customEnd = picked.end;
          _selectedPreset = DateRangePreset.custom;
        });
        _fetchReport();
      }
      return;
    }

    setState(() => _selectedPreset = preset);
    _fetchReport();
  }

  // ── Range Header ────────────────────────────────────────────
  Widget _buildRangeHeader() {
    final summary = _data['summary'] as Map<dynamic, dynamic>? ?? {};
    final orderCount = summary['orderCount'] as int? ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SALES OVERVIEW',
              style: KioskTheme.labelMedium.copyWith(color: KioskTheme.textMuted, fontSize: 14),
            ),
            Text(
              _rangeLabel,
              style: KioskTheme.headerMedium.copyWith(fontSize: 20),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: KioskTheme.lunaBrown.withOpacity(0.08),
            borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
          ),
          child: Text(
            '$orderCount orders',
            style: KioskTheme.labelSmall.copyWith(color: KioskTheme.lunaBrown, fontSize: 11),
          ),
        ),
      ],
    );
  }

  // ── Summary Row ─────────────────────────────────────────────
  Widget _buildSummaryRow(bool isMobile) {
    final summary = _data['summary'] as Map<dynamic, dynamic>? ?? {};
    final totalRevenue = summary['totalRevenue'] as int? ?? 0;
    final orderCount = summary['orderCount'] as int? ?? 0;
    final avgOrder = summary['averageOrderValue'] as int? ?? 0;
    final itemsSold = summary['totalItemsSold'] as int? ?? 0;

    final cards = [
      _MetricData('TOTAL REVENUE', '\u20B1${_fmt(totalRevenue)}', Icons.monetization_on_rounded, KioskTheme.success),
      _MetricData('TOTAL ORDERS', _fmt(orderCount), Icons.receipt_long_rounded, KioskTheme.info),
      _MetricData('AVG ORDER', '\u20B1${_fmt(avgOrder)}', Icons.analytics_rounded, Colors.purple),
      _MetricData('ITEMS SOLD', _fmt(itemsSold), Icons.shopping_bag_rounded, const Color(0xFFFF8C00)),
    ];

    if (isMobile) {
      return Column(
        children: cards
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMetricCard(c),
                ))
            .toList(),
      );
    }

    return Row(
      children: cards
          .map((c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildMetricCard(c),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildMetricCard(_MetricData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
        border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.06)),
        boxShadow: KioskTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: KioskTheme.labelMedium.copyWith(fontSize: 10, color: KioskTheme.textMuted)),
                const SizedBox(height: 2),
                Text(data.value, style: KioskTheme.headerMedium.copyWith(fontSize: 22)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Daily Revenue Chart ─────────────────────────────────────
  Widget _buildDailyRevenueChart() {
    final series = (_data['dailySeries'] as List<dynamic>?) ?? [];

    if (series.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
          border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.06)),
        ),
        child: Center(
          child: Text(
            'No sales data for this period',
            style: KioskTheme.bodySmall.copyWith(color: Colors.grey[400], fontSize: 13),
          ),
        ),
      );
    }

    // Group by month for a manageable chart
    final monthlyData = <String, int>{};
    final monthlyOrders = <String, int>{};
    for (final day in series) {
      final date = day['date'] as String;
      final month = date.substring(0, 7); // YYYY-MM
      monthlyData[month] = (monthlyData[month] ?? 0) + (day['revenue'] as int? ?? 0);
      monthlyOrders[month] = (monthlyOrders[month] ?? 0) + (day['orders'] as int? ?? 0);
    }

    final sortedMonths = monthlyData.keys.toList()..sort();
    final maxRev = monthlyData.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
        border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.06)),
        boxShadow: KioskTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('REVENUE OVER TIME', style: KioskTheme.labelLarge.copyWith(fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                '(Monthly)',
                style: KioskTheme.bodySmall.copyWith(color: KioskTheme.textMuted, fontSize: 11),
              ),
            ],
          ),
          KioskTheme.divider(),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sortedMonths.length,
              itemBuilder: (_, i) {
                final month = sortedMonths[i];
                final rev = monthlyData[month] ?? 0;
                final oCount = monthlyOrders[month] ?? 0;
                final heightFactor = maxRev > 0 ? rev / maxRev : 0.05;
                final barHeight = 20.0 + (heightFactor * 100.0);

                // Show month label as short format
                final parts = month.split('-');
                final label = '${monthsAbbr[int.parse(parts[1]) - 1]} ${parts.length > 1 ? "'${parts[1]}": ""}';

                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '\u20B1${_shortFmt(rev)}',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: KioskTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$oCount orders',
                        style: GoogleFonts.outfit(
                          fontSize: 7,
                          fontWeight: FontWeight.w600,
                          color: KioskTheme.textMuted.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 28,
                        height: barHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [KioskTheme.lunaBrown, KioskTheme.lunaDarkBrown],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: KioskTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Channel Breakdown ───────────────────────────────────────
  Widget _buildChannelBreakdownCard() {
    final breakdown = _data['breakdown'] as Map<dynamic, dynamic>? ?? {};
    final channel = breakdown['channel'] as Map<dynamic, dynamic>? ?? {};
    final walkIn = channel['walkIn'] as Map<dynamic, dynamic>? ?? {'revenue': 0, 'count': 0};
    final delivery = channel['delivery'] as Map<dynamic, dynamic>? ?? {'revenue': 0, 'count': 0};
    final pickup = channel['pickup'] as Map<dynamic, dynamic>? ?? {'revenue': 0, 'count': 0};

    final walkInRev = walkIn['revenue'] as int? ?? 0;
    final deliveryRev = delivery['revenue'] as int? ?? 0;
    final pickupRev = pickup['revenue'] as int? ?? 0;

    final maxRev = [walkInRev, deliveryRev, pickupRev].reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
        border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.06)),
        boxShadow: KioskTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CHANNEL SALES SPLIT', style: KioskTheme.labelLarge.copyWith(fontSize: 14)),
          KioskTheme.divider(),
          const SizedBox(height: 20),
          _buildSplitBar('Walk-In', walkInRev, walkIn['count'] as int? ?? 0, maxRev, Colors.orange),
          const SizedBox(height: 16),
          _buildSplitBar('Pickup', pickupRev, pickup['count'] as int? ?? 0, maxRev, KioskTheme.info),
          const SizedBox(height: 16),
          _buildSplitBar('Delivery', deliveryRev, delivery['count'] as int? ?? 0, maxRev, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildSplitBar(String label, int revenue, int count, int maxRev, Color color) {
    final fraction = maxRev > 0 ? revenue / maxRev : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: KioskTheme.titleMedium.copyWith(fontSize: 13)),
            Text(
              '\u20B1${_fmt(revenue)}  ·  $count orders',
              style: KioskTheme.bodySmall.copyWith(fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  // ── Entry Type ─────────────────────────────────────────────
  Widget _buildEntryTypeCard() {
    final breakdown = _data['breakdown'] as Map<dynamic, dynamic>? ?? {};
    final entry = breakdown['entryType'] as Map<dynamic, dynamic>? ?? {};
    final kiosk = entry['kiosk'] as Map<dynamic, dynamic>? ?? {'revenue': 0, 'count': 0};
    final staff = entry['staff'] as Map<dynamic, dynamic>? ?? {'revenue': 0, 'count': 0};

    final kioskRev = kiosk['revenue'] as int? ?? 0;
    final staffRev = staff['revenue'] as int? ?? 0;
    final kioskCount = kiosk['count'] as int? ?? 0;
    final staffCount = staff['count'] as int? ?? 0;
    final totalRev = kioskRev + staffRev;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
        border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.06)),
        boxShadow: KioskTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ORDER ENTRY', style: KioskTheme.labelLarge.copyWith(fontSize: 14)),
          KioskTheme.divider(),
          const SizedBox(height: 20),
          _buildMiniStat('🖥️  Kiosk', '\u20B1${_fmt(kioskRev)}', '$kioskCount orders', KioskTheme.info),
          const SizedBox(height: 16),
          _buildMiniStat('👤  Staff', '\u20B1${_fmt(staffRev)}', '$staffCount orders', Colors.orange),
          const SizedBox(height: 16),
          if (totalRev > 0) ...[
            KioskTheme.divider(),
            const SizedBox(height: 12),
            Text(
              'Kiosk: ${(kioskRev / totalRev * 100).toStringAsFixed(1)}%  ·  Staff: ${(staffRev / totalRev * 100).toStringAsFixed(1)}%',
              style: KioskTheme.bodySmall.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  // ── Payment Method ──────────────────────────────────────────
  Widget _buildPaymentMethodCard() {
    final breakdown = _data['breakdown'] as Map<dynamic, dynamic>? ?? {};
    final pm = breakdown['paymentMethod'] as Map<dynamic, dynamic>? ?? {};
    final cash = pm['cash'] as Map<dynamic, dynamic>? ?? {'revenue': 0, 'count': 0};
    final gcash = pm['gcash'] as Map<dynamic, dynamic>? ?? {'revenue': 0, 'count': 0};

    final cashRev = cash['revenue'] as int? ?? 0;
    final gcashRev = gcash['revenue'] as int? ?? 0;
    final cashCount = cash['count'] as int? ?? 0;
    final gcashCount = gcash['count'] as int? ?? 0;
    final totalRev = cashRev + gcashRev;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
        border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.06)),
        boxShadow: KioskTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PAYMENT METHOD', style: KioskTheme.labelLarge.copyWith(fontSize: 14)),
          KioskTheme.divider(),
          const SizedBox(height: 20),
          _buildMiniStat('💵  Cash', '\u20B1${_fmt(cashRev)}', '$cashCount orders', KioskTheme.success),
          const SizedBox(height: 16),
          _buildMiniStat('📱  GCash', '\u20B1${_fmt(gcashRev)}', '$gcashCount orders', const Color(0xFF007AFF)),
          const SizedBox(height: 16),
          if (totalRev > 0) ...[
            KioskTheme.divider(),
            const SizedBox(height: 12),
            Text(
              'Cash: ${(cashRev / totalRev * 100).toStringAsFixed(1)}%  ·  GCash: ${(gcashRev / totalRev * 100).toStringAsFixed(1)}%',
              style: KioskTheme.bodySmall.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, String sub, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: KioskTheme.titleMedium.copyWith(fontSize: 13)),
              Text(sub, style: KioskTheme.bodySmall.copyWith(fontSize: 10)),
            ],
          ),
        ),
        Text(value, style: KioskTheme.headerSmall.copyWith(fontSize: 16)),
      ],
    );
  }

  // ── Top Items ───────────────────────────────────────────────
  Widget _buildTopItemsCard() {
    final topItems = _data['topItems'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
        border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.06)),
        boxShadow: KioskTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BEST SELLERS', style: KioskTheme.labelLarge.copyWith(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            'Top items by quantity sold',
            style: KioskTheme.bodySmall.copyWith(fontSize: 10),
          ),
          KioskTheme.divider(),
          const SizedBox(height: 16),
          if (topItems.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No item sales recorded',
                  style: KioskTheme.bodySmall.copyWith(color: Colors.grey[400], fontSize: 13),
                ),
              ),
            )
          else
            ...topItems.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final name = item['name'] as String;
              final qty = item['quantity'] as int;
              final rev = item['revenue'] as int? ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: idx < 3
                            ? [KioskTheme.lunaBrown, const Color(0xFF6B5744), const Color(0xFF9E8B7A)][idx]
                            : KioskTheme.lunaBrown.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
                      ),
                      child: Center(
                        child: Text(
                          '#${idx + 1}',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: idx < 3 ? Colors.white : KioskTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: KioskTheme.titleMedium.copyWith(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '\u20B1${_fmt(rev)} total',
                            style: KioskTheme.bodySmall.copyWith(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: KioskTheme.lunaBrown.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
                      ),
                      child: Text(
                        '$qty sold',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: KioskTheme.lunaBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── Utilities ───────────────────────────────────────────────
  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  String _shortFmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  static const monthsAbbr = [
    'J', 'F', 'M', 'A', 'M', 'J',
    'J', 'A', 'S', 'O', 'N', 'D'
  ];
}

// ── Internal model ────────────────────────────────────────────
class _MetricData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricData(this.title, this.value, this.icon, this.color);
}
