import 'dart:convert';

import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapViewController extends GetxController {
  final mapController = MapController();

  final RxList<BusinessUserModel> businessUsers = <BusinessUserModel>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  final RxDouble currentZoom = 12.0.obs;
  bool isMapReady = false;
  final RxBool isLocating = false.obs;

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
