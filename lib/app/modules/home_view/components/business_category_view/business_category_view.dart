import 'package:atelyam/app/data/models/business_category_model.dart';
import 'package:atelyam/app/modules/home_view/components/business_category_view/all_business_users_view.dart';
import 'package:atelyam/app/modules/home_view/controllers/business_category_controller.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';

class BusinessCategoryView extends GetView<BusinessCategoryController> {
  final double screenWidth;
  final Future<List<BusinessCategoryModel>?> categoriesFuture;
  const BusinessCategoryView({
    required this.screenWidth,
    required this.categoriesFuture,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(BusinessCategoryController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 4.0,
          ),
          child: Text(
            'types_of_business'.tr,
            style: TextStyle(
              fontSize: AppFontSizes.fontSize20,
              fontWeight: FontWeight.w600,
              color: ColorConstants.darkMainColor,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: FutureBuilder<List<BusinessCategoryModel>?>(
            future: categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return EmptyStates().loadingData();
              } else if (snapshot.hasError || snapshot.data == null) {
                return EmptyStates().errorData(snapshot.error.toString());
              } else {
                final List<BusinessCategoryModel> categories = snapshot.data!;
                return ListView.builder(
                  itemCount: categories.length,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  itemBuilder: (BuildContext context, int index) {
                    final category = categories[index];

                    return Obx(() {
                      final bool isSelected =
                          controller.selectedIndex.value == index;
                      return GestureDetector(
                        onTap: () {
                          Get.to(
                            () => AllBusinessUsersView(categoryId: category.id),
                          );
                          controller.setSelectedIndex(index);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 14,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      ColorConstants.kSecondaryColor
                                          .withOpacity(0.7),
                                      ColorConstants.kSecondaryColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.9),
                                      Colors.grey.shade200,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? ColorConstants.kSecondaryColor
                                        .withOpacity(0.2)
                                    : Colors.black12,
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipOval(
                                child: SizedBox(
                                  width: 45,
                                  height: 50,
                                  child: WidgetsMine().customCachedImage(
                                    width: 45,
                                    height: 50,
                                    category.img,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : ColorConstants.darkMainColor
                                          .withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
