import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/rider.dart';
import '../services/pasugo_constants.dart';

/// Rider registration, login, and verification state.
class RiderAuth extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _riders = FirebaseFirestore.instance.collection(
    PasugoCollections.riders,
  );

  bool isRegistering = false;
  bool isLoggingIn = false;
  String? authError;

  RiderStatus? _status;
  bool get isVerified => _status == RiderStatus.approved;
  String? get currentUid => _auth.currentUser?.uid;

  Future<bool> registerRider({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
  }) async {
    isRegistering = true;
    authError = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _riders.doc(cred.user!.uid).set({
        'name': name,
        'phone': phone,
        'address': address,
        'status': RiderStatus.pending.toJson(),
        'registeredAt': DateTime.now().toIso8601String(),
        'isActive': true,
      });
      // Sign out so the rider waits for approval. A Cloud Function sets the
      // riderStatus claim when an admin approves the riders/{uid} document.
      await _auth.signOut();
      isRegistering = false;
      notifyListeners();
      return true;
    } catch (e) {
      isRegistering = false;
      authError = 'Registration failed: $e';
      notifyListeners();
      return false;
    }
  }

  Future<RiderLoginResult> loginRider({
    required String email,
    required String password,
  }) async {
    isLoggingIn = true;
    authError = null;
    notifyListeners();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user!;
      await user.getIdToken(true);
      final claims = (await user.getIdTokenResult()).claims;
      final status = RiderStatus.fromJson(
        claims?['riderStatus'] as String? ?? 'pending',
      );

      final doc = await _riders.doc(user.uid).get();
      if (doc.exists && (doc.data()?['isActive'] as bool? ?? true) == false) {
        await _auth.signOut();
        return _doneLoggingIn(
          RiderLoginResult(
            success: false,
            status: RiderStatus.rejected,
            error: 'Your account has been deactivated. Please contact support.',
          ),
        );
      }

      _status = status;
      return _doneLoggingIn(
        RiderLoginResult(
          success: status == RiderStatus.approved,
          status: status,
          uid: user.uid,
          error: status == RiderStatus.pending
              ? 'Your registration is still pending approval.'
              : status == RiderStatus.rejected
              ? 'Your registration has been rejected.'
              : null,
        ),
      );
    } catch (e) {
      authError = 'Login failed: $e';
      return _doneLoggingIn(
        RiderLoginResult(
          success: false,
          status: RiderStatus.pending,
          error: authError,
        ),
      );
    }
  }

  RiderLoginResult _doneLoggingIn(RiderLoginResult result) {
    isLoggingIn = false;
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    await _auth.signOut();
    _status = null;
    authError = null;
    notifyListeners();
  }
}
