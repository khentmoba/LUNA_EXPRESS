import 'dart:math';

/// Delivery fee math. Fee = ₱39/km from the nearest kitchen.
const storeLat = 9.0205090;
const storeLng = 125.5175910;
const base2Lat = 9.1212590;
const base2Lng = 125.5429739;
const feePerKm = 39;

double haversine(double lat1, double lng1, double lat2, double lng2) {
  const p = 0.017453292519943295;
  final a =
      0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lng2 - lng1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

/// Distance + fee from the nearer kitchen to [lat]/[lng].
({double distance, int fee}) deliveryQuote(double lat, double lng) {
  final toStore = haversine(storeLat, storeLng, lat, lng);
  final toBase2 = haversine(base2Lat, base2Lng, lat, lng);
  final distance = min(toStore, toBase2);
  return (distance: distance, fee: (distance * feePerKm).round());
}
