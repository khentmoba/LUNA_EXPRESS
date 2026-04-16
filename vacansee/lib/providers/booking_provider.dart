import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

/// Provider for booking state management
class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService;

  BookingProvider({BookingService? bookingService})
      : _bookingService = bookingService ?? BookingService();

  // State
  List<BookingModel> _bookings = [];
  BookingModel? _selectedBooking;
  bool _isLoading = false;
  String? _errorMessage;
  int _pendingCount = 0;

  // Getters
  List<BookingModel> get bookings => _bookings;
  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get pendingCount => _pendingCount;

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Load student bookings
  void loadStudentBookings(String studentId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _bookingService.getStudentBookings(studentId).listen(
      (bookings) {
        _bookings = bookings;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load bookings: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Load owner bookings
  void loadOwnerBookings(List<String> propertyIds) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _bookingService.getOwnerBookings(propertyIds).listen(
      (bookings) {
        _bookings = bookings;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load bookings: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Load pending bookings count for owner
  void loadPendingCount(List<String> propertyIds) {
    _bookingService.getPendingBookingsCount(propertyIds).listen(
      (count) {
        _pendingCount = count;
        notifyListeners();
      },
      onError: (error) {
        // Silently fail for badge count
      },
    );
  }

  /// Create a new booking
  Future<bool> createBooking({
    required String studentId,
    required String propertyId,
    required String roomId,
    required String propertyName,
    required String roomDescription,
    required String studentName,
    required String studentEmail,
    String? studentPhone,
    String? studentNotes,
    DateTime? moveInDate,
    int durationMonths = 1,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final booking = await _bookingService.createBooking(
        studentId: studentId,
        propertyId: propertyId,
        roomId: roomId,
        propertyName: propertyName,
        roomDescription: roomDescription,
        studentName: studentName,
        studentEmail: studentEmail,
        studentPhone: studentPhone,
        studentNotes: studentNotes,
        moveInDate: moveInDate,
        durationMonths: durationMonths,
      );
      _bookings.insert(0, booking);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create booking: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Approve a booking
  Future<bool> approveBooking(String bookingId, {String? ownerNotes}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _bookingService.approveBooking(bookingId, ownerNotes: ownerNotes);
      final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: BookingStatus.approved,
          respondedAt: DateTime.now(),
          ownerNotes: ownerNotes,
        );
      }
      _pendingCount = _pendingCount > 0 ? _pendingCount - 1 : 0;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to approve booking: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reject a booking
  Future<bool> rejectBooking(String bookingId, {String? ownerNotes}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _bookingService.rejectBooking(bookingId, ownerNotes: ownerNotes);
      final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: BookingStatus.rejected,
          respondedAt: DateTime.now(),
          ownerNotes: ownerNotes,
        );
      }
      _pendingCount = _pendingCount > 0 ? _pendingCount - 1 : 0;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to reject booking: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _bookingService.cancelBooking(bookingId);
      final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: BookingStatus.cancelled,
          respondedAt: DateTime.now(),
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to cancel booking: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Select a booking
  void selectBooking(BookingModel? booking) {
    _selectedBooking = booking;
    notifyListeners();
  }
}

/// Exception for booking provider operations
class BookingProviderException implements Exception {
  final String message;
  BookingProviderException(this.message);
  @override
  String toString() => 'BookingProviderException: $message';
}
