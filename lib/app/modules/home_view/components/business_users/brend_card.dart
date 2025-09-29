import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/modules/home_view/components/business_users/business_user_profile_view.dart';
import 'package:atelyam/app/product/empty_states/empty_states.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrendCard extends StatelessWidget {
  BrendCard({
    required this.businessUserModel,
    super.key,
  });
  final BusinessUserModel businessUserModel;
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => BusinessUserProfileView(
            businessUserModelFromOutside: businessUserModel,
            categoryID: businessUserModel.userID!,
            whichPage: 'popular',
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ColorConstants.kSecondaryColor.withOpacity(0.4),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: authController.ipAddress.value +
                      businessUserModel.images!.first,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => EmptyStates().loadingData(),
                  errorWidget: (context, url, error) =>
                      EmptyStates().noMiniCategoryImage(),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Text(
                  businessUserModel.businessName.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Bell',
                    color: Colors.white,
                    fontSize: AppFontSizes.fontSize18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Get.to(
                      () => BusinessUserProfileView(
                        businessUserModelFromOutside: businessUserModel,
                        categoryID: businessUserModel.userID!,
                        whichPage: 'popular',
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'BIZNESE GIR',
                        style: TextStyle(
                          color: ColorConstants.darkMainColor,
                          fontSize: AppFontSizes.fontSize16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Container(
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: ColorConstants.kPrimaryColor,
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
