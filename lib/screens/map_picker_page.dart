import 'dart:js' as js;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/kiosk/kiosk_theme.dart';

class MapPickerPage extends StatefulWidget {
  final String initialAddress;
  final double initialLat;
  final double initialLng;
  const MapPickerPage({
    super.key,
    required this.initialAddress,
    required this.initialLat,
    required this.initialLng,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  WebViewController? _webCtrl;
  late MapController _mapController;
  String _address = '';
  bool _loading = true;
  double _lat = 0, _lng = 0;

  @override
  void initState() {
    super.initState();
    _address = widget.initialAddress;
    _lat = widget.initialLat;
    _lng = widget.initialLng;
    _mapController = MapController();
    _getCurrentLocationAndInit();
  }

  Future<void> _getCurrentLocationAndInit() async {
    if (kIsWeb) {
      _getWebLocation();
      return;
    }

    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
      if (!serviceEnabled) {
        _initMapWithLocation(_lat, _lng);
        return;
      }

      permission = await Geolocator.checkPermission().timeout(
        const Duration(seconds: 5),
        onTimeout: () => LocationPermission.denied,
      );
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 10),
          onTimeout: () => LocationPermission.denied,
        );
        if (permission == LocationPermission.denied) {
          _initMapWithLocation(_lat, _lng);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _initMapWithLocation(_lat, _lng);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Location timeout'),
      );
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
      });
      _initMapWithLocation(_lat, _lng);
    } catch (e) {
      _initMapWithLocation(_lat, _lng);
    }
  }

  void _getWebLocation() {
    try {
      final geolocation = js.context['navigator']['geolocation'];
      if (geolocation == null) {
        _initMapWithLocation(_lat, _lng);
        return;
      }

      js.context['_geoSuccess'] = (pos) {
        final coords = pos['coords'];
        setState(() {
          _lat = coords['latitude'];
          _lng = coords['longitude'];
        });
        _initMapWithLocation(_lat, _lng);
      };

      js.context['_geoError'] = (_) {
        _initMapWithLocation(_lat, _lng);
      };

      js.context.callMethod('eval', ['''
        navigator.geolocation.getCurrentPosition(
          function(pos) { window._geoSuccess(pos); },
          function(err) { window._geoError(err); },
          { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
        );
      ''']);
    } catch (e) {
      _initMapWithLocation(_lat, _lng);
    }
  }

  void _initMapWithLocation(double lat, double lng) {
    if (!kIsWeb) {
      _webCtrl = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel('AddressChannel', onMessageReceived: (msg) {
          final parts = msg.message.split('||');
          if (parts.length >= 3) {
            setState(() {
              _address = parts[0];
              _lat = double.tryParse(parts[1]) ?? _lat;
              _lng = double.tryParse(parts[2]) ?? _lng;
              _loading = false;
            });
          }
        })
        ..loadHtmlString(_buildMapHtml(lat, lng));
    } else {
      setState(() => _loading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(LatLng(lat, lng), 16);
        _fetchAddress(lat, lng);
      });
    }
  }

  Future<void> _fetchAddress(double lat, double lng) async {
    final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1';
    try {
      final response = await http.get(Uri.parse(url), headers: {'Accept-Language': 'en'});
      if (response.statusCode == 200) {
        final data = response.body;
        final addressMatch = RegExp(r'"display_name"\s*:\s*"([^"]+)"').firstMatch(data);
        setState(() {
          _address = addressMatch != null ? addressMatch.group(1) ?? '' : '$lat, $lng';
        });
      }
    } catch (e) {
      setState(() {
        _address = '$lat, $lng';
      });
    }
  }

  String _buildMapHtml(double lat, double lng) => '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<style>
* { margin:0; padding:0; box-sizing:border-box; }
html, body { height:100%; width:100%; }
#map { height:100%; width:100%; }
#crosshair {
  position:fixed; top:50%; left:50%;
  transform:translate(-50%,-100%);
  z-index:9999; pointer-events:none;
  display:flex; flex-direction:column; align-items:center;
}
#crosshair .pin {
  width:32px; height:40px;
  background:#3D2A1D; border-radius:50% 50% 50% 0;
  transform:rotate(-45deg); border:3px solid #fff;
  box-shadow:0 2px 8px rgba(0,0,0,0.35);
}
#crosshair .pin-dot {
  position:absolute; top:50%; left:50%;
  transform:translate(-50%,-50%);
  width:10px; height:10px;
  background:#fff; border-radius:50%;
}
#crosshair .pin-shadow {
  width:12px; height:6px;
  background:rgba(0,0,0,0.2);
  border-radius:50%; margin-top:3px;
  filter:blur(2px);
}
#address-bar {
  position:fixed; bottom:0; left:0; right:0;
  background:#fff; padding:14px 16px;
  border-top:1px solid #eee;
  font-family:sans-serif; z-index:9999;
}
#addr-text {
  font-size:13px; color:#333;
  margin-bottom:10px; min-height:18px;
  line-height:1.4;
}
#loading-text {
  font-size:12px; color:#999;
  margin-bottom:10px;
}
</style>
</head>
<body>
<div id="map"></div>
<div id="crosshair">
  <div class="pin"><div class="pin-dot"></div></div>
  <div class="pin-shadow"></div>
