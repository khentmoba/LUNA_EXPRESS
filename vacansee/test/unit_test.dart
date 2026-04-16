// Unit tests for VacanSee models

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacansee/models/models.dart';

void main() {
  group('UserModel', () {
    test('can create a user model', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        role: UserRole.student,
        createdAt: DateTime(2025, 1, 1),
      );

      expect(user.uid, 'test-uid');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.role, UserRole.student);
    });

    test('copyWith creates a new instance with updated fields', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        role: UserRole.student,
        createdAt: DateTime(2025, 1, 1),
      );

      final updated = user.copyWith(displayName: 'Updated Name');

      expect(updated.uid, 'test-uid'); // unchanged
      expect(updated.displayName, 'Updated Name'); // changed
    });
  });

  group('PropertyModel', () {
    test('can create a property model', () {
      final property = PropertyModel(
        propertyId: 'prop-1',
        ownerId: 'owner-1',
        name: 'Test Property',
        address: '123 Test St',
        location: const GeoPoint(8.5, 124.6),
        genderOrientation: GenderOrientation.male,
        amenities: ['wifi', 'ac'],
        priceRange: const PriceRange(min: 3000, max: 5000),
        isVerified: true,
        lastUpdated: DateTime(2025, 1, 1),
      );

      expect(property.propertyId, 'prop-1');
      expect(property.name, 'Test Property');
      expect(property.isVerified, true);
    });

    test('price range formats correctly', () {
      const priceRange = PriceRange(min: 3000, max: 5000);
      expect(priceRange.formatted, '₱3000 - ₱5000');
    });
  });

  group('RoomModel', () {
    test('can create a room model', () {
      final room = RoomModel(
        roomId: 'room-1',
        propertyId: 'prop-1',
        status: RoomStatus.vacant,
        images: ['url1', 'url2'],
        capacity: 4,
        lastUpdated: DateTime(2025, 1, 1),
      );

      expect(room.roomId, 'room-1');
      expect(room.status, RoomStatus.vacant);
      expect(room.hasVacancy, true);
    });

    test('vacant room has vacancy', () {
      final room = RoomModel(
        roomId: 'room-1',
        propertyId: 'prop-1',
        status: RoomStatus.vacant,
        images: [],
        capacity: 2,
        lastUpdated: DateTime(2025, 1, 1),
      );

      expect(room.hasVacancy, true);
    });

    test('occupied room shows correct availability', () {
      final room = RoomModel(
        roomId: 'room-1',
        propertyId: 'prop-1',
        status: RoomStatus.occupied,
        images: [],
        capacity: 4,
        currentOccupants: 2,
        lastUpdated: DateTime(2025, 1, 1),
      );

      expect(room.status, RoomStatus.occupied);
      expect(room.availableSlots, 2);
    });

    test('copyWith preserves unmodified fields', () {
      final room = RoomModel(
        roomId: 'room-1',
        propertyId: 'prop-1',
        status: RoomStatus.vacant,
        images: ['url1'],
        capacity: 2,
        lastUpdated: DateTime(2025, 1, 1),
      );

      final updated = room.copyWith(status: RoomStatus.occupied);

      expect(updated.roomId, 'room-1');
      expect(updated.status, RoomStatus.occupied);
      expect(updated.capacity, 2);
    });
  });
}
