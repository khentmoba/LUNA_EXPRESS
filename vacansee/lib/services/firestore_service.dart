import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';
import '../models/room_model.dart';

/// Exception for Firestore-related errors
class FirestoreException implements Exception {
  final String message;
  const FirestoreException(this.message);

  @override
  String toString() => 'FirestoreException: $message';
}

/// Firestore service for property and room operations
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==================== Properties ====================

  /// Get all verified properties
  Stream<List<PropertyModel>> getVerifiedProperties() {
    return _firestore
        .collection('properties')
        .where('isVerified', isEqualTo: true)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PropertyModel.fromFirestore(doc)).toList());
  }

  /// Get properties by owner ID
  Stream<List<PropertyModel>> getPropertiesByOwner(String ownerId) {
    return _firestore
        .collection('properties')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PropertyModel.fromFirestore(doc)).toList());
  }

  /// Get single property by ID
  Future<PropertyModel?> getProperty(String propertyId) async {
    try {
      final doc = await _firestore.collection('properties').doc(propertyId).get();
      if (!doc.exists) return null;
      return PropertyModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to fetch property: ${e.message}');
    }
  }

  /// Create a new property
  Future<String> createProperty(PropertyModel property) async {
    try {
      final ref = _firestore.collection('properties').doc();
      final newProperty = property.copyWith(propertyId: ref.id);
      await ref.set(newProperty.toFirestore());
      return ref.id;
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to create property: ${e.message}');
    }
  }

  /// Update an existing property
  Future<void> updateProperty(PropertyModel property) async {
    try {
      await _firestore
          .collection('properties')
          .doc(property.propertyId)
          .update(property.toFirestore());
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to update property: ${e.message}');
    }
  }

  /// Delete a property
  Future<void> deleteProperty(String propertyId) async {
    try {
      // Delete all rooms in the property first
      final rooms = await _firestore
          .collection('properties')
          .doc(propertyId)
          .collection('rooms')
          .get();

      final batch = _firestore.batch();
      for (final room in rooms.docs) {
        batch.delete(room.reference);
      }
      batch.delete(_firestore.collection('properties').doc(propertyId));
      await batch.commit();
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to delete property: ${e.message}');
    }
  }

  /// Search properties with filters
  Stream<List<PropertyModel>> searchProperties({
    GenderOrientation? genderOrientation,
    int? maxPrice,
    bool verifiedOnly = true,
  }) {
    Query query = _firestore.collection('properties');

    if (verifiedOnly) {
      query = query.where('isVerified', isEqualTo: true);
    }

    if (genderOrientation != null) {
      query = query.where('genderOrientation', isEqualTo: genderOrientation.name);
    }

    // Note: Firestore doesn't support range filters on different fields
    // Price filtering will be done client-side for MVP
    return query.snapshots().map((snapshot) {
      var properties = snapshot.docs
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();

      // Client-side price filtering
      if (maxPrice != null) {
        properties = properties
            .where((p) => p.priceRange.min <= maxPrice)
            .toList();
      }

      return properties;
    });
  }

  // ==================== Rooms ====================

  /// Get all rooms for a property
  Stream<List<RoomModel>> getRooms(String propertyId) {
    return _firestore
        .collection('properties')
        .doc(propertyId)
        .collection('rooms')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoomModel.fromFirestore(doc, propertyId: propertyId))
            .toList());
  }

  /// Get single room
  Future<RoomModel?> getRoom(String propertyId, String roomId) async {
    try {
      final doc = await _firestore
          .collection('properties')
          .doc(propertyId)
          .collection('rooms')
          .doc(roomId)
          .get();

      if (!doc.exists) return null;
      return RoomModel.fromFirestore(doc, propertyId: propertyId);
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to fetch room: ${e.message}');
    }
  }

  /// Create a new room
  Future<String> createRoom(RoomModel room) async {
    try {
      final ref = _firestore
          .collection('properties')
          .doc(room.propertyId)
          .collection('rooms')
          .doc();

      final newRoom = room.copyWith(roomId: ref.id);
      await ref.set(newRoom.toFirestore());
      return ref.id;
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to create room: ${e.message}');
    }
  }

  /// Update room - CRITICAL for vacancy toggle
  Future<void> updateRoom(RoomModel room) async {
    try {
      await _firestore
          .collection('properties')
          .doc(room.propertyId)
          .collection('rooms')
          .doc(room.roomId)
          .update({
            ...room.toFirestore(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      // Also update property's lastUpdated
      await _firestore
          .collection('properties')
          .doc(room.propertyId)
          .update({'lastUpdated': FieldValue.serverTimestamp()});
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to update room: ${e.message}');
    }
  }

  /// Toggle room vacancy status - CORE FEATURE
  Future<void> toggleVacancy(String propertyId, String roomId, RoomStatus newStatus) async {
    try {
      await _firestore
          .collection('properties')
          .doc(propertyId)
          .collection('rooms')
          .doc(roomId)
          .update({
            'status': newStatus.name,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      // Update property's lastUpdated timestamp
      await _firestore
          .collection('properties')
          .doc(propertyId)
          .update({'lastUpdated': FieldValue.serverTimestamp()});
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to toggle vacancy: ${e.message}');
    }
  }

  /// Delete a room
  Future<void> deleteRoom(String propertyId, String roomId) async {
    try {
      await _firestore
          .collection('properties')
          .doc(propertyId)
          .collection('rooms')
          .doc(roomId)
          .delete();
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to delete room: ${e.message}');
    }
  }
}
