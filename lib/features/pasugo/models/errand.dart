import 'package:cloud_firestore/cloud_firestore.dart';

/// Status options for an errand (pasugo post).
enum ErrandStatus {
  available,
  accepted,
  completed,
  cancelled;

  String toJson() => name;
  static ErrandStatus fromJson(String json) =>
      ErrandStatus.values.firstWhere((e) => e.name == json);

  String get displayName {
    switch (this) {
      case ErrandStatus.available:
        return 'Available';
      case ErrandStatus.accepted:
        return 'Accepted';
      case ErrandStatus.completed:
        return 'Completed';
      case ErrandStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// A bulletin board listing created by a customer.
class Errand {
  final String? id;
  final String customerName;
  final String customerPhone;
  final String phoneHash;
  final String pinHash;
  final String message;
  final GeoPoint? locationPin;
  final ErrandStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;

  const Errand({
    this.id,
    required this.customerName,
    required this.customerPhone,
    required this.phoneHash,
    required this.pinHash,
    required this.message,
    this.locationPin,
    this.status = ErrandStatus.available,
    required this.createdAt,
    required this.expiresAt,
  });

  Errand copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? phoneHash,
    String? pinHash,
    String? message,
    GeoPoint? locationPin,
    bool clearLocationPin = false,
    ErrandStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Errand(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      phoneHash: phoneHash ?? this.phoneHash,
      pinHash: pinHash ?? this.pinHash,
      message: message ?? this.message,
      locationPin: clearLocationPin ? null : (locationPin ?? this.locationPin),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'phoneHash': phoneHash,
      'pinHash': pinHash,
      'message': message,
      if (locationPin != null) 'locationPin': locationPin,
      'status': status.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  factory Errand.fromMap(Map<String, dynamic> map, {String? id}) {
    return Errand(
      id: id ?? map['id'] as String?,
      customerName: map['customerName'] as String,
      customerPhone: map['customerPhone'] as String,
      phoneHash: map['phoneHash'] as String,
      pinHash: map['pinHash'] as String,
      message: map['message'] as String,
      locationPin: map['locationPin'] as GeoPoint?,
      status: ErrandStatus.fromJson(map['status'] as String? ?? 'available'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
    );
  }

  factory Errand.fromFirestore(DocumentSnapshot doc) {
    return Errand.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);
  }

  Map<String, dynamic> toFirestore() {
    final data = toMap();
    data.remove('id');
    return data;
  }
}
