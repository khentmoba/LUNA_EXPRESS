# Tech Stack & Tools

- **Frontend:** Flutter Web (Dart 3.x)
- **Backend:** Firebase (BaaS)
- **Database:** Cloud Firestore (NoSQL, real-time)
- **Authentication:** Firebase Auth (Email/Password, Google Sign-In)
- **Storage:** Firebase Storage (property/room images)
- **Hosting:** Firebase Hosting (SSL, global CDN)
- **AI Integration:** Gemini API (room description generation, content moderation)

## Project Structure
```
vacansee/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── models/           # Data models (Property, Room, User)
│   ├── providers/        # State management (Provider/Riverpod)
│   ├── services/         # Firebase repos, API calls
│   ├── screens/          # Page widgets
│   ├── widgets/          # Reusable components
│   └── utils/            # Helpers, constants
├── test/
├── web/
├── android/
├── ios/
└── pubspec.yaml
```

## Key Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.x
  firebase_auth: ^4.x
  cloud_firestore: ^4.x
  firebase_storage: ^11.x
  provider: ^6.x  # or riverpod
  google_maps_flutter: ^2.x
  geolocator: ^10.x
  image_picker: ^1.x
  cached_network_image: ^3.x
```

## Error Handling Pattern
```dart
// Repository pattern with proper error handling
class PropertyRepository {
  final FirebaseFirestore _firestore;

  Future<List<Property>> getPropertiesByFilter({
    required String genderOrientation,
    required int maxPrice,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('properties')
          .where('genderOrientation', isEqualTo: genderOrientation)
          .where('priceRange.max', isLessThanOrEqualTo: maxPrice)
          .where('isVerified', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Property.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw PropertyException('Failed to fetch properties: ${e.message}');
    } catch (e) {
      throw PropertyException('Unexpected error: $e');
    }
  }
}
```

## Styling & Component Examples
```dart
// RoomCard widget showing vacancy status
class RoomCard extends StatelessWidget {
  final Room room;
  final Property property;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Room image
          CachedNetworkImage(imageUrl: room.images.first),
          // Price and gender tag
          Row(
            children: [
              Text('₱${property.priceRange.min} - ${property.priceRange.max}'),
              Chip(label: Text(property.genderOrientation)),
            ],
          ),
          // Vacancy badge (CRITICAL FEATURE)
          Container(
            color: room.status == 'Vacant' ? Colors.green : Colors.red,
            child: Text(room.status),
          ),
        ],
      ),
    );
  }
}
```

## Naming Conventions
- **Files:** snake_case (e.g., `property_card.dart`)
- **Classes:** PascalCase (e.g., `PropertyCard`)
- **Variables:** camelCase (e.g., `propertyList`)
- **Constants:** camelCase (e.g., `maxPriceRange`)
