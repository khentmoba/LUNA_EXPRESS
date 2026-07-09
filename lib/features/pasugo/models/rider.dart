/// Status of a rider's verification.
enum RiderStatus {
  pending,
  approved,
  rejected;

  String toJson() => name;
  static RiderStatus fromJson(String json) =>
      RiderStatus.values.firstWhere((e) => e.name == json);

  String get displayName {
    switch (this) {
      case RiderStatus.pending:
        return 'Pending';
      case RiderStatus.approved:
        return 'Approved';
      case RiderStatus.rejected:
        return 'Rejected';
    }
  }
}

/// A registered rider profile stored in the `riders` Firestore collection.
class Rider {
  final String? id;
  final String name;
  final String phone;
  final String address;
  final RiderStatus status;
  final DateTime registeredAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final bool isActive;

  const Rider({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.status = RiderStatus.pending,
    required this.registeredAt,
    this.approvedAt,
    this.approvedBy,
    this.isActive = true,
  });

  Rider copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    RiderStatus? status,
    DateTime? registeredAt,
    DateTime? approvedAt,
    String? approvedBy,
    bool? isActive,
  }) {
    return Rider(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'status': status.toJson(),
      'registeredAt': registeredAt.toIso8601String(),
      if (approvedAt != null) 'approvedAt': approvedAt!.toIso8601String(),
      if (approvedBy != null) 'approvedBy': approvedBy,
      'isActive': isActive,
    };
  }

  factory Rider.fromMap(Map<String, dynamic> map, {String? id}) {
    return Rider(
      id: id ?? map['id'] as String?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      status: RiderStatus.fromJson(map['status'] as String? ?? 'pending'),
      registeredAt: DateTime.parse(map['registeredAt'] as String),
      approvedAt: map['approvedAt'] != null
          ? DateTime.parse(map['approvedAt'] as String)
          : null,
      approvedBy: map['approvedBy'] as String?,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}
