import 'package:cloud_firestore/cloud_firestore.dart';

/// Gender orientation for boarding house filtering
enum GenderOrientation {
  male,
  female,
  mixed,
}

/// Property model representing a boarding house listing
class PropertyModel {
  final String propertyId;
  final String ownerId;
  final String name;
  final String address;
  final GeoPoint location;
  final GenderOrientation genderOrientation;
  final List<String> amenities;
  final PriceRange priceRange;
  final bool isVerified;
  final DateTime lastUpdated;
  final String? description;
  final String? coverImageUrl;
  final bool hasVacancy;

  const PropertyModel({
    required this.propertyId,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.location,
    required this.genderOrientation,
    required this.amenities,
    required this.priceRange,
    required this.isVerified,
    required this.lastUpdated,
    this.description,
    this.coverImageUrl,
    this.hasVacancy = true,
  });

  factory PropertyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PropertyModel(
      propertyId: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      location: data['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      genderOrientation: GenderOrientation.values.firstWhere(
        (g) => g.name == (data['genderOrientation'] as String? ?? 'mixed'),
        orElse: () => GenderOrientation.mixed,
      ),
      amenities: List<String>.from(data['amenities'] as List? ?? []),
      priceRange: PriceRange.fromMap(data['priceRange'] as Map<String, dynamic>?),
      isVerified: data['isVerified'] as bool? ?? false,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'] as String?,
      coverImageUrl: data['coverImageUrl'] as String?,
      hasVacancy: data['hasVacancy'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'location': location,
      'genderOrientation': genderOrientation.name,
      'amenities': amenities,
      'priceRange': priceRange.toMap(),
      'isVerified': isVerified,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'description': description,
      'coverImageUrl': coverImageUrl,
      'hasVacancy': hasVacancy,
    };
  }

  PropertyModel copyWith({
    String? propertyId,
    String? ownerId,
    String? name,
    String? address,
    GeoPoint? location,
    GenderOrientation? genderOrientation,
    List<String>? amenities,
    PriceRange? priceRange,
    bool? isVerified,
    DateTime? lastUpdated,
    String? description,
    String? coverImageUrl,
    bool? hasVacancy,
  }) {
    return PropertyModel(
      propertyId: propertyId ?? this.propertyId,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      address: address ?? this.address,
      location: location ?? this.location,
      genderOrientation: genderOrientation ?? this.genderOrientation,
      amenities: amenities ?? this.amenities,
      priceRange: priceRange ?? this.priceRange,
      isVerified: isVerified ?? this.isVerified,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      hasVacancy: hasVacancy ?? this.hasVacancy,
    );
  }

  @override
  String toString() => 'PropertyModel(id: $propertyId, name: $name)';
}

/// Price range for filtering
class PriceRange {
  final int min;
  final int max;

  const PriceRange({required this.min, required this.max});

  factory PriceRange.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PriceRange(min: 0, max: 0);
    return PriceRange(
      min: (map['min'] as num?)?.toInt() ?? 0,
      max: (map['max'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {'min': min, 'max': max};

  String get formatted => '₱$min - ₱$max';
}
