import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Service for Firebase Storage operations
class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Upload property image to Firebase Storage
  /// Returns the download URL
  Future<String> uploadPropertyImage({
    required String propertyId,
    required File file,
    String? filename,
  }) async {
    try {
      final name = filename ?? DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('properties/$propertyId/images/$name.jpg');
      
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'propertyId': propertyId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw StorageException('Failed to upload image: $e');
    }
  }

  /// Upload multiple property images
  /// Returns list of download URLs
  Future<List<String>> uploadPropertyImages({
    required String propertyId,
    required List<File> files,
  }) async {
    final urls = <String>[];
    
    for (var i = 0; i < files.length; i++) {
      final url = await uploadPropertyImage(
        propertyId: propertyId,
        file: files[i],
        filename: 'image_$i',
      );
      urls.add(url);
    }
    
    return urls;
  }

  /// Delete property image from storage
  Future<void> deletePropertyImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw StorageException('Failed to delete image: $e');
    }
  }

  /// Delete all images for a property
  Future<void> deletePropertyImages(String propertyId) async {
    try {
      final ref = _storage.ref().child('properties/$propertyId/images');
      final listResult = await ref.listAll();
      
      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      throw StorageException('Failed to delete property images: $e');
    }
  }

  /// Upload room image
  Future<String> uploadRoomImage({
    required String propertyId,
    required String roomId,
    required File file,
  }) async {
    try {
      final name = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('properties/$propertyId/rooms/$roomId/$name.jpg');
      
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'propertyId': propertyId,
            'roomId': roomId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw StorageException('Failed to upload room image: $e');
    }
  }

  /// Get storage reference from URL
  Reference getRefFromUrl(String url) {
    return _storage.refFromURL(url);
  }
}

/// Exception for storage operations
class StorageException implements Exception {
  final String message;
  StorageException(this.message);
  @override
  String toString() => 'StorageException: $message';
}
