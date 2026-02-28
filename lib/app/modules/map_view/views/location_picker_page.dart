import 'dart:convert';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Kullanıcının harita üzerinde bir noktaya dokunarak konum seçmesini sağlar.
class LocationPickerPage extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerPage({super.key, this.initialLocation});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  // OpenStreetMap — global kapsam
  String _osmTileUrl = 'https://jaytap.com.tm/styles/test-style/{z}/{x}/{y}.png';

  // Türkmenistan / Aşgabat merkezi (varsayılan)
  static const LatLng _defaultCenter = LatLng(37.9601, 58.3261);

  late final MapController _mapController;
  LatLng? _selectedLocation;
  bool _isLoadingLocation = false;

  String? _addressText;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation;
    if (widget.initialLocation != null) {
      _fetchAddress(widget.initialLocation!);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Nominatim (OpenStreetMap) API ile reverse geocoding — Google gerektirmez
  Future<void> _fetchAddress(LatLng loc) async {
    setState(() {
      _isLoadingAddress = true;
      _addressText = null;
    });
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${loc.latitude}&lon=${loc.longitude}&format=json&accept-language=tk',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'AtelyamApp/1.0',
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final displayName = data['display_name'] as String?;
        print('📍 Nominatim adres: $displayName');
        if (displayName != null && displayName.isNotEmpty) {
          setState(() => _addressText = displayName);
        }
      } else {
        print('📍 Nominatim hata: ${response.statusCode}');
      }
    } catch (e) {
      print('📍 Geocoding HATA: $e');
      setState(() => _addressText = null);
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  Future<void> _goToMyLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage('location_service_disabled'.tr);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showMessage('location_permission_denied'.tr);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final loc = LatLng(position.latitude, position.longitude);
      setState(() => _selectedLocation = loc);
      _mapController.move(loc, 15.0);
      await _fetchAddress(loc);
    } catch (_) {
      _showMessage('location_error'.tr);
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.kSecondaryColor,
        title: Text(
          'select_location'.tr,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(IconlyLight.arrow_left_circle, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialLocation ?? _defaultCenter,
              initialZoom: widget.initialLocation != null ? 14.0 : 10.0,
              onTap: (tapPosition, latLng) {
                setState(() {
                  _selectedLocation = latLng;
                  _addressText = null;
                });
                _fetchAddress(latLng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _osmTileUrl,
                maxZoom: 19,
                userAgentPackageName: 'com.atelyam.app',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Bilgi kutusu — adres gösterimi
          Positioned(
            top: 12,
            left: 16,
            right: 72,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _selectedLocation == null
                  ? Text(
                      'tap_map_to_select'.tr,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    )
                  : _isLoadingAddress
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('...', style: TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        )
                      : Text(
                          _addressText != null ? '📍 $_addressText' : '📍 ${_selectedLocation!.latitude.toStringAsFixed(5)}, ${_selectedLocation!.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
            ),
          ),

          // Konumum butonu
          Positioned(
            bottom: 50,
            right: 16,
            child: FloatingActionButton(
              elevation: 0.0,
              backgroundColor: ColorConstants.kSecondaryColor,
              onPressed: _isLoadingLocation ? null : _goToMyLocation,
              child: _isLoadingLocation
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // Kaydet butonu
          if (_selectedLocation != null)
            Positioned(
              bottom: 50,
              left: 16,
              right: 80,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.kSecondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Get.back(result: {
                  'location': _selectedLocation,
                  'address': _addressText,
                }),
                icon: const Icon(Icons.check, color: Colors.white),
                label: Text(
                  'save_location'.tr,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
