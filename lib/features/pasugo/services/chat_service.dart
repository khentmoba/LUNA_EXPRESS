import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import 'pasugo_constants.dart';

/// Service for managing real-time chat messages within a pasugo session.
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns a reference to the messages subcollection for a given session.
  CollectionReference _messagesRef(String sessionId) =>
      _firestore
          .collection(PasugoCollections.sessions)
          .doc(sessionId)
          .collection(PasugoCollections.messages);

  /// Sends a message to a session's chat.
  Future<void> sendMessage({
    required String sessionId,
    required MessageSender sender,
    required String text,
    String? type,
  }) async {
    final message = ChatMessage(
      sender: sender,
      text: text,
      timestamp: DateTime.now(),
      type: type,
    );
    await _messagesRef(sessionId).add({
      'sender': message.sender.toJson(),
      'text': message.text,
      'timestamp': message.timestamp.toIso8601String(),
      if (message.type != null) 'type': message.type,
    });
  }

  /// Returns a real-time stream of messages for a session, ordered by time.
  Stream<List<ChatMessage>> getMessages(String sessionId) {
    return _messagesRef(sessionId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ChatMessage.fromMap(doc.data() as Map<String, dynamic>,
                    id: doc.id))
            .toList());
  }

  /// Marks a session as done — all subsequent message writes are blocked
  /// by Firestore security rules based on session status.
  Future<void> markSessionDone(String sessionId) async {
    await _firestore
        .collection(PasugoCollections.sessions)
        .doc(sessionId)
        .update({
      'status': 'completed',
      'completedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Gets a live stream of the session document to monitor status changes.
  Stream<DocumentSnapshot> getSessionStream(String sessionId) {
    return _firestore
        .collection(PasugoCollections.sessions)
        .doc(sessionId)
        .snapshots();
  }
}
