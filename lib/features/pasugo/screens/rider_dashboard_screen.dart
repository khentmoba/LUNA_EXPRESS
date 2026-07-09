import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../providers/rider_provider.dart';

/// Rider dashboard — shows active sessions and access to bulletin board.
class RiderDashboardScreen extends StatefulWidget {
  const RiderDashboardScreen({super.key});

  @override
  State<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends State<RiderDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final riderProvider = context.read<RiderProvider>();
      if (riderProvider.currentUid != null) {
        context.read<SessionProvider>().startListeningToActiveSessions(
              riderProvider.currentUid!,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<RiderProvider>().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/pasugo');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/pasugo/bulletin');
                    },
                    icon: const Icon(Icons.dashboard),
                    label: const Text('Browse Errands'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Active Sessions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Active sessions list
          Expanded(
            child: Consumer<SessionProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingSessions) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.activeSessions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox,
                            size: 48,
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'No active sessions',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Browse available errands to find one to accept',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.activeSessions.length,
                  itemBuilder: (context, index) {
                    final session = provider.activeSessions[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.chat),
                        ),
                        title: Text('Errand #${session.errandId.substring(0, 8)}...'),
                        subtitle: Text(
                          'Accepted ${_formatTimeAgo(session.acceptedAt)}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/pasugo/chat',
                            arguments: {
                              'sessionId': session.id,
                              'errandId': session.errandId,
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
