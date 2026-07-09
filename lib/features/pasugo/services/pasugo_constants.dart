/// Collection names for Firestore.
class PasugoCollections {
  static const String errands = 'pasugo_errands';
  static const String riders = 'riders';
  static const String sessions = 'pasugo_sessions';
  static const String messages = 'messages'; // subcollection under sessions
}

/// Errand constraints.
class ErrandConstraints {
  static const int nameMinLength = 2;
  static const int nameMaxLength = 100;
  static const int messageMinLength = 10;
  static const int messageMaxLength = 500;
  static const int pinLength = 4;
  static const Duration expiryDuration = Duration(hours: 48);
}

/// Error messages for validation.
class PasugoErrorMessages {
  static const String nameRequired = 'Name is required';
  static const String nameTooShort = 'Name must be at least 2 characters';
  static const String nameTooLong = 'Name must be under 100 characters';
  static const String phoneRequired = 'Phone number is required';
  static const String phoneInvalid = 'Please enter a valid phone number';
  static const String pinRequired = 'PIN is required';
  static const String pinInvalid = 'PIN must be exactly 4 digits';
  static const String messageRequired = 'Message is required';
  static const String messageTooShort = 'Message must be at least 10 characters';
  static const String messageTooLong = 'Message must be under 500 characters';
  static const String errandNotFound = 'Errand not found';
  static const String errandNotAvailable = 'This errand is no longer available';
  static const String sessionNotFound = 'Session not found';
  static const String sessionNotActive = 'Session is no longer active';
}
