import 'package:atelyam/app/data/models/business_category_model.dart';
import 'package:atelyam/app/modules/home_view/components/business_category_view/all_business_users_view.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart'; // Bu dosyanın içeriği hakkında bilgim yok, varsayılan olarak doğru çalıştığını kabul ediyorum.
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BusinessCategoryView extends StatefulWidget {
  final double screenWidth;
  final Future<List<BusinessCategoryModel>?> categoriesFuture;
  const BusinessCategoryView({
    required this.screenWidth,
    required this.categoriesFuture,
    super.key,
  });

  @override
  State<BusinessCategoryView> createState() => _BusinessCategoryViewState();
}

class _BusinessCategoryViewState extends State<BusinessCategoryView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            'types_of_business'.tr,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ColorConstants.darkMainColor,
            ),
          ),
        ),
        SizedBox(
          height: 90,
          child: FutureBuilder<List<BusinessCategoryModel>?>(
            future: widget.categoriesFuture,
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
                    final bool isSelected = _selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: Transform.rotate(
                        angle: 0.03,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 18,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ColorConstants.kSecondaryColor
                                    .withOpacity(0.8)
                                : ColorConstants.whiteMainColor,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? ColorConstants.kSecondaryColor
                                        .withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.white,
                                  child: WidgetsMine().customCachedImage(
                                    category.img,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: isSelected
                                      ? Colors.white
                                      : ColorConstants.darkMainColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
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
