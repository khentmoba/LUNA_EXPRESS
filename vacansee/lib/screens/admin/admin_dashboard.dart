import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/property_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadProperties();
      final propertyProvider = context.read<PropertyProvider>();
      final bookingProvider = context.read<BookingProvider>();
      if (propertyProvider.properties.isNotEmpty) {
        final propertyIds = propertyProvider.properties.map((p) => p.propertyId).toList();
        bookingProvider.loadPendingCount(propertyIds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final authProvider = context.watch<AuthProvider>();

    final totalListings = propertyProvider.properties.length;
    final totalBookings = bookingProvider.bookings.length;
    final pendingBookings = bookingProvider.pendingCount;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D1B16),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D1B16),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete system overview and management',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            // Stats Row 1
            Row(
              children: [
                _buildStatCard(
                  Icons.home_outlined,
                  totalListings.toString(),
                  'Total Listings',
                  const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  Icons.trending_up,
                  '66%',
                  'Occupancy Rate',
                  const Color(0xFF10B981),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  Icons.people_outline,
                  '5',
                  'Total Users',
                  const Color(0xFF8B5CF6),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  Icons.calendar_today_outlined,
                  totalBookings.toString(),
                  'Total Bookings',
                  const Color(0xFFF59E0B),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stats Row 2 (Colored cards)
            Row(
              children: [
                _buildColoredCard(
                  Icons.apartment,
                  '2',
                  'Active Tenants',
                  const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 12),
                _buildColoredCard(
                  Icons.person_outline,
                  '2',
                  'Property Owners',
                  const Color(0xFF10B981),
                ),
                const SizedBox(width: 12),
                _buildColoredCard(
                  Icons.schedule,
                  pendingBookings.toString(),
                  'Pending Bookings',
                  const Color(0xFFF59E0B),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Two column layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Actions
                Expanded(
                  child: _buildQuickActionsCard(),
                ),
                const SizedBox(width: 20),
                // Recent Bookings
                Expanded(
                  child: _buildRecentBookingsCard(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D1B16),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColoredCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B16),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2,
            children: [
              _buildActionButton(
                Icons.home_work_outlined,
                'Manage Listings',
                () {},
              ),
              _buildActionButton(
                Icons.calendar_today_outlined,
                'View Bookings',
                () {},
              ),
              _buildActionButton(
                Icons.people_outline,
                'User Management',
                () {},
              ),
              _buildActionButton(
                Icons.person_outline,
                'Admin Profile',
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF5287B2), size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1B16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBookingsCard() {
    final sampleBookings = [
      {
        'name': 'Carlos Rodriguez',
        'property': 'Sunshine Boarding House',
        'date': 'Mar 5, 2026',
      },
      {
        'name': 'Lisa Chen',
        'property': 'Green Valley Residence',
        'date': 'Mar 1, 2026',
      },
      {
        'name': 'Mark Johnson',
        'property': 'Executive Suites',
        'date': 'Mar 6, 2026',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Bookings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B16),
            ),
          ),
          const SizedBox(height: 16),
          ...sampleBookings.map((booking) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5287B2).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF5287B2),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking['name']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D1B16),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking['property']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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
}
