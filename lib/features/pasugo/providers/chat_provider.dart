import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

/// Manages chat state: messages list, sending, and real-time updates.
class ChatProvider extends ChangeNotifier {
  final ChatService _service = ChatService();

  // ── Messages ──
  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _isLoadingMessages = false;
  bool get isLoadingMessages => _isLoadingMessages;

  // ── Send state ──
  bool _isSending = false;
  bool get isSending => _isSending;

  String? _sendError;
  String? get sendError => _sendError;

  // ── Session status ──
  String _sessionStatus = 'active';
  String get sessionStatus => _sessionStatus;

  bool get isSessionActive => _sessionStatus == 'active';
  bool get isSessionCompleted => _sessionStatus == 'completed';

  /// Starts listening to messages for a given session.
  void startListeningToMessages(String sessionId) {
    _isLoadingMessages = true;
    notifyListeners();

    _service.getMessages(sessionId).listen(
      (messages) {
        _messages = messages;
        _isLoadingMessages = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoadingMessages = false;
        _sendError = 'Failed to load messages: $error';
        notifyListeners();
      },
    );

    // Also listen to session status changes
    _service.getSessionStream(sessionId).listen(
      (snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          _sessionStatus = data['status'] as String? ?? 'active';
          notifyListeners();
        }
      },
    );
  }

  /// Sends a chat message.
  Future<bool> sendMessage({
    required String sessionId,
    required MessageSender sender,
    required String text,
  }) async {
    if (text.trim().isEmpty) return false;

    _isSending = true;
    _sendError = null;
    notifyListeners();

    try {
      await _service.sendMessage(
        sessionId: sessionId,
        sender: sender,
        text: text.trim(),
      );
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSending = false;
      _sendError = 'Failed to send message: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clears chat state (when leaving a chat).
  void disposeChat() {
    _messages = [];
    _isLoadingMessages = false;
    _isSending = false;
    _sendError = null;
    _sessionStatus = 'active';
    notifyListeners();
  }
}
