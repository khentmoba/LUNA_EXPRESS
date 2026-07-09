import 'package:flutter/foundation.dart';
import '../models/rider.dart';
import '../services/rider_auth_service.dart';

/// Manages rider authentication state, profile, and verification status.
class RiderProvider extends ChangeNotifier {
  final RiderAuthService _authService = RiderAuthService();

  // ── Auth state ──
  Rider? _riderProfile;
  Rider? get riderProfile => _riderProfile;

  RiderStatus? _riderStatus;
  RiderStatus? get riderStatus => _riderStatus;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // ── Loading states ──
  bool _isRegistering = false;
  bool get isRegistering => _isRegistering;

  bool _isLoggingIn = false;
  bool get isLoggingIn => _isLoggingIn;

  String? _authError;
  String? get authError => _authError;

  /// Checks if the current rider is verified (approved).
  bool get isVerified => _riderStatus == RiderStatus.approved;

  /// Clears auth error.
  void clearError() {
    _authError = null;
    notifyListeners();
  }

  /// Registers a new rider.
  Future<bool> registerRider({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
  }) async {
    _isRegistering = true;
    _authError = null;
    notifyListeners();

    try {
      await _authService.registerRider(
        email: email,
        password: password,
        name: name,
        phone: phone,
        address: address,
      );
      _isRegistering = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isRegistering = false;
      _authError = 'Registration failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Logs in a rider.
  Future<RiderLoginResult> loginRider({
    required String email,
    required String password,
  }) async {
    _isLoggingIn = true;
    _authError = null;
    notifyListeners();

    try {
      final result = await _authService.loginRider(
        email: email,
        password: password,
      );

      if (result.success && result.uid != null) {
        _isLoggedIn = true;
        _riderStatus = result.status;
        // Load profile
        _riderProfile = await _authService.getRiderProfile(result.uid!);
      }

      _isLoggingIn = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoggingIn = false;
      _authError = 'Login failed: $e';
      notifyListeners();
      return RiderLoginResult(
        success: false,
        status: RiderStatus.pending,
        error: _authError,
      );
    }
  }

  /// Logs out the current rider.
  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _riderProfile = null;
    _riderStatus = null;
    _authError = null;
    notifyListeners();
  }

  /// Loads a rider profile by UID (used by admin management screens).
  Future<Rider?> getRiderProfile(String uid) async {
    return _authService.getRiderProfile(uid);
  }

  /// Returns the current Firebase Auth UID.
  String? get currentUid => _authService.currentUser?.uid;
}
