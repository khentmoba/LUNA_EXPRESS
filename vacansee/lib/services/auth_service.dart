import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Exception for authentication-related errors
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  factory AuthException.fromFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const AuthException('An account already exists with this email.');
      case 'invalid-email':
        return const AuthException('Please enter a valid email address.');
      case 'operation-not-allowed':
        return const AuthException('Operation not allowed. Contact support.');
      case 'weak-password':
        return const AuthException('Please enter a stronger password.');
      case 'user-disabled':
        return const AuthException('This account has been disabled.');
      case 'user-not-found':
        return const AuthException('No account found with this email.');
      case 'wrong-password':
        return const AuthException('Incorrect password. Please try again.');
      case 'invalid-credential':
        return const AuthException('Invalid credentials. Please try again.');
      case 'too-many-requests':
        return const AuthException('Too many attempts. Please try again later.');
      default:
        return AuthException(e.message ?? 'An error occurred. Please try again.');
    }
  }

  @override
  String toString() => 'AuthException: $message';
}

/// Authentication service handling Firebase Auth operations
class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Current Firebase user
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Get current user ID or null
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  /// Check if user is logged in
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  /// Register a new user with email and password
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? phoneNumber,
  }) async {
    try {
      // Create auth user
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Failed to create account.');
      }

      // Create user document in Firestore
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        role: role,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } on FirebaseException catch (e) {
      throw AuthException('Database error: ${e.message}');
    }
  }

  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Failed to sign in.');
      }

      // Update last login time
      await _firestore.collection('users').doc(user.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      // Fetch user model
      final userModel = await getUserModel(user.uid);
      if (userModel == null) {
        throw const AuthException('User profile not found.');
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Get user model from Firestore
  Future<UserModel?> getUserModel(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw AuthException('Failed to fetch user: ${e.message}');
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? phoneNumber,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;

      await _firestore.collection('users').doc(uid).update(updates);
    } on FirebaseException catch (e) {
      throw AuthException('Failed to update profile: ${e.message}');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }
}
