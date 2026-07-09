# Quickstart: Pasugo (Errand) System

## Prerequisites

- Flutter SDK ^3.11.3
- Firebase project with Auth, Firestore, and Cloud Messaging enabled
- Existing Luna Express app running

## Firestore Indexes

Create these composite indexes in Firebase Console:

| Collection | Fields | 
|------------|--------|
| `pasugo_errands` | `status` ASC, `createdAt` DESC |
| `pasugo_errands` | `customerPhone` ASC |
| `pasugo_sessions` | `riderId` ASC, `status` ASC |
| `pasugo_sessions` | `errandId` ASC |

## Firebase Security Rules

Add to `firestore.rules`:

```javascript
match /pasugo_errands/{errandId} {
  allow read: if true; // Public read for available errands
  allow create: if request.resource.data.customerName is string
              && request.resource.data.customerPhone is string
              && request.resource.data.message is string;
  allow update: if resource.data.status == 'available'
              && request.resource.data.status == 'cancelled'
              && request.resource.data.customerPhone == resource.data.customerPhone;
}

match /pasugo_sessions/{sessionId} {
  allow read: if request.auth != null || resource.data.customerPhone in [request.auth...];
  allow create: if request.auth.token.riderStatus == 'approved';
  allow update: if request.auth != null;
}

match /pasugo_sessions/{sessionId}/messages/{messageId} {
  allow read: if request.auth != null;
  allow create: if get(/databases/$(database)/documents/pasugo_sessions/$(sessionId)).data.status == 'active';
}
```

## App Integration

### 1. Add routes to `main.dart`

```dart
// Pasugo feature routes
MaterialPageRoute(builder: (_) => const PasugoScreen()),
MaterialPageRoute(builder: (_) => const BulletinBoardScreen()),
MaterialPageRoute(builder: (_) => const CreateErrandScreen()),
MaterialPageRoute(builder: (_) => const ChatScreen()),
MaterialPageRoute(builder: (_) => const RiderRegistrationScreen()),
MaterialPageRoute(builder: (_) => const RiderLoginScreen()),
```

### 2. Update landing screen

Add "Pasugo" button alongside "Order Now" on the Luna landing screen.

### 3. Add Provider for state management

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ErrandProvider()),
    ChangeNotifierProvider(create: (_) => SessionProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    ChangeNotifierProvider(create: (_) => RiderProvider()),
  ],
  child: MaterialApp(...),
);
```

## File Structure (Feature Module)

```text
lib/features/pasugo/
├── models/
│   ├── errand.dart
│   ├── rider.dart
│   ├── pasugo_session.dart
│   └── chat_message.dart
├── screens/
│   ├── pasugo_screen.dart          # "Pasugo" landing view
│   ├── create_errand_screen.dart   # Errand posting form
│   ├── bulletin_board_screen.dart  # Available errands list
│   ├── chat_screen.dart            # Customer-rider chat
│   ├── rider_registration_screen.dart
│   ├── rider_login_screen.dart
│   └── rider_dashboard_screen.dart # Rider's active sessions
├── widgets/
│   ├── errand_card.dart
│   ├── chat_bubble.dart
│   └── map_pin_picker.dart
├── services/
│   ├── errand_service.dart
│   ├── session_service.dart
│   ├── chat_service.dart
│   └── rider_auth_service.dart
├── providers/
│   ├── errand_provider.dart
│   ├── session_provider.dart
│   ├── chat_provider.dart
│   └── rider_provider.dart
└── admin/
    └── rider_management_screen.dart  # Admin dashboard for rider approvals
```

## Testing

```bash
# Unit tests for models and services
flutter test test/features/pasugo/models/
flutter test test/features/pasugo/services/

# Widget tests for screens
flutter test test/features/pasugo/screens/

# Integration tests (requires Firebase Emulator)
flutter test test/integration/pasugo_flow_test.dart
```

## Key Dependencies (already in pubspec.yaml)

- `firebase_auth` — rider authentication
- `cloud_firestore` — data storage + real-time chat
- `firebase_messaging` — push notifications
- `flutter_map` + `latlong2` — map pin display
- `geolocator` — location services for map
- `provider` — state management

## Development Sequence

1. **Data layer**: Create Firestore collections, indexes, and security rules
2. **Models**: Implement Dart data classes with fromMap/toMap
3. **Services**: Implement Firestore CRUD + real-time listeners
4. **Providers**: Connect services to UI state
5. **Screens**: Build UI screens (start with bulletin board + errand creation)
6. **Rider auth**: Implement Firebase Auth + custom claims integration
7. **Admin dashboard**: Add rider management to existing admin panel
8. **Chat**: Implement real-time messaging with Firestore snapshots
9. **Map pins**: Add optional GeoPoint picker and display
10. **Polish**: Edge cases, error handling, loading states
