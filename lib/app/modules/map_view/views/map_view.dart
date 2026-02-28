import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/modules/home_view/components/business_users/business_user_profile_view.dart';
import 'package:atelyam/app/modules/map_view/controllers/map_view_controller.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:latlong2/latlong.dart';

// ---------- Cluster yardımcı model ----------
class _ClusterGroup {
  final LatLng center;
  final List<BusinessUserModel> businesses;
  _ClusterGroup(this.center, this.businesses);
}

// ---------- Clustering hesaplama ----------
List<_ClusterGroup> _buildClusters(
  List<BusinessUserModel> businesses,
  double zoom,
) {
  // Zoom arttıkça ızgara hücresi küçülür → daha hassas gruplar
  final double gridSize = 180.0 / math.pow(2, zoom.clamp(1, 18).toInt());

  final Map<String, List<BusinessUserModel>> cells = {};

  for (final b in businesses) {
    final int latCell = (b.lat! / gridSize).floor();
    final int lonCell = (b.long! / gridSize).floor();
    final String key = '$latCell:$lonCell';
    cells.putIfAbsent(key, () => []).add(b);
  }

  return cells.entries.map((e) {
    final list = e.value;
    final avgLat = list.map((b) => b.lat!).reduce((a, b) => a + b) / list.length;
    final avgLon = list.map((b) => b.long!).reduce((a, b) => a + b) / list.length;
    return _ClusterGroup(LatLng(avgLat, avgLon), list);
  }).toList();
}

