import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/errand.dart';

/// Displays a single errand card for the bulletin board.
/// Phone number is intentionally hidden — only name and message shown.
class ErrandCard extends StatelessWidget {
  final Errand errand;
  final VoidCallback? onAccept;
  final bool showAcceptButton;
  final bool isAccepting;

  const ErrandCard({
    super.key,
    required this.errand,
    this.onAccept,
    this.showAcceptButton = false,
    this.isAccepting = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _formatTimeAgo(errand.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name + Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    errand.customerName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    errand.status.displayName,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              errand.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Footer: Time + optional Accept button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    if (errand.locationPin != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.location_on,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 2),
                      Text(
                        'Has pin',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
                if (showAcceptButton && onAccept != null)
                  FilledButton.tonal(
                    onPressed: isAccepting ? null : onAccept,
                    child: isAccepting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Accept'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (errand.status) {
      case ErrandStatus.available:
        return Colors.green;
      case ErrandStatus.accepted:
        return Colors.orange;
      case ErrandStatus.completed:
        return Colors.blue;
      case ErrandStatus.cancelled:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dateTime);
  }
}
