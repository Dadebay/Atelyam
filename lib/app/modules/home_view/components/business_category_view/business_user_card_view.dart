// lib/app/modules/home_view/components/brend_card_2.dart

import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/modules/home_view/components/business_users/business_user_profile_view.dart';
import 'package:atelyam/app/product/empty_states/empty_states.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BusinessUsersCardView extends StatelessWidget {
  BusinessUsersCardView({
    required this.category,
    required this.categoryID,
    super.key,
  });
  final BusinessUserModel category;
  final int categoryID;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => BusinessUserProfileView(
            businessUserModelFromOutside: category,
            categoryID: categoryID,
            whichPage: '',
          ),
        );
      },
      child: Container(
        height: 300,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadii.borderRadius15,
          color: ColorConstants.whiteMainColor.withOpacity(.8),
          border: Border.all(
            color: ColorConstants.kPrimaryColor.withOpacity(.2),
          ),
        ),
        child: topPart(),
      ),
    );
  }

  final AuthController authController = Get.find();

  Widget topPart() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            width: 105,
            height: 90,
            margin: const EdgeInsets.only(top: 10),
            child: ClipRRect(
              borderRadius: BorderRadii.borderRadius5,
              child: CachedNetworkImage(
                fadeInCurve: Curves.ease,
                imageUrl: authController.ipAddress.value + category.backPhoto,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadii.borderRadius50,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => EmptyStates().loadingData(),
                errorWidget: (context, url, error) =>
                    EmptyStates().noMiniCategoryImage(),
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.businessName.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppFontSizes.fontSize20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  category.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.darkMainColor.withOpacity(.8),
                    fontSize: AppFontSizes.fontSize14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
