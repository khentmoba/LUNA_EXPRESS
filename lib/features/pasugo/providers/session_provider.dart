import 'package:flutter/foundation.dart';
import '../models/pasugo_session.dart';
import '../services/session_service.dart';

/// Manages pasugo session state: acceptance flow and active session tracking.
class SessionProvider extends ChangeNotifier {
  final SessionService _service = SessionService();

  // ── Active sessions ──
  List<PasugoSession> _activeSessions = [];
  List<PasugoSession> get activeSessions => _activeSessions;

  bool _isLoadingSessions = false;
  bool get isLoadingSessions => _isLoadingSessions;

  // ── Acceptance state ──
  bool _isAccepting = false;
  bool get isAccepting => _isAccepting;

  String? _acceptError;
  String? get acceptError => _acceptError;

  String? _lastAcceptedSessionId;
  String? get lastAcceptedSessionId => _lastAcceptedSessionId;

  // ── Completion state ──
  bool _isCompleting = false;
  bool get isCompleting => _isCompleting;

  String? _completionError;
  String? get completionError => _completionError;

  /// Starts listening to active sessions for a given rider.
  void startListeningToActiveSessions(String riderId) {
    _isLoadingSessions = true;
    notifyListeners();

    _service.getActiveSessions(riderId).listen(
      (sessions) {
        _activeSessions = sessions;
        _isLoadingSessions = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoadingSessions = false;
        _acceptError = 'Failed to load sessions: $error';
        notifyListeners();
      },
    );
  }

  /// Atomically accepts an errand.
  Future<String?> acceptErrand({
    required String errandId,
    required String riderId,
    required String customerPhone,
  }) async {
    _isAccepting = true;
    _acceptError = null;
    notifyListeners();

    try {
      final sessionId = await _service.acceptErrand(
        errandId: errandId,
        riderId: riderId,
        customerPhone: customerPhone,
      );
      _lastAcceptedSessionId = sessionId;
      _isAccepting = false;
      notifyListeners();
      return sessionId;
    } catch (e) {
      _isAccepting = false;
      _acceptError = 'Failed to accept errand: $e';
      notifyListeners();
      return null;
    }
  }

  /// Marks a session as done.
  Future<bool> markSessionDone(String sessionId) async {
    _isCompleting = true;
    notifyListeners();

    try {
      await _service.markSessionDone(sessionId);
      _isCompleting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isCompleting = false;
      _completionError = 'Failed to complete session: $e';
      notifyListeners();
      return false;
    }
  }

  /// Gets a session by ID.
  Future<PasugoSession?> getSessionById(String sessionId) {
    return _service.getSessionById(sessionId);
  }

  /// Clears the acceptance state.
  void resetAcceptState() {
    _lastAcceptedSessionId = null;
    _acceptError = null;
    notifyListeners();
  }
}
