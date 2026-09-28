import 'dart:async';
import 'dart:js' as js;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Best-effort current position. Returns null when location is unavailable,
/// denied, or times out — never throws.
Future<LatLng?> currentPosition() async {
  try {
    if (kIsWeb) return await _webPosition();
    return await _mobilePosition();
  } catch (_) {
    return null;
  }
}

Future<LatLng?> _mobilePosition() async {
  final enabled = await Geolocator.isLocationServiceEnabled().timeout(
    const Duration(seconds: 5),
    onTimeout: () => false,
  );
  if (!enabled) return null;

  var permission = await Geolocator.checkPermission().timeout(
    const Duration(seconds: 5),
    onTimeout: () => LocationPermission.denied,
  );
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission().timeout(
      const Duration(seconds: 10),
      onTimeout: () => LocationPermission.denied,
    );
    if (permission == LocationPermission.denied) return null;
  }
  if (permission == LocationPermission.deniedForever) return null;

  final pos = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  ).timeout(const Duration(seconds: 10));
  return LatLng(pos.latitude, pos.longitude);
}

Future<LatLng?> _webPosition() async {
  if (js.context['navigator']['geolocation'] == null) return null;
  final completer = Completer<LatLng?>();
  js.context['_posOk'] = (pos) {
    final c = pos['coords'];
    completer.complete(LatLng(c['latitude'], c['longitude']));
  };
  js.context['_posErr'] = (_) => completer.complete(null);
  js.context.callMethod('eval', [
    '''navigator.geolocation.getCurrentPosition(
      function(p) { window._posOk(p); },
      function(e) { window._posErr(e); },
      { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
    );''',
  ]);
  return completer.future.timeout(
    const Duration(seconds: 12),
    onTimeout: () => null,
  );
}
