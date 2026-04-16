import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/room_model.dart';

/// Service for booking CRUD operations
class BookingService {
  final FirebaseFirestore _firestore;

  BookingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _bookings => _firestore.collection('bookings');

  /// Create a new booking request
  Future<BookingModel> createBooking({
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
    final docRef = _bookings.doc();
    final booking = BookingModel(
      bookingId: docRef.id,
      studentId: studentId,
      propertyId: propertyId,
      roomId: roomId,
      propertyName: propertyName,
      roomDescription: roomDescription,
      studentName: studentName,
      studentEmail: studentEmail,
      studentPhone: studentPhone,
      status: BookingStatus.pending,
      requestedAt: DateTime.now(),
      studentNotes: studentNotes,
      moveInDate: moveInDate,
      durationMonths: durationMonths,
    );

    await docRef.set(booking.toFirestore());
    return booking;
  }

  /// Get booking by ID
  Future<BookingModel?> getBooking(String bookingId) async {
    final doc = await _bookings.doc(bookingId).get();
    if (!doc.exists) return null;
    return BookingModel.fromFirestore(doc);
  }

  /// Get bookings for a student
  Stream<List<BookingModel>> getStudentBookings(String studentId) {
    return _bookings
        .where('studentId', isEqualTo: studentId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList());
  }

  /// Get bookings for an owner's properties
  Stream<List<BookingModel>> getOwnerBookings(List<String> propertyIds) {
    if (propertyIds.isEmpty) return Stream.value([]);
    
    return _bookings
        .where('propertyId', whereIn: propertyIds)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList());
  }

  /// Get pending bookings count for owner
  Stream<int> getPendingBookingsCount(List<String> propertyIds) {
    if (propertyIds.isEmpty) return Stream.value(0);
    
    return _bookings
        .where('propertyId', whereIn: propertyIds)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Approve a booking
  Future<void> approveBooking(String bookingId, {String? ownerNotes}) async {
    final booking = await getBooking(bookingId);
    if (booking == null) throw BookingException('Booking not found');

    final batch = _firestore.batch();

    // Update booking status
    final bookingRef = _bookings.doc(bookingId);
    batch.update(bookingRef, {
      'status': BookingStatus.approved.name,
      'respondedAt': Timestamp.fromDate(DateTime.now()),
      'ownerNotes': ownerNotes,
    });

    // Update room status to occupied
    final roomRef = _firestore
        .collection('properties')
        .doc(booking.propertyId)
        .collection('rooms')
        .doc(booking.roomId);
    batch.update(roomRef, {
      'status': RoomStatus.occupied.name,
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    });

    await batch.commit();
  }

  /// Reject a booking
  Future<void> rejectBooking(String bookingId, {String? ownerNotes}) async {
    await _bookings.doc(bookingId).update({
      'status': BookingStatus.rejected.name,
      'respondedAt': Timestamp.fromDate(DateTime.now()),
      'ownerNotes': ownerNotes,
    });
  }

  /// Cancel a booking (by student)
  Future<void> cancelBooking(String bookingId) async {
    await _bookings.doc(bookingId).update({
      'status': BookingStatus.cancelled.name,
      'respondedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Complete a booking
  Future<void> completeBooking(String bookingId) async {
    await _bookings.doc(bookingId).update({
      'status': BookingStatus.completed.name,
    });
  }

  /// Delete a booking
  Future<void> deleteBooking(String bookingId) async {
    await _bookings.doc(bookingId).delete();
  }
}

/// Exception for booking operations
class BookingException implements Exception {
  final String message;
  BookingException(this.message);
  @override
  String toString() => 'BookingException: $message';
}
