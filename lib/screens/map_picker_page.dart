import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/kiosk/kiosk_theme.dart';

const _maptilerKey = 'WdrFoTJ8mK1mg0cZdDoM';
const _tileUrl =
    'https://api.maptiler.com/maps/streets-v2/256/{z}/{x}/{y}.png?key=$_maptilerKey';
const _nominatimSearch =
    'https://nominatim.openstreetmap.org/search?format=json&addressdetails=1&limit=5';
const _nominatimReverse =
    'https://nominatim.openstreetmap.org/reverse?format=json&zoom=18&addressdetails=1';

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

class _MapPickerPageState extends State<MapPickerPage>
    with TickerProviderStateMixin {
  WebViewController? _webCtrl;
  late MapController _mapController;
  String _address = '';
  String _addressShort = '';
  bool _loading = true;
  double _lat = 0, _lng = 0;

  late AnimationController _pulseCtrl;

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;
  Timer? _searchDebounce;
  Timer? _addressDebounce;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _address = widget.initialAddress;
    _addressShort = widget.initialAddress;
    _lat = widget.initialLat;
    _lng = widget.initialLng;
    _mapController = MapController();

    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat(reverse: true);

    _getCurrentLocationAndInit();
  }

  // ─── Location ──────────────────────────────────────────────────

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

  Future<void> _goToMyLocation() async {
    if (kIsWeb) {
      try {
        final completer = Completer<Map<String, double>>();
        js.context['_myLocSuccess'] = (pos) {
          final c = pos['coords'];
          completer.complete({'lat': c['latitude'], 'lng': c['longitude']});
        };
        js.context['_myLocError'] = (_) => completer.completeError('error');
        js.context.callMethod('eval', ['''
          navigator.geolocation.getCurrentPosition(
            function(p) { window._myLocSuccess(p); },
            function(e) { window._myLocError(e); },
            { enableHighAccuracy: true, timeout: 8000, maximumAge: 0 }
          );
        ''']);
        final pos = await completer.complete();
        _mapController.move(LatLng(pos['lat']!, pos['lng']!), 17);
        _fetchAddress(pos['lat']!, pos['lng']!);
      } catch (_) {}
    } else {
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 8), onTimeout: () => throw Exception());
        if (_webCtrl != null) {
          _webCtrl!.runJavaScript('moveMapTo(${pos.latitude}, ${pos.longitude});');
        }
      } catch (_) {}
    }
  }

  void _initMapWithLocation(double lat, double lng) {
    if (!kIsWeb) {
      _webCtrl = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel('AddressChannel', onMessageReceived: (msg) {
          final parts = msg.message.split('||');
          if (parts.length >= 4) {
            setState(() {
              _address = parts[0];
              _addressShort = parts[1];
              _lat = double.tryParse(parts[2]) ?? _lat;
              _lng = double.tryParse(parts[3]) ?? _lng;
              _loading = false;
            });
          }
        })
        ..loadHtmlString(_buildMapHtml(lat, lng));
    } else {
      setState(() => _loading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(LatLng(lat, lng), 17);
        _fetchAddress(lat, lng);
      });
    }
  }

  // ─── Address ───────────────────────────────────────────────────

  Future<void> _fetchAddress(double lat, double lng) async {
    final url = '$_nominatimReverse&lat=$lat&lon=$lng';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept-Language': 'en'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final displayName =
            data['display_name'] as String? ?? '$lat, $lng';
        final address = data['address'] as Map<String, dynamic>?;
        final short = _parseAddressObject(address);
        setState(() {
          _address = displayName;
          _addressShort = short;
        });
      }
    } catch (e) {
      setState(() {
        _addressShort = '';
      });
    }
  }

  String _parseAddressObject(Map<String, dynamic>? address) {
    if (address == null) return '';
    final parts = <String>[];
    if (address['road'] != null) parts.add(address['road'] as String);
    if (address['suburb'] != null) parts.add(address['suburb'] as String);
    final city =
        address['city'] ?? address['town'] ?? address['village'];
    if (city != null) parts.add(city as String);
    if (address['state'] != null && parts.length < 2) {
      parts.add(address['state'] as String);
    }
    return parts.join(', ');
  }

  // ─── Search ────────────────────────────────────────────────────

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _showResults = false;
        _searchResults.clear();
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _searchAddress(query.trim());
    });
  }

  Future<void> _searchAddress(String query) async {
    final url = '$_nominatimSearch&q=${Uri.encodeComponent(query)}';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept-Language': 'en'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _searchResults =
              data.map((e) => e as Map<String, dynamic>).toList();
          _showResults = _searchResults.isNotEmpty;
          _searching = false;
        });
      } else {
        setState(() => _searching = false);
      }
    } catch (e) {
      setState(() => _searching = false);
    }
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final lat = double.tryParse(result['lat'].toString()) ?? _lat;
    final lng = double.tryParse(result['lon'].toString()) ?? _lng;
    final displayName = result['display_name'] as String? ?? '';
    final address = result['address'] as Map<String, dynamic>?;
    final short = _parseAddressObject(address);

    setState(() {
      _lat = lat;
      _lng = lng;
      _address = displayName;
      _addressShort = short;
      _showResults = false;
      _searchCtrl.clear();
      _searchFocus.unfocus();
    });

    if (kIsWeb) {
      _mapController.move(LatLng(lat, lng), 17);
    } else if (_webCtrl != null) {
      _webCtrl!.runJavaScript('moveMapTo($lat, $lng);');
    }
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _searchDebounce?.cancel();
    setState(() {
      _showResults = false;
      _searchResults.clear();
      _searching = false;
    });
  }

  // ─── Native Map HTML ───────────────────────────────────────────

  String _buildMapHtml(double lat, double lng) => '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<style>
