// Run from the repository root: dart run tool/crop_menu_poster.dart
import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final manifest =
      jsonDecode(File('docs/menu-poster-crops.json').readAsStringSync())
          as Map<String, dynamic>;
  final source = img.decodeImage(
    File(manifest['source'] as String).readAsBytesSync(),
  )!;
  for (final entry in manifest['crops'] as List) {
    final rect = (entry['rect'] as List).cast<int>();
    final crop = img.copyCrop(
      source,
      x: rect[0],
      y: rect[1],
      width: rect[2],
      height: rect[3],
    );
    File(
      entry['file'] as String,
    ).writeAsBytesSync(img.encodeJpg(crop, quality: 94));
  }
}
