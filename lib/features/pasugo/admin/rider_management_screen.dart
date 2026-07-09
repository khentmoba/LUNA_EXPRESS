import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/pasugo_constants.dart';
import '../models/rider.dart';

/// Admin screen for managing rider registrations.
class RiderManagementScreen extends StatelessWidget {
  const RiderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Management'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(PasugoCollections.riders)
            .orderBy('registeredAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final riders = snapshot.data!.docs;

          if (riders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No riders registered yet',
                      style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: riders.length,
            itemBuilder: (context, index) {
              final doc = riders[index];
              final data = doc.data() as Map<String, dynamic>;
              final rider = Rider.fromMap(data, id: doc.id);
              return _RiderManagementCard(rider: rider);
            },
          );
        },
      ),
    );
  }
}

class _RiderManagementCard extends StatelessWidget {
  final Rider rider;

  const _RiderManagementCard({required this.rider});

  Future<void> _updateRiderStatus(
      BuildContext context, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection(PasugoCollections.riders)
          .doc(rider.id)
          .update({
        'status': newStatus,
        if (newStatus == RiderStatus.approved.toJson())
          'approvedAt': DateTime.now().toIso8601String(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Rider ${rider.name} ${newStatus == "approved" ? "approved" : "rejected"}'),
            backgroundColor:
                newStatus == 'approved' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine status color
    Color statusColor;
    switch (rider.status) {
      case RiderStatus.pending:
        statusColor = Colors.orange;
        break;
      case RiderStatus.approved:
        statusColor = Colors.green;
        break;
      case RiderStatus.rejected:
        statusColor = Colors.red;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    rider.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rider.status.displayName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Phone: ${rider.phone}',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text('Address: ${rider.address}',
                style: theme.textTheme.bodySmall),
            if (rider.registeredAt != null) ...[
              const SizedBox(height: 2),
              Text(
                'Registered: ${rider.registeredAt.toLocal().toString().substring(0, 16)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
            if (rider.status == RiderStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        _updateRiderStatus(context, 'rejected'),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () =>
                        _updateRiderStatus(context, 'approved'),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
