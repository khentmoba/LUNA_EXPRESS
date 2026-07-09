import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import '../models/errand.dart';
import 'pasugo_constants.dart';

/// Service for managing errand (pasugo post) operations with Firestore.
class ErrandService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _errandsRef =>
      _firestore.collection(PasugoCollections.errands);

  /// Creates a new errand post and returns the document ID.
  Future<String> createErrand(Errand errand) async {
    final docRef = await _errandsRef.add(errand.toFirestore());
    return docRef.id;
  }

  /// Hashes a 4-digit PIN using SHA-256.
  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generates a random 4-digit PIN (for display purposes only — not stored).
  static String generatePin() {
    final random = Random();
    return '${1000 + random.nextInt(9000)}';
  }

  /// Returns a real-time stream of available errands ordered by newest first.
  Stream<List<Errand>> getAvailableErrands() {
    return _errandsRef
        .where('status', isEqualTo: ErrandStatus.available.toJson())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Errand.fromFirestore(doc)).toList());
  }

  /// Finds errands by customer phone number (for customer status lookup).
  Future<List<Errand>> findErrandsByPhone(String phone) async {
    final querySnapshot = await _errandsRef
        .where('customerPhone', isEqualTo: phone)
        .orderBy('createdAt', descending: true)
        .get();
    return querySnapshot.docs
        .map((doc) => Errand.fromFirestore(doc))
        .toList();
  }

  /// Verifies a customer's PIN against the stored hash for a given phone.
  Future<bool> verifyPin(String phone, String pin) async {
    final hashedPin = hashPin(pin);
    final querySnapshot = await _errandsRef
        .where('customerPhone', isEqualTo: phone)
        .limit(1)
        .get();
    if (querySnapshot.docs.isEmpty) return false;
    final errand = Errand.fromFirestore(querySnapshot.docs.first);
    return errand.pinHash == hashedPin;
  }

  /// Cancels an errand (customer-facing: sets status to cancelled).
  Future<void> cancelErrand(String errandId) async {
    await _errandsRef.doc(errandId).update({
      'status': ErrandStatus.cancelled.toJson(),
    });
  }

  /// Updates errand status (used internally when rider accepts/completes).
  Future<void> updateErrandStatus(
      String errandId, ErrandStatus newStatus) async {
    await _errandsRef.doc(errandId).update({
      'status': newStatus.toJson(),
    });
  }

  /// Gets a single errand by its ID.
  Future<Errand?> getErrandById(String errandId) async {
    final doc = await _errandsRef.doc(errandId).get();
    if (!doc.exists) return null;
    return Errand.fromFirestore(doc);
  }
}
