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
          final itemsCount = controller.productImages.length + 1;
          final displayCount = itemsCount > 4 ? 4 : itemsCount;
          return Container(
            height: displayCount * 85.0,
            child: ListView.builder(
              itemCount: itemsCount,
              itemBuilder: (context, index) {
                if (index == controller.productImages.length) {
                  return GestureDetector(
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
                      width: 45,
                      height: 75,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        IconlyLight.call,
                        color: ColorConstants.whiteMainColor,
                        size: 28,
                      ),
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      controller.updateSelectedImageIndex(index);
                    },
                    child: Obx(
                      () => Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        width: 42,
                        height: 75,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadii.borderRadius15,
                          border: Border.all(
                            color: index == controller.selectedImageIndex.value
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
                }
              },
            ),
          );
        }),
      ),
    );
  }
}
