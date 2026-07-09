import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rider.dart';
import 'pasugo_constants.dart';

/// Service for rider authentication and profile management.
class RiderAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _ridersRef =>
      _firestore.collection(PasugoCollections.riders);

  /// Registers a new rider with Firebase Auth and creates their profile.
  /// Returns the Firebase Auth UID on success.
  Future<String> registerRider({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
  }) async {
    // Create Firebase Auth account
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = userCredential.user!.uid;

    // Create rider profile document
    final rider = Rider(
      id: uid,
      name: name,
      phone: phone,
      address: address,
      status: RiderStatus.pending,
      registeredAt: DateTime.now(),
      isActive: true,
    );

    await _ridersRef.doc(uid).set({
      'name': rider.name,
      'phone': rider.phone,
      'address': rider.address,
      'status': rider.status.toJson(),
      'registeredAt': rider.registeredAt.toIso8601String(),
      'isActive': rider.isActive,
    });

    // Note: Custom claim for riderStatus will be set by a Cloud Function
    // triggered on riders/{uid} document creation/update.
    // For now, just register and sign out so the rider waits for approval.
    await _auth.signOut();

    return uid;
  }

  /// Logs in a rider and returns their status.
  /// Throws if login fails (wrong credentials, account disabled, etc.).
  Future<RiderLoginResult> loginRider({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user!;
    // Reload to get latest custom claims
    await user.getIdToken(true);
    final idTokenResult = await user.getIdTokenResult();

    final riderStatus =
        idTokenResult.claims?['riderStatus'] as String? ?? 'pending';

    // Check if rider is active
    final riderDoc = await _ridersRef.doc(user.uid).get();
    if (riderDoc.exists) {
      final data = riderDoc.data() as Map<String, dynamic>?;
      final isActive = data?['isActive'] as bool? ?? true;
      if (!isActive) {
        await _auth.signOut();
        return RiderLoginResult(
          success: false,
          status: RiderStatus.rejected,
          error: 'Your account has been deactivated. Please contact support.',
        );
      }
    }

    final status = RiderStatus.fromJson(riderStatus);

    return RiderLoginResult(
      success: status == RiderStatus.approved,
      status: status,
      uid: user.uid,
      error: status == RiderStatus.pending
          ? 'Your registration is still pending approval.'
          : status == RiderStatus.rejected
              ? 'Your registration has been rejected.'
              : null,
    );
  }

  /// Gets the rider profile from Firestore.
  Future<Rider?> getRiderProfile(String uid) async {
    final doc = await _ridersRef.doc(uid).get();
    if (!doc.exists) return null;
    return Rider.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);
  }

  /// Logs out the current rider.
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Returns the currently logged-in Firebase user.
  User? get currentUser => _auth.currentUser;
}

/// Result of a rider login attempt.
class RiderLoginResult {
  final bool success;
  final RiderStatus status;
  final String? uid;
  final String? error;

  const RiderLoginResult({
    required this.success,
    required this.status,
    this.uid,
    this.error,
  });
}
