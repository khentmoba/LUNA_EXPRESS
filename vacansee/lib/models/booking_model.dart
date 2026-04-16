import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Booking status enum
enum BookingStatus {
  pending,
  approved,
  rejected,
  cancelled,
  completed,
}

/// Booking model representing a room booking request
class BookingModel {
  final String bookingId;
  final String studentId;
  final String propertyId;
  final String roomId;
  final String propertyName;
  final String roomDescription;
  final String studentName;
  final String studentEmail;
  final String? studentPhone;
  final BookingStatus status;
  final DateTime requestedAt;
  final DateTime? respondedAt;
  final String? ownerNotes;
  final String? studentNotes;
  final DateTime? moveInDate;
  final int durationMonths;

  const BookingModel({
    required this.bookingId,
    required this.studentId,
    required this.propertyId,
    required this.roomId,
    required this.propertyName,
    required this.roomDescription,
    required this.studentName,
    required this.studentEmail,
    this.studentPhone,
    required this.status,
    required this.requestedAt,
    this.respondedAt,
    this.ownerNotes,
    this.studentNotes,
    this.moveInDate,
    this.durationMonths = 1,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      bookingId: doc.id,
      studentId: data['studentId'] as String? ?? '',
      propertyId: data['propertyId'] as String? ?? '',
      roomId: data['roomId'] as String? ?? '',
      propertyName: data['propertyName'] as String? ?? '',
      roomDescription: data['roomDescription'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      studentEmail: data['studentEmail'] as String? ?? '',
      studentPhone: data['studentPhone'] as String?,
      status: BookingStatus.values.firstWhere(
        (s) => s.name == (data['status'] as String? ?? 'pending'),
        orElse: () => BookingStatus.pending,
      ),
      requestedAt: (data['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
      ownerNotes: data['ownerNotes'] as String?,
      studentNotes: data['studentNotes'] as String?,
      moveInDate: (data['moveInDate'] as Timestamp?)?.toDate(),
      durationMonths: (data['durationMonths'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'propertyId': propertyId,
      'roomId': roomId,
      'propertyName': propertyName,
      'roomDescription': roomDescription,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'studentPhone': studentPhone,
      'status': status.name,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'ownerNotes': ownerNotes,
      'studentNotes': studentNotes,
      'moveInDate': moveInDate != null ? Timestamp.fromDate(moveInDate!) : null,
      'durationMonths': durationMonths,
    };
  }

  BookingModel copyWith({
    String? bookingId,
    String? studentId,
    String? propertyId,
    String? roomId,
    String? propertyName,
    String? roomDescription,
    String? studentName,
    String? studentEmail,
    String? studentPhone,
    BookingStatus? status,
    DateTime? requestedAt,
    DateTime? respondedAt,
    String? ownerNotes,
    String? studentNotes,
    DateTime? moveInDate,
    int? durationMonths,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      studentId: studentId ?? this.studentId,
      propertyId: propertyId ?? this.propertyId,
      roomId: roomId ?? this.roomId,
      propertyName: propertyName ?? this.propertyName,
      roomDescription: roomDescription ?? this.roomDescription,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      studentPhone: studentPhone ?? this.studentPhone,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      ownerNotes: ownerNotes ?? this.ownerNotes,
      studentNotes: studentNotes ?? this.studentNotes,
      moveInDate: moveInDate ?? this.moveInDate,
      durationMonths: durationMonths ?? this.durationMonths,
    );
  }

  String get statusLabel {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  Color get statusColor {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFFFA000);
      case BookingStatus.approved:
        return Colors.green;
      case BookingStatus.rejected:
        return Colors.red;
      case BookingStatus.cancelled:
        return Colors.grey;
      case BookingStatus.completed:
        return const Color(0xFF5287B2);
    }
  }

  @override
  String toString() => 'BookingModel(id: $bookingId, status: $status)';
}
