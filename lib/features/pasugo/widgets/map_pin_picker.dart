import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A map widget that lets the user drop a pin by tapping.
/// Defaults to a Philippines-centered view if no location is provided.
class MapPinPicker extends StatefulWidget {
  final void Function(GeoPoint geoPoint) onPinSelected;
  final LatLng? initialLocation;

  const MapPinPicker({
    super.key,
    required this.onPinSelected,
    this.initialLocation,
  });

  @override
  State<MapPinPicker> createState() => _MapPinPickerState();
}

class _MapPinPickerState extends State<MapPinPicker> {
  // Default center: Manila, Philippines
  static const LatLng _defaultCenter = LatLng(14.5995, 120.9842);

  late LatLng _center;
  LatLng? _pinnedLocation;

  @override
  void initState() {
    super.initState();
    _center = widget.initialLocation ?? _defaultCenter;
  }

  void _handleTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _pinnedLocation = point;
    });
    widget.onPinSelected(GeoPoint(point.latitude, point.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 12.0,
              onTap: _handleTap,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.lunaexpress.app',
              ),
              if (_pinnedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pinnedLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Helper overlay text
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Tap on the map to drop a pin',
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
