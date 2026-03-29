import 'dart:convert';

import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:iconly/iconly.dart';
import 'package:latlong2/latlong.dart';

class MapViewController extends GetxController {
  static const String ayterekTileUrl = 'https://map.ayterek.com/tile/{z}/{x}/{y}.png';
  static const String tmTileUrl = 'https://jaytap.com.tm/styles/test-style/{z}/{x}/{y}.png';
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // Test tile for Ashgabat area at zoom 8
  static const String _ayterekTestTile = 'https://map.ayterek.com/tile/8/169/100.png';
  static const String _tmTestTile = 'https://jaytap.com.tm/styles/test-style/8/169/100.png';

  /// Probes ayterek → jaytap.com.tm → OSM and returns the first working URL.
  /// If [isInTurkmenistan] is false, returns OSM directly.
  static Future<String> resolveTileUrl({required bool isInTurkmenistan}) async {
    if (!isInTurkmenistan) return osmTileUrl;
    try {
      final r = await http.head(Uri.parse(_ayterekTestTile)).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return ayterekTileUrl;
    } catch (_) {}
    try {
      final r = await http.head(Uri.parse(_tmTestTile)).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return tmTileUrl;
    } catch (_) {}
    return osmTileUrl;
  }

  final mapController = MapController();

  final RxList<BusinessUserModel> businessUsers = <BusinessUserModel>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  final RxDouble currentZoom = 12.0.obs;
  bool isMapReady = false;
  final RxBool isLocating = false.obs;
  final RxString resolvedTileUrl = osmTileUrl.obs;

  /// Bu zoom değerinin altında cluster (sayı balonu), üstünde bireysel marker gösterilir
  static const double clusterZoomThreshold = 12.0;

  void onZoomChanged(double zoom) {
    currentZoom.value = zoom;
  }

  // Türkmenistan bounding box: lat 35.1–42.8, lon 52.4–66.7
  // Başlangıçta varsayılan merkez Türkmenistan olduğu için true
  final RxBool isInTurkmenistan = true.obs;

  static bool _checkTurkmenistan(double lat, double lon) {
    return lat >= 35.1 && lat <= 42.8 && lon >= 52.4 && lon <= 66.7;
  }

  // Türkmenistan / Aşgabat merkezi (varsayılan)
  final LatLng defaultCenter = const LatLng(37.9601, 58.3261);

  @override
  void onInit() {
    super.onInit();
    fetchAllBusinessLocations();
    _initTileUrl();
  }

  Future<void> checkAndPromptLocation() async {
    // 1. Önce izin durumunu kontrol et
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      _showEnableLocationDialog();
      return;
    }

    if (permission == LocationPermission.denied) {
      // Native OS izin popup'ını göster
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return; // Kullanıcı reddetti, bir şey yapma
      }
    }

    // 2. İzin verildi, ama GPS servisi kapalıysa dialog göster → kullanıcı karar versin
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showEnableLocationDialog();
    }
  }

  void _showEnableLocationDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: ColorConstants.kSecondaryColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  IconlyBold.location,
                  color: ColorConstants.kSecondaryColor,
                  size: 34,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'enable_location_title'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.kPrimaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'enable_location_message'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              // Open Settings button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Get.back();
                    await Geolocator.openLocationSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.kSecondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'open_settings'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    'cancel'.tr,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _initTileUrl() async {
    resolvedTileUrl.value = await resolveTileUrl(isInTurkmenistan: isInTurkmenistan.value);
    print('🗺️ Tile URL seçildi: ${resolvedTileUrl.value}');
  }

  Future<void> fetchAllBusinessLocations() async {
    isLoading.value = true;
    businessUsers.clear();

    try {
      final authController = Get.find<AuthController>();
      final url = Uri.parse('${authController.ipAddress.value}/mobile/allmap/');
      print('🗺️ MapView: allmap çekiliyor → $url');

      final response = await http.get(url);
      if (response.statusCode != 200) {
        print('🗺️ MapView: allmap hata kodu ${response.statusCode}');
        return;
      }

      final List<dynamic> decoded = jsonDecode(utf8.decode(response.bodyBytes));

      final List<BusinessUserModel> all = [];
      for (final item in decoded) {
        final map = item as Map<String, dynamic>;
        final latRaw = map['lat'];
        final lonRaw = map['long'];
        if (latRaw == null || lonRaw == null) continue;

        final lat = latRaw is num ? latRaw.toDouble() : double.tryParse(latRaw.toString());
        final lon = lonRaw is num ? lonRaw.toDouble() : double.tryParse(lonRaw.toString());
        if (lat == null || lon == null) continue;

        final userId = map['user'] as int? ?? 0;
        all.add(BusinessUserModel(
          id: userId,
          userID: userId,
          user: userId,
          businessName: map['businessName'] as String? ?? '',
          businessPhone: '',
          backPhoto: map['back_photo'] as String? ?? '',
          description: '',
          title: 0,
          lat: lat,
          long: lon,
        ));
      }

      // Tekrar edenleri user id'ye göre filtrele
      final seen = <int>{};
      final unique = all.where((b) => seen.add(b.id)).toList();

      businessUsers.assignAll(unique);
      print('🗺️ MapView: ${unique.length} adet konumlu işletme yüklendi.');
    } catch (e, stackTrace) {
      print('🗺️ MapView fetchAllBusinessLocations hatası: $e');
      print(stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> goToUserLocation() async {
    final bool hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    isLocating.value = true;
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final LatLng loc = LatLng(position.latitude, position.longitude);
      userLocation.value = loc;
      isInTurkmenistan.value = _checkTurkmenistan(position.latitude, position.longitude);
      resolvedTileUrl.value = await resolveTileUrl(isInTurkmenistan: isInTurkmenistan.value);
      if (isMapReady) {
        mapController.move(loc, 14.0);
      }
    } catch (e) {
      // Konum alınamadı
    } finally {
      isLocating.value = false;
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  void onMapReady() {
    isMapReady = true;
  }
}
