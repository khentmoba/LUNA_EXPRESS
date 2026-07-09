import 'package:flutter/foundation.dart';
import '../models/errand.dart';
import '../services/errand_service.dart';
import '../services/pasugo_constants.dart';

/// Manages errand state: creation flow and bulletin board listing.
class ErrandProvider extends ChangeNotifier {
  final ErrandService _service = ErrandService();

  // ── Bulletin board state ──
  List<Errand> _availableErrands = [];
  List<Errand> get availableErrands => _availableErrands;

  bool _isLoadingBoard = false;
  bool get isLoadingBoard => _isLoadingBoard;

  String? _boardError;
  String? get boardError => _boardError;

  // ── Creation state ──
  bool _isCreating = false;
  bool get isCreating => _isCreating;

  String? _creationError;
  String? get creationError => _creationError;

  String? _createdErrandId;
  String? get createdErrandId => _createdErrandId;

  // ── Customer lookup state ──
  List<Errand> _customerErrands = [];
  List<Errand> get customerErrands => _customerErrands;

  bool _isLookingUp = false;
  bool get isLookingUp => _isLookingUp;

  String? _lookupError;
  String? get lookupError => _lookupError;

  /// Clears creation state (for resetting form after success).
  void resetCreationState() {
    _isCreating = false;
    _creationError = null;
    _createdErrandId = null;
    notifyListeners();
  }

  /// Starts listening to available errands for the bulletin board.
  void startListeningToBoard() {
    _isLoadingBoard = true;
    _boardError = null;
    notifyListeners();

    _service.getAvailableErrands().listen(
      (errands) {
        _availableErrands = errands;
        _isLoadingBoard = false;
        _boardError = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoadingBoard = false;
        _boardError = 'Failed to load errands: $error';
        notifyListeners();
      },
    );
  }

  /// Validates form fields and creates a new errand.
  Future<bool> createErrand({
    required String name,
    required String phone,
    required String pin,
    required String message,
    dynamic locationPin, // GeoPoint or null
  }) async {
    // Client-side validation
    if (name.length < ErrandConstraints.nameMinLength ||
        name.length > ErrandConstraints.nameMaxLength) {
      _creationError = PasugoErrorMessages.nameTooShort;
      notifyListeners();
      return false;
    }
    if (phone.isEmpty || !_isValidPhone(phone)) {
      _creationError = PasugoErrorMessages.phoneInvalid;
      notifyListeners();
      return false;
    }
    if (pin.length != ErrandConstraints.pinLength ||
        int.tryParse(pin) == null) {
      _creationError = PasugoErrorMessages.pinInvalid;
      notifyListeners();
      return false;
    }
    if (message.length < ErrandConstraints.messageMinLength ||
        message.length > ErrandConstraints.messageMaxLength) {
      _creationError = PasugoErrorMessages.messageTooShort;
      notifyListeners();
      return false;
    }

    _isCreating = true;
    _creationError = null;
    notifyListeners();

    try {
      final pinHash = _service.hashPin(pin);
      final errand = Errand(
        customerName: name,
        customerPhone: phone,
        phoneHash: _service.hashPin(phone),
        pinHash: pinHash,
        message: message,
        locationPin: locationPin as dynamic,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(ErrandConstraints.expiryDuration),
      );
      final docId = await _service.createErrand(errand);
      _createdErrandId = docId;
      _isCreating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isCreating = false;
      _creationError = 'Failed to post errand: $e';
      notifyListeners();
      return false;
    }
  }

  /// Looks up errands by phone number (for returning customers).
  Future<bool> findErrandsByPhone(String phone) async {
    if (phone.isEmpty) {
      _lookupError = PasugoErrorMessages.phoneRequired;
      notifyListeners();
      return false;
    }
    _isLookingUp = true;
    _lookupError = null;
    notifyListeners();

    try {
      _customerErrands = await _service.findErrandsByPhone(phone);
      _isLookingUp = false;
      if (_customerErrands.isEmpty) {
        _lookupError = 'No errands found for this phone number';
        notifyListeners();
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _isLookingUp = false;
      _lookupError = 'Failed to look up errands: $e';
      notifyListeners();
      return false;
    }
  }

  /// Verifies PIN for returning customer access.
  Future<bool> verifyPin(String phone, String pin) async {
    try {
      return await _service.verifyPin(phone, pin);
    } catch (e) {
      _lookupError = 'Verification failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Cancels an errand by ID.
  Future<bool> cancelErrand(String errandId) async {
    try {
      await _service.cancelErrand(errandId);
      return true;
    } catch (e) {
      _creationError = 'Failed to cancel errand: $e';
      notifyListeners();
      return false;
    }
  }

  bool _isValidPhone(String phone) {
    // Basic PH phone validation: starts with 09, +63, or 639, 10-11 digits
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('+63')) {
      return cleaned.length >= 12 && cleaned.length <= 13;
    }
    if (cleaned.startsWith('09')) {
      return cleaned.length == 11;
    }
    if (cleaned.startsWith('639')) {
      return cleaned.length == 12;
    }
    return false;
  }
}