* { margin:0; padding:0; box-sizing:border-box; }
html, body { height:100%; width:100%; overflow:hidden; }
#map { height:100%; width:100%; }
#crosshair {
  position:fixed; top:50%; left:50%;
  transform:translate(-50%,-100%);
  z-index:9999; pointer-events:none;
  display:flex; flex-direction:column; align-items:center;
}
@keyframes pinPulse {
  0%,100% { transform: scale(1); }
  50% { transform: scale(1.06); }
}
.pin-container {
  animation: pinPulse 1.6s ease-in-out infinite;
}
.pin-body {
  width:36px; height:44px;
  background:#4A3728; border-radius:50% 50% 50% 0;
  transform:rotate(-45deg); border:3px solid #fff;
  box-shadow:0 3px 10px rgba(0,0,0,0.35);
  position:relative;
}
.pin-dot {
  position:absolute; top:50%; left:50%;
  transform:translate(-50%,-50%);
  width:12px; height:12px;
  background:#fff; border-radius:50%;
  box-shadow:inset 0 1px 2px rgba(0,0,0,0.15);
}
.pin-shadow {
  width:14px; height:7px;
  background:rgba(0,0,0,0.18);
  border-radius:50%; margin-top:2px;
  filter:blur(3px);
}
</style>
</head>
<body>
<div id="map"></div>
<div id="crosshair">
  <div class="pin-container">
    <div class="pin-body"><div class="pin-dot"></div></div>
    <div class="pin-shadow"></div>
  </div>
</div>
<script>
var map = L.map('map', { zoomControl:true, attributionControl:false }).setView([$lat, $lng], 17);
L.tileLayer('$_tileUrl', { maxZoom:19 }).addTo(map);

var debounce;
function fetchAddressAt(lat, lng) {
  clearTimeout(debounce);
  debounce = setTimeout(function() {
    var url = '$_nominatimReverse&lat=' + lat + '&lon=' + lng;
    fetch(url, { headers: { 'Accept-Language': 'en' } })
      .then(function(r){ return r.json(); })
      .then(function(d) {
        var display = d.display_name || (lat.toFixed(6) + ', ' + lng.toFixed(6));
        var short = display;
        var a = d.address || {};
        var parts = [];
        if (a.road) parts.push(a.road);
        if (a.suburb) parts.push(a.suburb);
        var city = a.city || a.town || a.village;
        if (city) parts.push(city);
        if (a.state && parts.length < 2) parts.push(a.state);
        if (parts.length > 0) short = parts.join(', ');
        AddressChannel.postMessage(display + '||' + short + '||' + lat + '||' + lng);
      })
      .catch(function() {
        var fb = lat.toFixed(6) + ', ' + lng.toFixed(6);
        AddressChannel.postMessage(fb + '||' + fb + '||' + lat + '||' + lng);
      });
  }, 600);
}

map.on('moveend', function() {
  var c = map.getCenter();
  fetchAddressAt(c.lat, c.lng);
});

function moveMapTo(lat, lng) {
  map.setView([lat, lng], 17);
}

