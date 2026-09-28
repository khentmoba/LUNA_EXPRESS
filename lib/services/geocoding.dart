import 'dart:convert';
import 'package:http/http.dart' as http;

const maptilerKey = 'WdrFoTJ8mK1mg0cZdDoM';
const tileUrl =
    'https://api.maptiler.com/maps/streets-v2/256/{z}/{x}/{y}.png?key=$maptilerKey';
const _searchUrl =
    'https://nominatim.openstreetmap.org/search?format=json&addressdetails=1&limit=5';
const reverseUrl =
    'https://nominatim.openstreetmap.org/reverse?format=json&zoom=18&addressdetails=1';

/// 'road, suburb, city' style short label from a Nominatim address object.
String shortAddress(Map<String, dynamic>? address) {
  if (address == null) return '';
  final parts = <String>[];
  if (address['road'] != null) parts.add(address['road'] as String);
  if (address['suburb'] != null) parts.add(address['suburb'] as String);
  final city = address['city'] ?? address['town'] ?? address['village'];
  if (city != null) parts.add(city as String);
  if (address['state'] != null && parts.length < 2) {
    parts.add(address['state'] as String);
  }
  return parts.join(', ');
}

/// Reverse-geocode to `(full, short)` display strings. Returns empty strings
/// on failure instead of throwing.
Future<({String full, String short})> reverseGeocode(
  double lat,
  double lng,
) async {
  try {
    final res = await http.get(
      Uri.parse('$reverseUrl&lat=$lat&lon=$lng'),
      headers: const {'Accept-Language': 'en'},
    );
    if (res.statusCode != 200) return (full: '', short: '');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final full = data['display_name'] as String? ?? '$lat, $lng';
    return (
      full: full,
      short: shortAddress(data['address'] as Map<String, dynamic>?),
    );
  } catch (_) {
    return (full: '', short: '');
  }
}

/// Forward-geocode a query. Returns raw Nominatim results, [] on failure.
Future<List<Map<String, dynamic>>> searchAddress(String query) async {
  try {
    final res = await http.get(
      Uri.parse('$_searchUrl&q=${Uri.encodeComponent(query)}'),
      headers: const {'Accept-Language': 'en'},
    );
    if (res.statusCode != 200) return [];
    return (jsonDecode(res.body) as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  } catch (_) {
    return [];
  }
}
