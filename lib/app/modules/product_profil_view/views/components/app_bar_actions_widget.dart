import 'package:atelyam/app/modules/settings_view/components/fav_button_product.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';

class AppBarActionsWidget extends StatelessWidget {
  const AppBarActionsWidget({
    required this.controller,
    required this.productModel,
  });

  final ProductProfilController controller;
  final ProductModel productModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: controller.showMoreOptions.value
                ? Container(
                    key: const ValueKey('rightPanel'),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadii.borderRadius15,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  IconlyLight.show,
                                  color: ColorConstants.whiteMainColor,
                                  size: AppFontSizes.fontSize24,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  controller.viewCount.toString(),
                                  style: TextStyle(
                                    color: ColorConstants.whiteMainColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppFontSizes.fontSize20 - 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // FavButton
                        FavButtonProduct(
                          productProfilStyle: true,
                          product: productModel,
                        ),
                        const SizedBox(width: 10),

                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            style: IconButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadii.borderRadius15,
                              ),
                              backgroundColor: Colors.grey.withOpacity(0.7),
                            ),
                            icon: Icon(
                              IconlyLight.download,
                              color: ColorConstants.whiteMainColor,
                              size: AppFontSizes.fontSize24,
                            ),
                            onPressed: () {
                              controller.checkPermissionAndDownloadImage(
                                controller.productImages[
                                    controller.selectedImageIndex.value],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.showMoreOptions.toggle();
          },
          child: Container(
            child: Icon(
              Icons.more_vert,
              color: ColorConstants.whiteMainColor,
              size: AppFontSizes.fontSize30,
            ),
          ),
        ),
      ],
    );
  }
}
