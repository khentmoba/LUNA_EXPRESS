/// Status of a pasugo session.
enum SessionStatus {
  active,
  completed,
  cancelled;

  String toJson() => name;
  static SessionStatus fromJson(String json) =>
      SessionStatus.values.firstWhere((e) => e.name == json);

  String get displayName {
    switch (this) {
      case SessionStatus.active:
        return 'Active';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// A link record created when a rider accepts an errand.
class PasugoSession {
  final String? id;
  final String errandId;
  final String riderId;
  final String customerPhone;
  final SessionStatus status;
  final DateTime acceptedAt;
  final DateTime? completedAt;
  final String? cancelledBy;
  final String? cancellationReason;

  const PasugoSession({
    this.id,
    required this.errandId,
    required this.riderId,
    required this.customerPhone,
    this.status = SessionStatus.active,
    required this.acceptedAt,
    this.completedAt,
    this.cancelledBy,
    this.cancellationReason,
  });

  PasugoSession copyWith({
    String? id,
    String? errandId,
    String? riderId,
    String? customerPhone,
    SessionStatus? status,
    DateTime? acceptedAt,
    DateTime? completedAt,
    String? cancelledBy,
    String? cancellationReason,
  }) {
    return PasugoSession(
      id: id ?? this.id,
      errandId: errandId ?? this.errandId,
      riderId: riderId ?? this.riderId,
      customerPhone: customerPhone ?? this.customerPhone,
      status: status ?? this.status,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'errandId': errandId,
      'riderId': riderId,
      'customerPhone': customerPhone,
      'status': status.toJson(),
      'acceptedAt': acceptedAt.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      if (cancelledBy != null) 'cancelledBy': cancelledBy,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
    };
  }

  factory PasugoSession.fromMap(Map<String, dynamic> map, {String? id}) {
    return PasugoSession(
      id: id ?? map['id'] as String?,
      errandId: map['errandId'] as String,
      riderId: map['riderId'] as String,
      customerPhone: map['customerPhone'] as String,
      status: SessionStatus.fromJson(map['status'] as String? ?? 'active'),
      acceptedAt: DateTime.parse(map['acceptedAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      cancelledBy: map['cancelledBy'] as String?,
      cancellationReason: map['cancellationReason'] as String?,
    );
  }
}
