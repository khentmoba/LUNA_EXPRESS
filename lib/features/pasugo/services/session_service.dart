import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pasugo_session.dart';
import '../models/errand.dart';
import 'pasugo_constants.dart';

/// Service for managing pasugo sessions (accept, track, complete).
class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _sessionsRef =>
      _firestore.collection(PasugoCollections.sessions);

  CollectionReference get _errandsRef =>
      _firestore.collection(PasugoCollections.errands);

  /// Atomically accepts an errand: validates availability, updates errand,
  /// and creates a session in a single Firestore transaction.
  /// Returns the new session ID on success, throws on failure.
  Future<String> acceptErrand({
    required String errandId,
    required String riderId,
    required String customerPhone,
  }) async {
    // Use a transaction to prevent double-claim
    return await _firestore.runTransaction((transaction) async {
      final errandRef = _errandsRef.doc(errandId);
      final errandDoc = await transaction.get(errandRef);

      if (!errandDoc.exists) {
        throw Exception(PasugoErrorMessages.errandNotFound);
      }

      final errand = Errand.fromFirestore(errandDoc);
      if (errand.status != ErrandStatus.available) {
        throw Exception(PasugoErrorMessages.errandNotAvailable);
      }

      // Update errand status to accepted
      transaction.update(errandRef, {
        'status': ErrandStatus.accepted.toJson(),
      });

      // Create session document
      final sessionRef = _sessionsRef.doc();
      final now = DateTime.now();
      transaction.set(sessionRef, {
        'errandId': errandId,
        'riderId': riderId,
        'customerPhone': customerPhone,
        'status': SessionStatus.active.toJson(),
        'acceptedAt': now.toIso8601String(),
      });

      return sessionRef.id;
    });
  }

  /// Returns a stream of active sessions for a given rider.
  Stream<List<PasugoSession>> getActiveSessions(String riderId) {
    return _sessionsRef
        .where('riderId', isEqualTo: riderId)
        .where('status', isEqualTo: SessionStatus.active.toJson())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                PasugoSession.fromMap(doc.data() as Map<String, dynamic>,
                    id: doc.id))
            .toList());
  }

  /// Gets a session by errand ID.
  Future<PasugoSession?> getSessionByErrand(String errandId) async {
    final querySnapshot = await _sessionsRef
        .where('errandId', isEqualTo: errandId)
        .limit(1)
        .get();
    if (querySnapshot.docs.isEmpty) return null;
    return PasugoSession.fromMap(
        querySnapshot.docs.first.data() as Map<String, dynamic>,
        id: querySnapshot.docs.first.id);
  }

  /// Gets a session by its ID.
  Future<PasugoSession?> getSessionById(String sessionId) async {
    final doc = await _sessionsRef.doc(sessionId).get();
    if (!doc.exists) return null;
    return PasugoSession.fromMap(doc.data() as Map<String, dynamic>,
        id: doc.id);
  }

  /// Marks a session as done (completed).
  Future<void> markSessionDone(String sessionId) async {
    await _firestore.runTransaction((transaction) async {
      final sessionRef = _sessionsRef.doc(sessionId);
      final sessionDoc = await transaction.get(sessionRef);

      if (!sessionDoc.exists) {
        throw Exception(PasugoErrorMessages.sessionNotFound);
      }

      final session = PasugoSession.fromMap(
          sessionDoc.data() as Map<String, dynamic>,
          id: sessionDoc.id);
      if (session.status != SessionStatus.active) {
        throw Exception(PasugoErrorMessages.sessionNotActive);
      }

      final now = DateTime.now().toIso8601String();
      transaction.update(sessionRef, {
        'status': SessionStatus.completed.toJson(),
        'completedAt': now,
      });

      // Also update the errand status to completed
      final errandRef = _errandsRef.doc(session.errandId);
      transaction.update(errandRef, {
        'status': ErrandStatus.completed.toJson(),
      });
    });
  }

  /// Cancels a session (rider-initiated or admin-initiated).
  Future<void> cancelSession({
    required String sessionId,
    required String cancelledBy,
    String? reason,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final sessionRef = _sessionsRef.doc(sessionId);
      final sessionDoc = await transaction.get(sessionRef);

      if (!sessionDoc.exists) {
        throw Exception(PasugoErrorMessages.sessionNotFound);
      }

      final session = PasugoSession.fromMap(
          sessionDoc.data() as Map<String, dynamic>,
          id: sessionDoc.id);

      final now = DateTime.now().toIso8601String();
      transaction.update(sessionRef, {
        'status': SessionStatus.cancelled.toJson(),
        'completedAt': now,
        'cancelledBy': cancelledBy,
        if (reason != null) 'cancellationReason': reason,
      });

      // Return errand to available status
      final errandRef = _errandsRef.doc(session.errandId);
      transaction.update(errandRef, {
        'status': ErrandStatus.available.toJson(),
      });
    });
  }
}
