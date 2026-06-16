import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  final dir = Directory('images');
  if (!await dir.exists()) {
    print('Error: images directory not found');
    return;
  }

  print('Scanning images directory...');
  final files = await dir.list().toList();
  var processed = 0;

  for (final entity in files) {
    if (entity is! File) continue;

    final file = entity;
    final path = file.path.toLowerCase();
    
    if (!path.endsWith('.png') && !path.endsWith('.jpg') && !path.endsWith('.jpeg')) {
      continue;
    }

    print('Optimizing ${file.path}...');
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        print('Failed to decode ${file.path}');
        continue;
      }

      // Determine dimensions
      var width = image.width;
      var height = image.height;
      final maxDimension = 800;

      img.Image resizedImage = image;
      if (width > maxDimension || height > maxDimension) {
        if (width > height) {
          height = (height * (maxDimension / width)).round();
          width = maxDimension;
        } else {
          width = (width * (maxDimension / height)).round();
          height = maxDimension;
        }
        print('  Resizing from ${image.width}x${image.height} to ${width}x${height}...');
        resizedImage = img.copyResize(image, width: width, height: height);
      }

      List<int> compressedBytes;
      if (path.endsWith('.png')) {
        print('  Compressing PNG...');
        compressedBytes = img.encodePng(resizedImage, level: 6);
      } else {
        print('  Compressing JPEG...');
        compressedBytes = img.encodeJpg(resizedImage, quality: 75);
      }

      // Save in-place
      await file.writeAsBytes(compressedBytes);
      print('  Saved: ${file.path} (${compressedBytes.length} bytes)');
      processed++;
    } catch (e) {
      print('Error processing ${file.path}: $e');
    }
  }

  print('\nOptimization complete! Processed $processed image(s).');
}
