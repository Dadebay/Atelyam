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
          () => BusinessUserProfileView(businessUserModelFromOutside: category, categoryID: categoryID, whichPage: ''),
        );
      },
      child: Container(
        height: 310,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            borderRadius: BorderRadii.borderRadius15,
            color: ColorConstants.whiteMainColor,
            border: Border.all(
              color: ColorConstants.kPrimaryColor.withOpacity(.2),
            ),
            boxShadow: [
              BoxShadow(
                color: ColorConstants.kThirdColor.withOpacity(0.4),
                blurRadius: 5,
                spreadRadius: 1,
              )
            ]),
        child: topPart(),
      ),
    );
  }

  final AuthController authController = Get.find();

  Widget topPart() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 105,
          height: 105,
          color: Colors.transparent,
          margin: const EdgeInsets.only(top: 10),
          child: ClipRRect(
            borderRadius: BorderRadii.borderRadius5,
            child: CachedNetworkImage(
              fadeInCurve: Curves.ease,
              imageUrl: authController.ipAddress.value + (category.backPhoto),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: ColorConstants.kPrimaryColor),
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => EmptyStates().loadingData(),
              errorWidget: (context, url, error) => EmptyStates().noMiniCategoryImage(),
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