</div>
<div id="address-bar">
  <div id="loading-text">Move map to pin your location...</div>
  <div id="addr-text"></div>
</div>
<script>
var map = L.map('map', { zoomControl:true, attributionControl:false }).setView([$lat, $lng], 16);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom:19 }).addTo(map);
var debounce;
function onMapMove() {
  clearTimeout(debounce);
  debounce = setTimeout(fetchAddress, 600);
}

function fetchAddress() {
  var c = map.getCenter();
  var url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=' + c.lat + '&lon=' + c.lng + '&zoom=18&addressdetails=1';
  fetch(url, { headers: { 'Accept-Language': 'en' } })
    .then(function(r){ return r.json(); })
    .then(function(d) {
      var addr = d.display_name || (c.lat.toFixed(6) + ', ' + c.lng.toFixed(6));
      document.getElementById('addr-text').textContent = addr;
      document.getElementById('loading-text').textContent = 'Drag map to adjust pin';
      AddressChannel.postMessage(addr + '||' + c.lat + '||' + c.lng);
    })
    .catch(function() {
      var fallback = c.lat.toFixed(6) + ', ' + c.lng.toFixed(6);
      document.getElementById('addr-text').textContent = fallback;
      AddressChannel.postMessage(fallback + '||' + c.lat + '||' + c.lng);
    });
}

map.on('moveend', onMapMove);
fetchAddress();
</script>
</body>
</html>
''';

  Widget _buildWebMap() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(_lat, _lng),
            initialZoom: 16,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
              maxZoom: 19,
            ),
          ],
        ),
        Positioned(
          top: 50,
          left: 50,
          right: 50,
          bottom: 110,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 40,
                  decoration: BoxDecoration(
                    color: KioskTheme.lunaBrown,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 12,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 90,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
              boxShadow: KioskTheme.shadowMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: KioskTheme.lunaBrown, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'PINNED ADDRESS',
                      style: KioskTheme.labelSmall.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _address.isEmpty ? 'Move the map to find your location...' : _address,
                  style: KioskTheme.bodyMedium.copyWith(
                    fontSize: 13,
                    color: _address.isEmpty ? KioskTheme.textMuted : KioskTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_loading)
          Container(
            color: Colors.white.withOpacity(0.85),
            child: const Center(
              child: CircularProgressIndicator(color: KioskTheme.lunaBrown),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmLocation() async {
    if (kIsWeb) {
      setState(() => _loading = true);
      final center = _mapController.camera.center;
      setState(() {
        _lat = center.latitude;
        _lng = center.longitude;
      });
      await _fetchAddress(_lat, _lng);
      setState(() => _loading = false);
      if (mounted) {
        Navigator.pop(context, {'address': _address, 'lat': _lat, 'lng': _lng});
      }
    } else {
      Navigator.pop(context, {'address': _address, 'lat': _lat, 'lng': _lng});
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KioskTheme.lunaCream,
      appBar: AppBar(
        title: Text(
          'PIN YOUR LOCATION',
          style: KioskTheme.headerSmall.copyWith(color: KioskTheme.textOnPrimary, letterSpacing: 1, fontSize: 18),
        ),
        backgroundColor: KioskTheme.lunaBrown,
        foregroundColor: KioskTheme.textOnPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _address.isEmpty ? null : _confirmLocation,
            child: Text(
              'CONFIRM',
              style: KioskTheme.labelLarge.copyWith(color: KioskTheme.textOnPrimary, fontSize: 14),
            ),
          ),
        ],
      ),
      body: kIsWeb
          ? _buildWebMap()
          : Stack(
              children: [
                WebViewWidget(controller: _webCtrl!),
                if (_loading)
                  Container(
                    color: KioskTheme.lunaWhite.withOpacity(0.85),
                    child: const Center(child: CircularProgressIndicator(color: KioskTheme.lunaBrown)),
                  ),
                Positioned(
                  bottom: 90,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: KioskTheme.lunaWhite,
                      borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
                      boxShadow: KioskTheme.shadowMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: KioskTheme.lunaBrown, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'PINNED ADDRESS',
                              style: KioskTheme.labelSmall.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _address.isEmpty ? 'Move the map to find your location...' : _address,
                          style: KioskTheme.bodyMedium.copyWith(
                            fontSize: 13,
                            color: _address.isEmpty ? KioskTheme.textMuted : KioskTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
