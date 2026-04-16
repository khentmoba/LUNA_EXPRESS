import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';
import '../models/room_model.dart';

/// Service for property CRUD operations
class PropertyService {
  final FirebaseFirestore _firestore;

  PropertyService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _properties => _firestore.collection('properties');

  /// Create a new property
  Future<PropertyModel> createProperty({
    required String ownerId,
    required String name,
    required String address,
    required GeoPoint location,
    required GenderOrientation genderOrientation,
    required List<String> amenities,
    required PriceRange priceRange,
    String? description,
    String? coverImageUrl,
  }) async {
    final docRef = _properties.doc();
    final property = PropertyModel(
      propertyId: docRef.id,
      ownerId: ownerId,
      name: name,
      address: address,
      location: location,
      genderOrientation: genderOrientation,
      amenities: amenities,
      priceRange: priceRange,
      isVerified: false,
      lastUpdated: DateTime.now(),
      description: description,
      coverImageUrl: coverImageUrl,
    );

    await docRef.set(property.toFirestore());
    return property;
  }

  /// Get a single property by ID
  Future<PropertyModel?> getProperty(String propertyId) async {
    final doc = await _properties.doc(propertyId).get();
    if (!doc.exists) return null;
    return PropertyModel.fromFirestore(doc);
  }

  /// Get all properties with optional filters
  Stream<List<PropertyModel>> getProperties({
    String? ownerId,
    GenderOrientation? genderOrientation,
    int? minPrice,
    int? maxPrice,
    List<String>? amenities,
    String? searchQuery,
  }) {
    Query query = _properties;

    // Apply filters
    if (ownerId != null) {
      query = query.where('ownerId', isEqualTo: ownerId);
    }
    if (genderOrientation != null) {
      query = query.where('genderOrientation', isEqualTo: genderOrientation.name);
    }

    // Note: For complex price filtering, we'll do it client-side
    // Firestore doesn't support range queries on multiple fields well

    return query.snapshots().map((snapshot) {
      var properties = snapshot.docs
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();

      // Client-side filtering for price and amenities
      if (minPrice != null) {
        properties = properties.where((p) => p.priceRange.min >= minPrice).toList();
      }
      if (maxPrice != null) {
        properties = properties.where((p) => p.priceRange.max <= maxPrice).toList();
      }
      if (amenities != null && amenities.isNotEmpty) {
        properties = properties
            .where((p) => amenities.every((a) => p.amenities.contains(a)))
            .toList();
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        properties = properties.where((p) {
          return p.name.toLowerCase().contains(lowerQuery) ||
              p.address.toLowerCase().contains(lowerQuery);
        }).toList();
      }

      return properties;
    });
  }

  /// Update a property
  Future<void> updateProperty(PropertyModel property) async {
    final updated = property.copyWith(lastUpdated: DateTime.now());
    await _properties.doc(property.propertyId).update(updated.toFirestore());
  }

  /// Delete a property and its rooms
  Future<void> deleteProperty(String propertyId) async {
    // Delete all rooms first (subcollection)
    final roomsSnapshot = await _properties
        .doc(propertyId)
        .collection('rooms')
        .get();
    
    final batch = _firestore.batch();
    for (var doc in roomsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_properties.doc(propertyId));
    
    await batch.commit();
  }

  /// Add a room to a property
  Future<RoomModel> addRoom({
    required String propertyId,
    required int capacity,
    required int monthlyRate,
    RoomStatus status = RoomStatus.vacant,
    List<String>? images,
    String? description,
  }) async {
    final docRef = _properties.doc(propertyId).collection('rooms').doc();
    final room = RoomModel(
      roomId: docRef.id,
      propertyId: propertyId,
      status: status,
      images: images ?? [],
      capacity: capacity,
      monthlyRate: monthlyRate,
      description: description,
      lastUpdated: DateTime.now(),
    );

    await docRef.set(room.toFirestore());
    return room;
  }

  /// Get rooms for a property
  Stream<List<RoomModel>> getRooms(String propertyId) {
    return _properties
        .doc(propertyId)
        .collection('rooms')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => RoomModel.fromFirestore(doc)).toList());
  }

  /// Update room status
  Future<void> updateRoomStatus(
    String propertyId,
    String roomId,
    RoomStatus status,
  ) async {
    await _properties
        .doc(propertyId)
        .collection('rooms')
        .doc(roomId)
        .update({'status': status.name, 'lastUpdated': Timestamp.now()});
  }

  /// Delete a room
  Future<void> deleteRoom(String propertyId, String roomId) async {
    await _properties
        .doc(propertyId)
        .collection('rooms')
        .doc(roomId)
        .delete();
  }

  /// Get properties by owner
  Stream<List<PropertyModel>> getOwnerProperties(String ownerId) {
    return _properties
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PropertyModel.fromFirestore(doc)).toList());
  }
}

/// Exception for property operations
class PropertyException implements Exception {
  final String message;
  PropertyException(this.message);
  @override
  String toString() => 'PropertyException: $message';
}
