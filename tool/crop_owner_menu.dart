// Run from the repository root: dart run tool/crop_owner_menu.dart
import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final manifest =
      jsonDecode(File('docs/owner-menu-crops.json').readAsStringSync())
          as Map<String, dynamic>;
  for (final entry in manifest['crops'] as List) {
    final sourceFile = 'docs/reference/menu-update/${entry['source']}';
    final source = img.decodeImage(File(sourceFile).readAsBytesSync())!;
    final rect = (entry['rect'] as List).cast<int>();
    if (rect[0] < 0 ||
        rect[1] < 0 ||
        rect[0] + rect[2] > source.width ||
        rect[1] + rect[3] > source.height) {
      throw StateError('Crop outside source image: $sourceFile');
    }
    var crop = img.copyCrop(
      source,
      x: rect[0],
      y: rect[1],
      width: rect[2],
      height: rect[3],
    );
    if (crop.width > 900 || crop.height > 900) {
      crop = crop.width >= crop.height
          ? img.copyResize(crop, width: 900)
          : img.copyResize(crop, height: 900);
    }
    File(
      entry['file'] as String,
    ).writeAsBytesSync(img.encodeJpg(crop, quality: 90));
    stdout.writeln(entry['file']);
  }
}
