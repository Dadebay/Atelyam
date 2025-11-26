import 'package:atelyam/app/data/models/business_category_model.dart';
import 'package:atelyam/app/modules/home_view/components/business_category_view/all_business_users_view.dart';
import 'package:atelyam/app/modules/home_view/controllers/business_category_controller.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';

class BusinessCategoryView extends GetView<BusinessCategoryController> {
  final double screenWidth;
  final Future<List<BusinessCategoryModel>?> categoriesFuture;
  BusinessCategoryView({
    required this.screenWidth,
    required this.categoriesFuture,
    super.key,
  });
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0),
          child: Text(
            'types_of_business'.tr,
            style: TextStyle(
              fontSize: AppFontSizes.fontSize20,
              fontWeight: FontWeight.w600,
              color: ColorConstants.darkMainColor,
            ),
          ),
        ),
        Container(
          height: 110,
          padding: EdgeInsets.symmetric(vertical: 8),
          child: FutureBuilder<List<BusinessCategoryModel>?>(
            future: categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return EmptyStates().loadingData();
              } else if (snapshot.hasError || snapshot.data == null) {
                return EmptyStates().errorData(snapshot.error.toString());
              } else {
                final List<BusinessCategoryModel> categories = snapshot.data!;
                print('Categories count: ${categories.length}');
                return ListView.builder(
                  itemCount: categories.length,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final category = categories[index];

                    return Obx(() {
                      final bool isSelected = controller.selectedIndex.value == index;
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => AllBusinessUsersView(categoryId: category.id));
                          controller.setSelectedIndex(index);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 14),
                          padding: const EdgeInsets.only(left: 6, right: 12, top: 6, bottom: 6),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      ColorConstants.kSecondaryColor.withOpacity(0.7),
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
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? ColorConstants.kSecondaryColor.withOpacity(0.2) : Colors.black12,
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(shape: BoxShape.circle),
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: authController.ipAddress.value + category.img,
                                    fit: BoxFit.cover,
                                    fadeInCurve: Curves.ease,
                                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => EmptyStates().noMiniCategoryImage(),
                                  ),
                                ),
                              ),
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isSelected ? Colors.white : ColorConstants.darkMainColor.withOpacity(0.9),
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
