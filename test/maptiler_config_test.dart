import 'package:flutter_test/flutter_test.dart';
import 'package:luna_express/services/geocoding.dart';

// The map key is a build input, not source. `flutter test` normally runs with no
// key compiled in; pass `--dart-define=MAPTILER_KEY=...` to exercise the other
// branch. Both must hold: the tile template carries the key, or it is empty so
// no tile layer is created at all.
void main() {
  group('maptiler build configuration', () {
    test('tile template exists exactly when a key was compiled in', () {
      expect(tileUrl.isEmpty, maptilerKey.isEmpty);
    });

    test('the template never ships a placeholder or a stray key=', () {
      if (maptilerKey.isEmpty) {
        expect(tileUrl, isEmpty);
      } else {
        expect(tileUrl, startsWith('https://api.maptiler.com/'));
        expect(tileUrl, contains('key=$maptilerKey'));
        expect(tileUrl, contains('{z}'));
        expect(tileUrl, contains('{x}'));
        expect(tileUrl, contains('{y}'));
      }
    });
  });
}
