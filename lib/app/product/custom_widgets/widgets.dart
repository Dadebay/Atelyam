import 'dart:io';

import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/product/custom_widgets/back_button.dart';
import 'package:atelyam/app/product/empty_states/empty_states.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

enum FilterOption {
  lowPrice,
  highPrice,
  viewCount,
  first,
  last,
}

SnackbarController showSnackBar(String title, String subtitle, Color color) {
  if (SnackbarController.isSnackbarBeingShown) {
    SnackbarController.cancelAllSnackbars();
  }
  return Get.snackbar(
    title,
    subtitle,
    snackStyle: SnackStyle.FLOATING,
    titleText: title == ''
        ? const SizedBox.shrink()
        : Text(
            title.tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppFontSizes.fontSize20,
              color: Colors.white,
            ),
          ),
    messageText: Text(
      subtitle.tr,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: AppFontSizes.fontSize16,
        color: Colors.white,
      ),
    ),
    snackPosition: SnackPosition.TOP,
    backgroundColor: color,
    borderRadius: 20.0,
    duration: const Duration(seconds: 1),
    margin: const EdgeInsets.all(8),
  );
}

class WidgetsMine {
  Widget buildUploadButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(IconlyLight.image, size: 40, color: Colors.grey.shade400),
            SizedBox(height: 8),
            Text(
              'add_image'.tr,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageItem({required File image, required VoidCallback onTap}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(
            image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          right: 5,
          top: 5,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildImageItemEditProduct({
    required String image,
    required VoidCallback onTap,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: WidgetsMine().customCachedImage(
            image,
          ),
        ),
        Positioned(
          right: 5,
          top: 5,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget customCachedImage(String image, {double? width, double? height}) {
    final AuthController authController = Get.find();

    return CachedNetworkImage(
      imageUrl: authController.ipAddress.value + image,
      fit: BoxFit.cover,
      fadeInCurve: Curves.ease,
      placeholder: (context, url) => EmptyStates().loadingData(),
      errorWidget: (context, url, error) => EmptyStates().noMiniCategoryImage(),
    );
  }

  AppBar appBar({required String appBarName, required List<Widget> actions}) {
    return AppBar(
      backgroundColor: ColorConstants.kSecondaryColor,
      title: Text(
        appBarName.tr,
        style: TextStyle(
          color: ColorConstants.whiteMainColor,
          fontSize: AppFontSizes.fontSize16 + 2,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: BackButtonMine(miniButton: true),
      actions: actions,
    );
  }
}