// ============================================================
class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  static const String _tmTileUrl = 'https://jaytap.com.tm/styles/test-style/{z}/{x}/{y}.png';
  static const String _osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String _ayterekMap = 'https://map.ayterek.com/tile/{z}/{x}/{y}.png';

  late final MapViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(MapViewController());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: ColorConstants.kSecondaryColor,
          ),
        );
      }

      return Stack(
        children: [
          FlutterMap(
            mapController: _controller.mapController,
            options: MapOptions(
              initialCenter: _controller.businessUsers.isNotEmpty
                  ? LatLng(
                      _controller.businessUsers.first.lat!,
                      _controller.businessUsers.first.long!,
                    )
                  : _controller.defaultCenter,
              initialZoom: _controller.currentZoom.value,
              onMapReady: _controller.onMapReady,
              onPositionChanged: (camera, _) {
                _controller.onZoomChanged(camera.zoom);
              },
            ),
            children: [
              // Tile katmanı
              Obx(() {
                final tileUrl = _controller.isInTurkmenistan.value ? _ayterekMap : _osmTileUrl;
                return TileLayer(
                  urlTemplate: tileUrl,
                  maxZoom: 19,
                  minZoom: 3,
                  keepBuffer: 8,
                  panBuffer: 2,
                  userAgentPackageName: 'com.atelyam.app',
                );
              }),

              // Business marker'ları (cluster veya bireysel)
              Obx(() {
                final zoom = _controller.currentZoom.value;
                final businesses = _controller.businessUsers;
                final markers = <Marker>[];

                if (zoom < MapViewController.clusterZoomThreshold) {
                  // ────── CLUSTER MODU ──────
                  final clusters = _buildClusters(businesses, zoom);
                  for (final cluster in clusters) {
                    if (cluster.businesses.length == 1) {
                      // Tek business → bireysel marker göster
                      final business = cluster.businesses.first;
                      markers.add(
                        Marker(
                          width: 56,
                          height: 70,
                          point: LatLng(business.lat!, business.long!),
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            onTap: () => _navigateToProfile(business),
                            child: _BusinessMarker(business: business),
                          ),
                        ),
                      );
                    } else {
                      // 2+ business → cluster balonu
                      markers.add(_buildClusterMarker(cluster, zoom));
                    }
                  }
                } else {
                  // ────── BİREYSEL MARKER MODU ──────
                  for (final business in businesses) {
                    markers.add(
                      Marker(
                        width: 56,
                        height: 70,
                        point: LatLng(business.lat!, business.long!),
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () => _navigateToProfile(business),
                          child: _BusinessMarker(business: business),
                        ),
                      ),
                    );
                  }
                }

                return MarkerLayer(markers: markers);
              }),

              // Kullanıcı konum marker'ı
              Obx(() {
                final loc = _controller.userLocation.value;
                if (loc == null) return const SizedBox.shrink();
                return MarkerLayer(
                  markers: [
                    Marker(
                      point: loc,
                      width: 35,
                      height: 35,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorConstants.kSecondaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: ColorConstants.kSecondaryColor.withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          IconlyBold.location,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),

          // Sonuç sayısı
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconlyBold.location,
                    color: ColorConstants.kSecondaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Obx(
                    () => Text(
                      '${_controller.businessUsers.length} ${'terzi'.tr}',
                      style: TextStyle(
                        color: ColorConstants.kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sağ alt aksiyon butonları
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              children: [
                Obx(() => _MapFab(
                      icon: Icons.my_location_rounded,
                      onTap: _controller.goToUserLocation,
                      color: ColorConstants.kSecondaryColor,
                      isLoading: _controller.isLocating.value,
                    )),
                const SizedBox(height: 10),
                _MapFab(
                  icon: Icons.add,
                  onTap: () {
                    final newZoom = (_controller.currentZoom.value + 1).clamp(4.0, 18.0);
                    _controller.currentZoom.value = newZoom;
                    _controller.mapController.move(
                      _controller.mapController.camera.center,
                      newZoom,
                    );
                  },
                ),
                const SizedBox(height: 8),
                _MapFab(
                  icon: Icons.remove,
                  onTap: () {
                    final newZoom = (_controller.currentZoom.value - 1).clamp(4.0, 18.0);
                    _controller.currentZoom.value = newZoom;
                    _controller.mapController.move(
                      _controller.mapController.camera.center,
                      newZoom,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  // ──────────────────────────────────────────
  /// Cluster marker: büyük daire + "N işletme" yazısı
  Marker _buildClusterMarker(_ClusterGroup cluster, double zoom) {
    final count = cluster.businesses.length;

    // Cluster boyutu: içindeki eleman sayısına göre biraz büyür
    final double size = count == 1 ? 30 : (30 + math.min(count * 2.0, 20));

    return Marker(
      width: size,
      height: size,
      point: cluster.center,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          // Tıklayınca yakınlaştır → individual marker'ları göster
          final newZoom = (zoom + 2).clamp(4.0, 18.0);
          _controller.mapController.move(cluster.center, newZoom);
          _controller.currentZoom.value = newZoom;
        },
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ColorConstants.kSecondaryColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: ColorConstants.kSecondaryColor.withOpacity(0.45),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToProfile(BusinessUserModel business) {
    Get.to(
      () => BusinessUserProfileView(
        businessUserModelFromOutside: business,
        categoryID: business.title,
        whichPage: 'map',
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
/// Haritada her terzi için gösterilen daire marker (bireysel mod)
class _BusinessMarker extends StatelessWidget {
  const _BusinessMarker({required this.business});
  final BusinessUserModel business;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorConstants.kSecondaryColor,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: ColorConstants.kSecondaryColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: business.backPhoto.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: '${authController.ipAddress.value}${business.backPhoto}',
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _defaultIcon(),
                    placeholder: (_, __) => _defaultIcon(),
                  )
                : _defaultIcon(),
          ),
        ),
        // Aşağıya bakan ok
        CustomPaint(
          size: const Size(14, 8),
          painter: _MarkerArrow(),
        ),
      ],
    );
  }

  Widget _defaultIcon() {
    return Container(
      color: ColorConstants.kSecondaryColor,
      child: const Icon(
        IconlyBold.profile,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

/// Marker'ın alt kısmındaki ok boyacısı
class _MarkerArrow extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ColorConstants.kSecondaryColor
      ..style = PaintingStyle.fill;

    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Sağ alt köşedeki yuvarlak aksiyon butonu
class _MapFab extends StatelessWidget {
  const _MapFab({
    required this.icon,
    required this.onTap,
    this.color,
    this.isLoading = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color ?? ColorConstants.kSecondaryColor,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    color: color ?? ColorConstants.kPrimaryColor,
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }
}
