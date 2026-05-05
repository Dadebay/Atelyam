import 'dart:ui' as ui;

import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:iconly/iconly.dart';
import 'package:latlong2/latlong.dart';

/// Tek bir işletmenin konumunu haritada gösteren sayfa.
/// Türkmenistan'da ayterek tile kullanılır, diğer ülkelerde OSM.
class BusinessLocationMapPage extends StatefulWidget {
  final BusinessUserModel business;

  const BusinessLocationMapPage({required this.business, super.key});

  @override
  State<BusinessLocationMapPage> createState() => _BusinessLocationMapPageState();
}

class _BusinessLocationMapPageState extends State<BusinessLocationMapPage> {
  static const String _tmTileUrl = 'https://jaytap.com.tm/styles/test-style/{z}/{x}/{y}.png';
  static const String _osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  final MapController _mapController = MapController();
  final AuthController _authController = Get.find<AuthController>();

  late final LatLng _point;
  bool _isTurkmenistan = false;
  String _resolvedTileUrl = _osmTileUrl;

  Future<void> _probeTileUrl() async {
    if (!_isTurkmenistan) return; // already defaults to OSM
    try {
      final r = await http.head(Uri.parse('https://jaytap.com.tm/styles/test-style/8/169/100.png')).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) {
        if (mounted) setState(() => _resolvedTileUrl = _tmTileUrl);
        return;
      }
    } catch (_) {}
    // keep _osmTileUrl
  }

  @override
  void initState() {
    super.initState();
    _point = LatLng(widget.business.lat!, widget.business.long!);
    // Türkmenistan koordinat aralığı: lat 35–43, lon 52–66
    _isTurkmenistan = _point.latitude >= 35 && _point.latitude <= 43 && _point.longitude >= 52 && _point.longitude <= 66;
    _probeTileUrl();
  }

  @override
  Widget build(BuildContext context) {
    final tileUrl = _resolvedTileUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.business.businessName,
          style: TextStyle(
            fontFamily: Fonts.gilroy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ColorConstants.kPrimaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(IconlyLight.arrow_left_circle, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _point,
              initialZoom: 15.5,
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                maxZoom: 19,
                minZoom: 3,
                keepBuffer: 8,
                userAgentPackageName: 'com.atelyam.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 56,
                    height: 70,
                    point: _point,
                    alignment: Alignment.topCenter,
                    child: _BusinessMarker(
                      business: widget.business,
                      authController: _authController,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // İşletme adı ve adres kart
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.business.backPhoto.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _authController.ipAddress.value + widget.business.backPhoto,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _defaultIcon(),
                          )
                        : _defaultIcon(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.business.businessName,
                          style: TextStyle(
                            fontFamily: Fonts.gilroy,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: ColorConstants.kPrimaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.business.address?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.business.address!,
                            style: TextStyle(
                              fontFamily: Fonts.gilroy,
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sağ alt: merkezle butonu
          Positioned(
            right: 16,
            bottom: 110,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
              shadowColor: Colors.black26,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _mapController.move(_point, 15.5),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.my_location_rounded,
                    color: ColorConstants.kSecondaryColor,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultIcon() {
    return Container(
      width: 52,
      height: 52,
      color: ColorConstants.kSecondaryColor,
      child: const Icon(IconlyBold.profile, color: Colors.white, size: 26),
    );
  }
}

// ─────────────────────────────────────────────────────
/// Haritadaki tek marker widget'ı
class _BusinessMarker extends StatelessWidget {
  const _BusinessMarker({required this.business, required this.authController});
  final BusinessUserModel business;
  final AuthController authController;

  @override
  Widget build(BuildContext context) {
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
                color: ColorConstants.kSecondaryColor.withOpacity(0.45),
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
                    errorWidget: (_, __, ___) => const Icon(IconlyBold.profile, color: Colors.white, size: 24),
                    placeholder: (_, __) => Container(color: ColorConstants.kSecondaryColor),
                  )
                : Container(
                    color: ColorConstants.kSecondaryColor,
                    child: const Icon(IconlyBold.profile, color: Colors.white, size: 24),
                  ),
          ),
        ),
        // Aşağı bakan ok
        CustomPaint(size: const Size(14, 8), painter: _MarkerArrow()),
      ],
    );
  }
}

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
