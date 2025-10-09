import 'package:atelyam/app/product/custom_widgets/index.dart';

class ProductThumbnailList extends StatelessWidget {
  const ProductThumbnailList({
    required this.controller,
    required this.outSideBusinessuserModel,
    required this.makePhoneCall,
    Key? key,
  }) : super(key: key);

  final ProductProfilController controller;
  final BusinessUserModel? outSideBusinessuserModel;
  final Function(String) makePhoneCall;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 10,
      top: AppBar().preferredSize.height + 20,
      bottom: 20,
      child: SizedBox(
        width: 45,
        child: Obx(() {
          final double itemHeight = Get.height * 0.130;
          final int visibleImageCount = controller.productImages.length > 4
              ? 4
              : controller.productImages.length;
          double imagesSectionHeight = visibleImageCount * itemHeight;
          if (visibleImageCount == 1) {
            imagesSectionHeight = Get.height * 0.20;
          } else if (visibleImageCount == 2) {
            imagesSectionHeight = Get.height * 0.30;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: imagesSectionHeight,
                child: Center(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: controller.productImages.length <= 4
                        ? NeverScrollableScrollPhysics()
                        : null,
                    itemCount: controller.productImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          controller.updateSelectedImageIndex(index);
                        },
                        child: Obx(
                          () => Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            width: Get.width * 0.112,
                            height: Get.height * 0.092,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadii.borderRadius15,
                              border: Border.all(
                                color:
                                    index == controller.selectedImageIndex.value
                                        ? Colors.white
                                        : Colors.grey.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadii.borderRadius15,
                              child: CachedNetworkImage(
                                imageUrl: controller.productImages[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    EmptyStates().loadingData(),
                                errorWidget: (context, url, error) =>
                                    EmptyStates().noMiniCategoryImage(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (outSideBusinessuserModel != null) {
                    makePhoneCall(
                      '+${outSideBusinessuserModel!.businessPhone}',
                    );
                  } else {
                    showSnackBar(
                      'error',
                      'phone_call_error',
                      ColorConstants.redColor,
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  width: Get.width * 0.12,
                  height: Get.height * 0.092,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    IconlyLight.call,
                    color: ColorConstants.whiteMainColor,
                    size: Get.width * 0.07,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
