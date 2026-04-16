import 'package:cloud_firestore/cloud_firestore.dart';

/// Room vacancy status - the core feature of VacanSee
enum RoomStatus {
  vacant,
  occupied,
}

/// Room model representing individual rooms within a property
class RoomModel {
  final String roomId;
  final String propertyId;
  final RoomStatus status;
  final List<String> images;
  final int capacity;
  final int? currentOccupants;
  final int? monthlyRate;
  final String? description;
  final DateTime lastUpdated;

  const RoomModel({
    required this.roomId,
    required this.propertyId,
    required this.status,
    required this.images,
    required this.capacity,
    this.currentOccupants,
    this.monthlyRate,
    this.description,
    required this.lastUpdated,
  });

  factory RoomModel.fromFirestore(DocumentSnapshot doc, {String? propertyId}) {
    final data = doc.data() as Map<String, dynamic>;
    return RoomModel(
      roomId: doc.id,
      propertyId: propertyId ?? data['propertyId'] as String? ?? '',
      status: RoomStatus.values.firstWhere(
        (s) => s.name == (data['status'] as String? ?? 'vacant'),
        orElse: () => RoomStatus.vacant,
      ),
      images: List<String>.from(data['images'] as List? ?? []),
      capacity: (data['capacity'] as num?)?.toInt() ?? 1,
      currentOccupants: (data['currentOccupants'] as num?)?.toInt(),
      monthlyRate: (data['monthlyRate'] as num?)?.toInt(),
      description: data['description'] as String?,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'propertyId': propertyId,
      'status': status.name,
      'images': images,
      'capacity': capacity,
      'currentOccupants': currentOccupants,
      'monthlyRate': monthlyRate,
      'description': description,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Check if room has available slots
  bool get hasVacancy {
    if (status == RoomStatus.vacant) return true;
    if (currentOccupants == null || capacity == 0) return false;
    return currentOccupants! < capacity;
  }

  /// Get available slots count
  int get availableSlots {
    if (capacity == 0) return 0;
    return capacity - (currentOccupants ?? 0);
  }

  RoomModel copyWith({
    String? roomId,
    String? propertyId,
    RoomStatus? status,
    List<String>? images,
    int? capacity,
    int? currentOccupants,
    int? monthlyRate,
    String? description,
    DateTime? lastUpdated,
  }) {
    return RoomModel(
      roomId: roomId ?? this.roomId,
      propertyId: propertyId ?? this.propertyId,
      status: status ?? this.status,
      images: images ?? this.images,
      capacity: capacity ?? this.capacity,
      currentOccupants: currentOccupants ?? this.currentOccupants,
      monthlyRate: monthlyRate ?? this.monthlyRate,
      description: description ?? this.description,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() => 'RoomModel(id: $roomId, status: $status)';
}
