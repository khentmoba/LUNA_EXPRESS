import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../models/errand.dart';
import '../services/pasugo_constants.dart';

String _sha256(String input) => sha256.convert(utf8.encode(input)).toString();

/// Errand board, creation, and customer lookup.
class Errands extends ChangeNotifier {
  final _ref = FirebaseFirestore.instance.collection(PasugoCollections.errands);
  StreamSubscription? _boardSub;

  List<Errand> availableErrands = [];
  bool isLoadingBoard = false;
  String? boardError;

  bool isCreating = false;
  String? creationError;

  List<Errand> customerErrands = [];
  bool isLookingUp = false;

  @override
  void dispose() {
    _boardSub?.cancel();
    super.dispose();
  }

  void startListeningToBoard() {
    _boardSub?.cancel();
    isLoadingBoard = true;
    boardError = null;
    notifyListeners();

    _boardSub = _ref
        .where('status', isEqualTo: ErrandStatus.available.toJson())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Errand.fromFirestore).toList())
        .listen(
          (errands) {
            availableErrands = errands;
            isLoadingBoard = false;
            notifyListeners();
          },
          onError: (e) {
            isLoadingBoard = false;
            boardError = 'Failed to load errands: $e';
            notifyListeners();
          },
        );
  }

  Future<bool> createErrand({
    required String name,
    required String phone,
    required String pin,
    required String message,
    GeoPoint? locationPin,
  }) async {
    creationError = _validate(name, phone, pin, message);
    if (creationError != null) {
      notifyListeners();
      return false;
    }

    isCreating = true;
    creationError = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      await _ref.add(
        Errand(
          customerName: name,
          customerPhone: phone,
          phoneHash: _sha256(phone),
          pinHash: _sha256(pin),
          message: message,
          locationPin: locationPin,
          createdAt: now,
          expiresAt: now.add(ErrandConstraints.expiryDuration),
        ).toFirestore(),
      );
      isCreating = false;
      notifyListeners();
      return true;
    } catch (e) {
      isCreating = false;
      creationError = 'Failed to post errand: $e';
      notifyListeners();
      return false;
    }
  }

  void resetCreationState() {
    isCreating = false;
    creationError = null;
    notifyListeners();
  }

  Future<bool> findErrandsByPhone(String phone) async {
    if (phone.isEmpty) return false;
    isLookingUp = true;
    notifyListeners();
    try {
      final snap = await _ref
          .where('customerPhone', isEqualTo: phone)
          .orderBy('createdAt', descending: true)
          .get();
      customerErrands = snap.docs.map(Errand.fromFirestore).toList();
      isLookingUp = false;
      notifyListeners();
      return customerErrands.isNotEmpty;
    } catch (_) {
      isLookingUp = false;
      customerErrands = [];
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyPin(String phone, String pin) async {
    try {
      final snap = await _ref
          .where('customerPhone', isEqualTo: phone)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return false;
      return Errand.fromFirestore(snap.docs.first).pinHash == _sha256(pin);
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelErrand(String errandId) async {
    try {
      await _ref.doc(errandId).update({
        'status': ErrandStatus.cancelled.toJson(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  String? _validate(String name, String phone, String pin, String message) {
    if (name.length < ErrandConstraints.nameMinLength ||
        name.length > ErrandConstraints.nameMaxLength) {
      return PasugoErrorMessages.nameTooShort;
    }
    if (phone.isEmpty || !_isValidPhone(phone)) {
      return PasugoErrorMessages.phoneInvalid;
    }
    if (pin.length != ErrandConstraints.pinLength ||
        int.tryParse(pin) == null) {
      return PasugoErrorMessages.pinInvalid;
    }
    if (message.length < ErrandConstraints.messageMinLength ||
        message.length > ErrandConstraints.messageMaxLength) {
      return PasugoErrorMessages.messageTooShort;
    }
    return null;
  }

  bool _isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('+63'))
      return cleaned.length >= 12 && cleaned.length <= 13;
    if (cleaned.startsWith('09')) return cleaned.length == 11;
    if (cleaned.startsWith('639')) return cleaned.length == 12;
    return false;
  }
}
