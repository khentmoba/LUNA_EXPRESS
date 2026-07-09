import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/chat_bubble.dart';

/// Chat screen for communication between customer and rider.
/// Receives sessionId and errandId via route arguments.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isRider = false;
  String? _sessionId;
  String? _errandId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _sessionId = args?['sessionId'] as String?;
      _errandId = args?['errandId'] as String?;
      _isRider = args?['isRider'] as bool? ?? false;

      if (_sessionId != null) {
        context.read<ChatProvider>().startListeningToMessages(_sessionId!);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    context.read<ChatProvider>().disposeChat();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _messageController.text;
    if (text.trim().isEmpty || _sessionId == null) return;

    _messageController.clear();
    final provider = context.read<ChatProvider>();
    await provider.sendMessage(
      sessionId: _sessionId!,
      sender: _isRider ? MessageSender.rider : MessageSender.customer,
      text: text,
    );
    _scrollToBottom();
  }

  Future<void> _handleMarkDone() async {
    if (_sessionId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Errand'),
        content: const Text(
          'Mark this errand as done? The chat will be closed and archived.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Mark as Done'),
          ),
        ],
      ),
    );

    if (confirmed == true && _sessionId != null) {
      final provider = context.read<SessionProvider>();
      final success = await provider.markSessionDone(_sessionId!);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errand marked as done!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isRider ? 'Customer Chat' : 'Rider Chat'),
        centerTitle: true,
        actions: [
          if (_isRider)
            Consumer<ChatProvider>(
              builder: (context, provider, _) {
                if (provider.isSessionActive) {
                  return IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    tooltip: 'Mark as Done',
                    onPressed: _handleMarkDone,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingMessages) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48,
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Send a message to start coordinating',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Auto-scroll when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    final isFromCustomer = _isRider
                        ? message.sender == MessageSender.customer
                        : message.sender == MessageSender.rider;
                    return ChatBubble(
                      message: message,
                      isFromCustomer: isFromCustomer,
                    );
                  },
                );
              },
            ),
          ),

          // Session status banner (if completed)
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              if (!provider.isSessionActive) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock,
                          size: 16,
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.6)),
                      const SizedBox(width: 8),
                      Text(
                        provider.isSessionCompleted
                            ? 'Chat closed (completed)'
                            : 'Chat closed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Input area (only if session is active)
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              if (!provider.isSessionActive) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 3,
                          minLines: 1,
                          onSubmitted: (_) => _handleSend(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Consumer<ChatProvider>(
                        builder: (context, provider, _) {
                          return IconButton.filled(
                            onPressed: provider.isSending ? null : _handleSend,
                            icon: provider.isSending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
