import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/errand_provider.dart';
import '../providers/session_provider.dart';
import '../providers/rider_provider.dart';
import '../widgets/errand_card.dart';
import '../models/errand.dart';

/// Bulletin board screen — lists available errands for riders and customers.
class BulletinBoardScreen extends StatefulWidget {
  const BulletinBoardScreen({super.key});

  @override
  State<BulletinBoardScreen> createState() => _BulletinBoardScreenState();
}

class _BulletinBoardScreenState extends State<BulletinBoardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ErrandProvider>().startListeningToBoard();
    });
  }

  Future<void> _handleAccept(Errand errand) async {
    if (errand.id == null) return;

    final riderProvider = context.read<RiderProvider>();
    final sessionProvider = context.read<SessionProvider>();

    if (riderProvider.currentUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final sessionId = await sessionProvider.acceptErrand(
      errandId: errand.id!,
      riderId: riderProvider.currentUid!,
      customerPhone: errand.customerPhone,
    );

    if (!mounted) return;

    if (sessionId != null) {
      Navigator.pushNamed(
        context,
        '/pasugo/chat',
        arguments: {
          'sessionId': sessionId,
          'errandId': errand.id,
          'isRider': true,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sessionProvider.acceptError ?? 'Failed to accept errand',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Errands'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ErrandProvider>().startListeningToBoard();
            },
          ),
        ],
      ),
      body: Consumer<ErrandProvider>(
        builder: (context, errandProvider, _) {
          if (errandProvider.isLoadingBoard) {
            return const Center(child: CircularProgressIndicator());
          }

          if (errandProvider.boardError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errandProvider.boardError!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () => errandProvider.startListeningToBoard(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (errandProvider.availableErrands.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No errands yet',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to post an errand!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
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

          // Check if current user is a verified rider
          final isVerifiedRider = context.watch<RiderProvider>().isVerified;

          return RefreshIndicator(
            onRefresh: () async {
              errandProvider.startListeningToBoard();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: errandProvider.availableErrands.length,
              itemBuilder: (context, index) {
                final errand = errandProvider.availableErrands[index];
                return ErrandCard(
                  errand: errand,
                  showAcceptButton: isVerifiedRider,
                  isAccepting: context.watch<SessionProvider>().isAccepting,
                  onAccept: isVerifiedRider
                      ? () => _handleAccept(errand)
                      : null,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/pasugo/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