fetchAddressAt($lat, $lng);
</script>
</body>
</html>
''';

  // ─── Confirm ───────────────────────────────────────────────────

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
        Navigator.pop(context, {
          'address': _address,
          'lat': _lat,
          'lng': _lng,
        });
      }
    } else {
      Navigator.pop(context, {
        'address': _address,
        'lat': _lat,
        'lng': _lng,
      });
    }
  }

  // ─── Build ─────────────────────────────────────────────────────

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _searchDebounce?.cancel();
    _addressDebounce?.cancel();
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
          style: KioskTheme.headerSmall.copyWith(
            color: KioskTheme.textOnPrimary,
            letterSpacing: 1,
            fontSize: 18,
          ),
        ),
        backgroundColor: KioskTheme.lunaBrown,
        foregroundColor: KioskTheme.textOnPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _address.isEmpty ? null : _confirmLocation,
            child: Text(
              'CONFIRM',
              style: KioskTheme.labelLarge.copyWith(
                color: KioskTheme.textOnPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showResults && _searchResults.isNotEmpty)
            _buildSearchResults(),
          Expanded(child: _buildMapContent()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: KioskTheme.lunaWhite,
        boxShadow: [
          BoxShadow(
            color: KioskTheme.lunaBrown.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        focusNode: _searchFocus,
        onChanged: _onSearchChanged,
        onTap: () {
          if (_searchResults.isNotEmpty) {
            setState(() => _showResults = true);
          }
        },
        decoration: InputDecoration(
          hintText: 'Search address...',
          hintStyle: KioskTheme.bodyMedium.copyWith(
            color: KioskTheme.textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: KioskTheme.lunaBrown,
            size: 20,
          ),
          suffixIcon: _searching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: KioskTheme.lunaBrown,
                    ),
                  ),
                )
              : _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      color: KioskTheme.textMuted,
                      onPressed: _clearSearch,
                    )
                  : null,
          filled: true,
          fillColor: KioskTheme.lunaCream,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
            borderSide: BorderSide(
              color: KioskTheme.lunaBrown.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        style: KioskTheme.bodyMedium,
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: KioskTheme.lunaWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _searchResults.length,
        separatorBuilder: (_, __) =>
            KioskTheme.divider(opacity: 0.05),
        itemBuilder: (context, index) {
          final r = _searchResults[index];
          final name = r['display_name'] as String? ?? '';
          return ListTile(
            dense: true,
            leading: const Icon(
              Icons.location_on,
              color: KioskTheme.lunaBrown,
              size: 20,
            ),
            title: Text(
              name,
              style: KioskTheme.bodyMedium.copyWith(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _selectSearchResult(r),
          );
        },
      ),
    );
  }

  Widget _buildMapContent() {
    if (kIsWeb) return _buildWebMap();
    return _buildNativeMap();
  }

  Widget _buildWebMap() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(_lat, _lng),
            initialZoom: 17,
            onMapEvent: (e) {
              if (e is MapEventMoveEnd) {
                final c = _mapController.camera.center;
                setState(() {
                  _lat = c.latitude;
                  _lng = c.longitude;
                });
                _addressDebounce?.cancel();
                _addressDebounce = Timer(
                  const Duration(milliseconds: 600),
                  () => _fetchAddress(c.latitude, c.longitude),
                );
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _tileUrl,
              userAgentPackageName: 'com.example.app',
              maxZoom: 19,
            ),
          ],
        ),
        _buildPinOverlay(),
        _buildMyLocationButton(),
        _buildAddressCard(),
        if (_loading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildNativeMap() {
    return Stack(
      children: [
        if (_webCtrl != null) WebViewWidget(controller: _webCtrl!),
        _buildMyLocationButton(),
        _buildAddressCard(),
        if (_loading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildPinOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 120,
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.94 + (_pulseCtrl.value * 0.06),
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 44,
                  decoration: BoxDecoration(
                    color: KioskTheme.lunaBrown,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: KioskTheme.lunaWhite,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 14,
                  height: 7,
                  decoration: BoxDecoration(
                    color: KioskTheme.lunaBrown.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyLocationButton() {
    return Positioned(
      right: 16,
      bottom: 110,
      child: Material(
        color: KioskTheme.lunaWhite,
        borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(KioskTheme.radiusFull),
          onTap: _goToMyLocation,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: KioskTheme.lunaBrown.withOpacity(0.1),
              ),
            ),
            child: const Icon(
              Icons.my_location,
              color: KioskTheme.lunaBrown,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    final hasAddress = _addressShort.isNotEmpty;
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: KioskTheme.lunaWhite,
          borderRadius:
              BorderRadius.circular(KioskTheme.radiusLg),
          boxShadow: KioskTheme.shadowLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on,
                    color: KioskTheme.lunaBrown, size: 18),
                const SizedBox(width: 6),
                Text(
                  'PINNED LOCATION',
                  style: KioskTheme.labelSmall
                      .copyWith(fontSize: 11),
                ),
                const Spacer(),
                if (hasAddress)
                  const Icon(Icons.check_circle,
                      color: KioskTheme.success, size: 18),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              hasAddress
                  ? _addressShort
                  : 'Move the map to pin your location',
              style: KioskTheme.bodyMedium.copyWith(
                fontSize: 14,
                color: hasAddress
                    ? KioskTheme.textPrimary
                    : KioskTheme.textMuted,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: KioskTheme.lunaWhite.withOpacity(0.85),
      child: const Center(
        child: CircularProgressIndicator(
          color: KioskTheme.lunaBrown,
        ),
      ),
    );
  }
}
