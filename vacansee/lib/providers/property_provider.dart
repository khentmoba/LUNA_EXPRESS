import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';
import '../models/room_model.dart';
import '../services/property_service.dart';

/// Provider for property state management
class PropertyProvider extends ChangeNotifier {
  final PropertyService _propertyService;

  PropertyProvider({PropertyService? propertyService})
      : _propertyService = propertyService ?? PropertyService();

  // State
  List<PropertyModel> _properties = [];
  PropertyModel? _selectedProperty;
  List<RoomModel> _rooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  String? _searchQuery;
  GenderOrientation? _genderFilter;
  int? _minPrice;
  int? _maxPrice;
  List<String> _selectedAmenities = [];

  // Getters
  List<PropertyModel> get properties => _properties;
  PropertyModel? get selectedProperty => _selectedProperty;
  List<RoomModel> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get searchQuery => _searchQuery;
  GenderOrientation? get genderFilter => _genderFilter;
  int? get minPrice => _minPrice;
  int? get maxPrice => _maxPrice;
  List<String> get selectedAmenities => _selectedAmenities;

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Set search query
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set gender filter
  void setGenderFilter(GenderOrientation? gender) {
    _genderFilter = gender;
    notifyListeners();
  }

  /// Set price range
  void setPriceRange(int? min, int? max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  /// Toggle amenity selection
  void toggleAmenity(String amenity) {
    if (_selectedAmenities.contains(amenity)) {
      _selectedAmenities.remove(amenity);
    } else {
      _selectedAmenities.add(amenity);
    }
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = null;
    _genderFilter = null;
    _minPrice = null;
    _maxPrice = null;
    _selectedAmenities = [];
    notifyListeners();
  }

  /// Load all properties with current filters
  void loadProperties() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _propertyService
        .getProperties(
          searchQuery: _searchQuery,
          genderOrientation: _genderFilter,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          amenities: _selectedAmenities.isEmpty ? null : _selectedAmenities,
        )
        .listen(
          (properties) {
            _properties = properties;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Failed to load properties: $error';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Load properties for a specific owner
  void loadOwnerProperties(String ownerId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _propertyService.getOwnerProperties(ownerId).listen(
      (properties) {
        _properties = properties;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load properties: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Get a single property by ID
  Future<void> getProperty(String propertyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedProperty = await _propertyService.getProperty(propertyId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load property: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new property
  Future<bool> createProperty({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final property = await _propertyService.createProperty(
        ownerId: ownerId,
        name: name,
        address: address,
        location: location,
        genderOrientation: genderOrientation,
        amenities: amenities,
        priceRange: priceRange,
        description: description,
        coverImageUrl: coverImageUrl,
      );
      _properties.insert(0, property);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create property: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Create a new property and return the property model
  Future<PropertyModel> createPropertyWithId({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final property = await _propertyService.createProperty(
        ownerId: ownerId,
        name: name,
        address: address,
        location: location,
        genderOrientation: genderOrientation,
        amenities: amenities,
        priceRange: priceRange,
        description: description,
        coverImageUrl: coverImageUrl,
      );
      _properties.insert(0, property);
      _isLoading = false;
      notifyListeners();
      return property;
    } catch (e) {
      _errorMessage = 'Failed to create property: $e';
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  /// Update an existing property
  Future<bool> updateProperty(PropertyModel property) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _propertyService.updateProperty(property);
      final index = _properties.indexWhere((p) => p.propertyId == property.propertyId);
      if (index != -1) {
        _properties[index] = property;
      }
      if (_selectedProperty?.propertyId == property.propertyId) {
        _selectedProperty = property;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update property: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a property
  Future<bool> deleteProperty(String propertyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _propertyService.deleteProperty(propertyId);
      _properties.removeWhere((p) => p.propertyId == propertyId);
      if (_selectedProperty?.propertyId == propertyId) {
        _selectedProperty = null;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete property: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load rooms for a property
  void loadRooms(String propertyId) {
    _propertyService.getRooms(propertyId).listen(
      (rooms) {
        _rooms = rooms;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load rooms: $error';
        notifyListeners();
      },
    );
  }

  /// Add a room to a property
  Future<bool> addRoom({
    required String propertyId,
    required int capacity,
    required int monthlyRate,
    RoomStatus status = RoomStatus.vacant,
    List<String>? images,
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final room = await _propertyService.addRoom(
        propertyId: propertyId,
        capacity: capacity,
        monthlyRate: monthlyRate,
        status: status,
        images: images,
        description: description,
      );
      _rooms.add(room);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add room: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update room status
  Future<bool> updateRoomStatus(
    String propertyId,
    String roomId,
    RoomStatus status,
  ) async {
    try {
      await _propertyService.updateRoomStatus(propertyId, roomId, status);
      final index = _rooms.indexWhere((r) => r.roomId == roomId);
      if (index != -1) {
        _rooms[index] = _rooms[index].copyWith(status: status);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update room: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a room
  Future<bool> deleteRoom(String propertyId, String roomId) async {
    try {
      await _propertyService.deleteRoom(propertyId, roomId);
      _rooms.removeWhere((r) => r.roomId == roomId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete room: $e';
      notifyListeners();
      return false;
    }
  }

  /// Select a property
  void selectProperty(PropertyModel? property) {
    _selectedProperty = property;
    if (property != null) {
      loadRooms(property.propertyId);
    } else {
      _rooms = [];
    }
    notifyListeners();
  }
}

/// Exception for property operations
class PropertyProviderException implements Exception {
  final String message;
  PropertyProviderException(this.message);
  @override
  String toString() => 'PropertyProviderException: $message';
}
