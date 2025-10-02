import 'package:atelyam/app/product/custom_widgets/index.dart';

class ProductImagePageView extends StatelessWidget {
  const ProductImagePageView({
    required this.controller,
    required this.pageController,
  });

  final ProductProfilController controller;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? EmptyStates().loadingData()
          : GestureDetector(
              onTap: () {
                Get.to(
                  () => PhotoViewPage(
                    images: controller.productImages,
                    initialIndex: controller.selectedImageIndex.value,
                  ),
                );
              },
              child: Align(
                alignment: Alignment.bottomCenter,
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  controller: pageController,
                  itemCount: controller.productImages.length,
                  onPageChanged: (index) {
                    controller.updateSelectedImageIndex(index);
                  },
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: controller.productImages.isNotEmpty
                          ? controller.productImages[index]
                          : '',
                      fit: BoxFit.cover,
                      height: Get.size.height,
                      width: Get.size.width,
                      placeholder: (context, url) =>
                          EmptyStates().loadingData(),
                      errorWidget: (context, url, error) =>
                          EmptyStates().noMiniCategoryImage(),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
