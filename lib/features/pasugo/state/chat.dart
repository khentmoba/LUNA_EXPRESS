import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/pasugo_constants.dart';

/// Real-time chat within a pasugo session.
class Chat extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  StreamSubscription? _messagesSub;
  StreamSubscription? _sessionSub;

  List<ChatMessage> messages = [];
  bool isLoadingMessages = false;
  bool isSending = false;

  String _sessionStatus = 'active';
  bool get isSessionActive => _sessionStatus == 'active';
  bool get isSessionCompleted => _sessionStatus == 'completed';

  @override
  void dispose() {
    _messagesSub?.cancel();
    _sessionSub?.cancel();
    super.dispose();
  }

  CollectionReference _messagesRef(String sessionId) => _db
      .collection(PasugoCollections.sessions)
      .doc(sessionId)
      .collection(PasugoCollections.messages);

  void startListeningToMessages(String sessionId) {
    _messagesSub?.cancel();
    _sessionSub?.cancel();
    isLoadingMessages = true;
    notifyListeners();

    _messagesSub = _messagesRef(sessionId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (s) => s.docs
              .map(
                (d) => ChatMessage.fromMap(
                  d.data() as Map<String, dynamic>,
                  id: d.id,
                ),
              )
              .toList(),
        )
        .listen(
          (msgs) {
            messages = msgs;
            isLoadingMessages = false;
            notifyListeners();
          },
          onError: (_) {
            isLoadingMessages = false;
            notifyListeners();
          },
        );

    _sessionSub = _db
        .collection(PasugoCollections.sessions)
        .doc(sessionId)
        .snapshots()
        .listen((snap) {
          if (snap.exists) {
            _sessionStatus =
                (snap.data() as Map<String, dynamic>)['status'] as String? ??
                'active';
            notifyListeners();
          }
        });
  }

  Future<bool> sendMessage({
    required String sessionId,
    required MessageSender sender,
    required String text,
  }) async {
    if (text.trim().isEmpty) return false;
    isSending = true;
    notifyListeners();
    try {
      await _messagesRef(sessionId).add(
        ChatMessage(
          sender: sender,
          text: text.trim(),
          timestamp: DateTime.now(),
        ).toMap(),
      );
      isSending = false;
      notifyListeners();
      return true;
    } catch (_) {
      isSending = false;
      notifyListeners();
      return false;
    }
  }

  /// Clears chat state when leaving a chat.
  void reset() {
    _messagesSub?.cancel();
    _sessionSub?.cancel();
    messages = [];
    isLoadingMessages = false;
    isSending = false;
    _sessionStatus = 'active';
    notifyListeners();
  }
}
