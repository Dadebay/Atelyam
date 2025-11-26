import 'package:atelyam/app/data/models/product_model.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/modules/product_profil_view/views/product_profil_view.dart';
import 'package:atelyam/app/modules/settings_view/components/fav_button.dart';
import 'package:atelyam/app/product/empty_states/empty_states.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

/// Ürün kartı widget'ı - Ana sayfada ve diğer sayfalarda ürünleri gösterir
class DiscoveryCard extends StatelessWidget {
  final ProductModel productModel;
  final bool homePageStyle;
  final bool? showViewCount;
  final bool showFavButton;
  final String? businessUserID;
  final int? index;

  DiscoveryCard({
    required this.productModel,
    required this.homePageStyle,
    this.showViewCount,
    this.businessUserID,
    this.showFavButton = true,
    this.index,
    super.key,
  });

  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    final bool isEvenIndex = (index ?? 1) % 2 == 0;

    // Çift sıradaki öğeler için özel tasarım (ana sayfada)
    if (isEvenIndex && homePageStyle) {
      return _buildAlternativeCard();
    }

    // Normal kart tasarımı
    return _buildStandardCard();
  }

  /// Çift sıradaki kartlar için alternatif tasarım
  Widget _buildAlternativeCard() {
    return GestureDetector(
      onTap: _navigateToProductDetail,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Arka plan resmi
              _buildProductImage(),

              // Beyaz köşe efekti
              Positioned.fill(
                child: CustomPaint(painter: _CurvedWhiteCornerPainter()),
              ),

              // Görüntülenme sayısı (sol üst)
              _buildViewCountBadge(
                top: 10,
                left: 10,
                showIcon: true,
              ),

              // Favori butonu (sağ üst)
              _buildFavoriteButton(top: 10, right: 10),

              // Ürün ismi (sol alt)
              _buildProductName(),

              // Ok ikonu (sağ alt)
              _buildArrowIcon(),
            ],
          ),
        ),
      ),
    );
  }

  /// Standart kart tasarımı
  Widget _buildStandardCard() {
    return GestureDetector(
      onTap: _navigateToProductDetail,
      child: Container(
        margin: homePageStyle ? const EdgeInsets.only(left: 20, top: 10, bottom: 10) : EdgeInsets.zero,
        decoration: BoxDecoration(
          boxShadow: homePageStyle
              ? [
                  BoxShadow(
                    color: ColorConstants.darkMainColor.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 5,
                  ),
                ]
              : [],
          borderRadius: BorderRadii.borderRadius20,
        ),
        child: ClipRRect(
          borderRadius: BorderRadii.borderRadius20,
          child: Stack(
            children: [
              // Arka plan resmi
              _buildProductImage(),

              // Favori butonu (sağ üst)
              _buildFavoriteButton(top: 10, right: 10),

              // Görüntülenme sayısı
              _buildViewCountSection(),

              // Alt bilgi paneli (ana sayfa için)
              if (homePageStyle) _buildBottomInfoPanel(),
            ],
          ),
        ),
      ),
    );
  }

  /// Ürün resmini oluşturur
  Widget _buildProductImage() {
    return Positioned.fill(
      child: CachedNetworkImage(
        imageUrl: authController.ipAddress.value + productModel.img,
        fit: BoxFit.cover,
        placeholder: (context, url) => EmptyStates().loadingData(),
        errorWidget: (context, url, error) => EmptyStates().noMiniCategoryImage(),
      ),
    );
  }

  /// Görüntülenme sayısı rozeti
  Widget _buildViewCountBadge({
    required double top,
    required double left,
    required bool showIcon,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: showIcon ? 10 : 5,
          vertical: showIcon ? 4 : 2,
        ),
        margin: EdgeInsets.only(right: showIcon ? 10 : 10),
        decoration: BoxDecoration(
          color: ColorConstants.whiteMainColor.withOpacity(.8),
          border: Border.all(
            color: ColorConstants.kPrimaryColor.withOpacity(.6),
            width: showIcon ? 0.5 : 0.1,
          ),
          borderRadius: showIcon ? BorderRadii.borderRadius15 : BorderRadii.borderRadius10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  IconlyLight.show,
                  color: ColorConstants.kPrimaryColor,
                  size: AppFontSizes.fontSize14,
                ),
              ),
            Text(
              productModel.viewCount.toString(),
              style: TextStyle(
                color: showIcon ? ColorConstants.kPrimaryColor : Colors.black,
                fontWeight: showIcon ? FontWeight.bold : FontWeight.w500,
                fontSize: showIcon ? AppFontSizes.fontSize12 : AppFontSizes.fontSize10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Görüntülenme sayısı bölümü (standart kart için)
  Widget _buildViewCountSection() {
    if (!showFavButton) {
      return _buildViewCountBadge(
        top: 5,
        left: 5,
        showIcon: false,
      );
    }

    return _buildViewCountBadge(
      top: 10,
      left: 10,
      showIcon: true,
    );
  }

  /// Favori butonu
  Widget _buildFavoriteButton({
    required double top,
    required double right,
  }) {
    if (!showFavButton) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: top,
      right: right,
      child: FavButton(
        productProfilStyle: false,
        product: productModel,
      ),
    );
  }

  /// Ürün ismi (alternatif kart için)
  Widget _buildProductName() {
    return Positioned(
      bottom: 30,
      left: 10,
      child: SizedBox(
        width: 110,
        child: Text(
          productModel.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Ok ikonu (alternatif kart için)
  Widget _buildArrowIcon() {
    return const Positioned(
      bottom: 16,
      right: 16,
      child: Icon(
        Icons.north_east,
        color: Colors.black,
        size: 18,
      ),
    );
  }

  /// Alt bilgi paneli (standart kart için - ana sayfa)
  Widget _buildBottomInfoPanel() {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        padding: const EdgeInsets.only(
          bottom: 12,
          left: 8,
          right: 8,
          top: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.65),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ürün adı
            Text(
              productModel.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ColorConstants.kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: AppFontSizes.fontSize16,
              ),
            ),
            // Ürün açıklaması
            Text(
              productModel.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ColorConstants.kPrimaryColor,
                fontWeight: FontWeight.w400,
                fontSize: AppFontSizes.fontSize14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 3. Minimal ve modern tasarım (Yeni Design)
  Widget _buildMinimalCard() {
    return GestureDetector(
      onTap: _navigateToProductDetail,
      child: Container(
        margin: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: ColorConstants.darkMainColor.withOpacity(0.08),
              spreadRadius: 3,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadii.borderRadius20,
        ),
        child: ClipRRect(
          borderRadius: BorderRadii.borderRadius20,
          child: Stack(
            children: [
              // Arka plan resmi
              _buildProductImage(),

              // Gradient overlay - Yumuşak alt gölgelendirme
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.75),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // Favori butonu (sağ üst)
              _buildFavoriteButton(top: 10, right: 10),

              // Görüntülenme sayısı - Compact & Modern (sol üst)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadii.borderRadius10,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconlyLight.show,
                        color: Colors.white,
                        size: AppFontSizes.fontSize12,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        productModel.viewCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: AppFontSizes.fontSize12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Alt kısım - Modern bilgi paneli
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // Sol taraf - Ürün bilgileri
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Ürün adı
                            Text(
                              productModel.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                height: 1.2,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Ürün açıklaması
                            Text(
                              productModel.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w400,
                                fontSize: AppFontSizes.fontSize14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Sağ taraf - Modern ok butonu
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorConstants.kPrimaryColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: ColorConstants.kPrimaryColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ürün detay sayfasına yönlendirme
  void _navigateToProductDetail() {
    Get.to(
      () => ProductProfilView(productModel: productModel, businessUserID: businessUserID),
    );
  }
}

/// Sağ alt köşede beyaz kavisli bir şekil çizen özel painter
class _CurvedWhiteCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    // Sağ ortadan başla
    path.moveTo(size.width, size.height * 0.55);

    // Kavisli bir çizgi ile sol alta git
    path.quadraticBezierTo(
      size.width * 0.98, // Kontrol noktası X
      size.height * 0.95, // Kontrol noktası Y
      size.width * 0.40, // Bitiş noktası X
      size.height, // Bitiş noktası Y
    );

    // Sağ alt köşeye çizgi çek
    path.lineTo(size.width, size.height);

    // Yolu kapat
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
