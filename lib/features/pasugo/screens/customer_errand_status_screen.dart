import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/errand.dart';
import '../providers/errand_provider.dart';
import '../widgets/errand_card.dart';

/// Shows a customer's errands with status and actions.
class CustomerErrandStatusScreen extends StatelessWidget {
  const CustomerErrandStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Errands'),
        centerTitle: true,
      ),
      body: Consumer<ErrandProvider>(
        builder: (context, provider, _) {
          if (provider.isLookingUp) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.customerErrands.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No errands found',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/pasugo/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Post an Errand'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.customerErrands.length,
            itemBuilder: (context, index) {
              final errand = provider.customerErrands[index];
              return _buildErrandCard(context, errand, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildErrandCard(
      BuildContext context, Errand errand, ErrandProvider provider) {
    final theme = Theme.of(context);

    IconData statusIcon;
    Color statusColor;
    String statusText;
    String actionLabel;
    VoidCallback? onAction;

    switch (errand.status) {
      case ErrandStatus.available:
        statusIcon = Icons.hourglass_empty;
        statusColor = Colors.orange;
        statusText = 'Waiting for a rider';
        actionLabel = 'Cancel';
        onAction = () => _cancelErrand(context, errand, provider);
        break;
      case ErrandStatus.accepted:
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = 'Rider found!';
        actionLabel = 'Open Chat';
        onAction = () {
          Navigator.pushNamed(
            context,
            '/pasugo/chat',
            arguments: {
              'errandId': errand.id,
              'isRider': false,
            },
          );
        };
        break;
      case ErrandStatus.completed:
        statusIcon = Icons.check_circle;
        statusColor = Colors.blue;
        statusText = 'Completed';
        actionLabel = 'View Archive';
        onAction = () {
          Navigator.pushNamed(
            context,
            '/pasugo/chat',
            arguments: {
              'errandId': errand.id,
              'isRider': false,
            },
          );
        };
        break;
      case ErrandStatus.cancelled:
        statusIcon = Icons.cancel;
        statusColor = Colors.grey;
        statusText = 'Cancelled';
        actionLabel = '';
        onAction = null;
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
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              errand.message,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (actionLabel.isNotEmpty && onAction != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: actionLabel == 'Cancel'
                    ? OutlinedButton.icon(
                        onPressed: onAction,
                        icon: const Icon(Icons.close, size: 18),
                        label: Text(actionLabel),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      )
                    : FilledButton.tonalIcon(
                        onPressed: onAction,
                        icon: const Icon(Icons.chat, size: 18),
                        label: Text(actionLabel),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _cancelErrand(
      BuildContext context, Errand errand, ErrandProvider provider) async {
    if (errand.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Errand'),
        content: const Text('Are you sure you want to cancel this errand?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.cancelErrand(errand.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Errand cancelled' : 'Failed to cancel'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
