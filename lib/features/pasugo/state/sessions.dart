import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/errand.dart';
import '../models/pasugo_session.dart';
import '../services/pasugo_constants.dart';

/// Errand acceptance and active-session tracking.
class Sessions extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _sessions =>
      _db.collection(PasugoCollections.sessions);
  CollectionReference get _errands => _db.collection(PasugoCollections.errands);
  StreamSubscription? _sub;

  List<PasugoSession> activeSessions = [];
  bool isLoadingSessions = false;

  bool isAccepting = false;
  String? acceptError;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void startListeningToActiveSessions(String riderId) {
    _sub?.cancel();
    isLoadingSessions = true;
    notifyListeners();

    _sub = _sessions
        .where('riderId', isEqualTo: riderId)
        .where('status', isEqualTo: SessionStatus.active.toJson())
        .snapshots()
        .map(
          (s) => s.docs
              .map(
                (d) => PasugoSession.fromMap(
                  d.data() as Map<String, dynamic>,
                  id: d.id,
                ),
              )
              .toList(),
        )
        .listen(
          (sessions) {
            activeSessions = sessions;
            isLoadingSessions = false;
            notifyListeners();
          },
          onError: (e) {
            isLoadingSessions = false;
            acceptError = 'Failed to load sessions: $e';
            notifyListeners();
          },
        );
  }

  /// Atomically accepts an errand. Returns the new session ID, or null.
  Future<String?> acceptErrand({
    required String errandId,
    required String riderId,
    required String customerPhone,
  }) async {
    isAccepting = true;
    acceptError = null;
    notifyListeners();

    try {
      final sessionId = await _db.runTransaction((tx) async {
        final errandRef = _errands.doc(errandId);
        final errandDoc = await tx.get(errandRef);
        if (!errandDoc.exists)
          throw Exception(PasugoErrorMessages.errandNotFound);
        if (Errand.fromFirestore(errandDoc).status != ErrandStatus.available) {
          throw Exception(PasugoErrorMessages.errandNotAvailable);
        }
        tx.update(errandRef, {'status': ErrandStatus.accepted.toJson()});
        final sessionRef = _sessions.doc();
        tx.set(sessionRef, {
          'errandId': errandId,
          'riderId': riderId,
          'customerPhone': customerPhone,
          'status': SessionStatus.active.toJson(),
          'acceptedAt': DateTime.now().toIso8601String(),
        });
        return sessionRef.id;
      });
      isAccepting = false;
      notifyListeners();
      return sessionId;
    } catch (e) {
      isAccepting = false;
      acceptError = 'Failed to accept errand: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> markSessionDone(String sessionId) async {
    try {
      await _db.runTransaction((tx) async {
        final sessionRef = _sessions.doc(sessionId);
        final sessionDoc = await tx.get(sessionRef);
        if (!sessionDoc.exists) {
          throw Exception(PasugoErrorMessages.sessionNotFound);
        }
        final session = PasugoSession.fromMap(
          sessionDoc.data() as Map<String, dynamic>,
          id: sessionDoc.id,
        );
        if (session.status != SessionStatus.active) {
          throw Exception(PasugoErrorMessages.sessionNotActive);
        }
        tx.update(sessionRef, {
          'status': SessionStatus.completed.toJson(),
          'completedAt': DateTime.now().toIso8601String(),
        });
        tx.update(_errands.doc(session.errandId), {
          'status': ErrandStatus.completed.toJson(),
        });
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}
