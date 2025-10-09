import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:photo_view/photo_view.dart';

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
          : Align(
              alignment: Alignment.bottomCenter,
              child: PageView.builder(
                scrollDirection: Axis.vertical,
                controller: pageController,
                itemCount: controller.productImages.length,
                onPageChanged: (index) {
                  controller.updateSelectedImageIndex(index);
                },
                itemBuilder: (context, index) {
                  return PhotoView(
                    imageProvider: CachedNetworkImageProvider(
                      controller.productImages.isNotEmpty
                          ? (controller.productImages[index])
                          : '',
                    ),
                    loadingBuilder: (context, event) =>
                        EmptyStates().loadingData(),
                    errorBuilder: (context, url, error) =>
                        EmptyStates().noMiniCategoryImage(),
                    backgroundDecoration:
                        const BoxDecoration(color: Colors.transparent),
                    initialScale: PhotoViewComputedScale.covered,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                  );
                },
              ),
            ),
    );
  }
}