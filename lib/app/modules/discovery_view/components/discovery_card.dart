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
    final bool isEven = (index ?? 1) % 2 == 0;

    if (isEven && homePageStyle == true) {
      return GestureDetector(
        onTap: () {
          Get.to(
            () => ProductProfilView(
              productModel: productModel,
              businessUserID: businessUserID,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white,
              width: 2.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: authController.ipAddress.value + productModel.img,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => EmptyStates().loadingData(),
                    errorWidget: (context, url, error) =>
                        EmptyStates().noMiniCategoryImage(),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CurvedWhiteCornerPainter(),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: ColorConstants.whiteMainColor.withOpacity(.8),
                      border: Border.all(
                        color: ColorConstants.kPrimaryColor.withOpacity(.6),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadii.borderRadius15,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                            color: ColorConstants.kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: AppFontSizes.fontSize12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: showFavButton
                      ? FavButton(
                          productProfilStyle: false,
                          product: productModel,
                        )
                      : const SizedBox.shrink(),
                ),
                Positioned(
                  bottom: 30,
                  left: 10,
                  child: SizedBox(
                    width: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productModel.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: const Icon(
                    Icons.north_east,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Get.to(
          () => ProductProfilView(
            productModel: productModel,
            businessUserID: businessUserID,
          ),
        );
      },
      child: Container(
        margin: homePageStyle == true
            ? const EdgeInsets.only(left: 20, top: 10, bottom: 10)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          boxShadow: homePageStyle == true
              ? [
                  BoxShadow(
                    color: ColorConstants.darkMainColor.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 5,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.transparent,
                  ),
                ],
          borderRadius: BorderRadii.borderRadius10,
        ),
        child: ClipRRect(
          borderRadius: BorderRadii.borderRadius10,
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: authController.ipAddress.value + (productModel.img),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => EmptyStates().loadingData(),
                  errorWidget: (context, url, error) =>
                      EmptyStates().noMiniCategoryImage(),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: showFavButton
                    ? FavButton(
                        productProfilStyle: false,
                        product: productModel,
                      )
                    : const SizedBox.shrink(),
              ),
              showFavButton == false
                  ? Positioned(
                      top: 5,
                      left: 5,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: ColorConstants.whiteMainColor.withOpacity(.8),
                          border: Border.all(
                            color: ColorConstants.kPrimaryColor.withOpacity(.6),
                            width: 0.1,
                          ),
                          borderRadius: BorderRadii.borderRadius10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              productModel.viewCount.toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: AppFontSizes.fontSize10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: ColorConstants.whiteMainColor.withOpacity(.8),
                          border: Border.all(
                            color: ColorConstants.kPrimaryColor.withOpacity(.6),
                            width: 0.5,
                          ),
                          borderRadius: BorderRadii.borderRadius15,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                                color: ColorConstants.kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: AppFontSizes.fontSize12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              homePageStyle
                  ? Positioned(
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
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
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurvedWhiteCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(size.width, size.height * 0.55);
    path.quadraticBezierTo(
      size.width * 0.98,
      size.height * 0.95,
      size.width * 0.40,
      size.height,
    );
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
