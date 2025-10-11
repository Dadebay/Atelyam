import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

class EmptyStates {
  Center noMiniCategoryImage() {
    return Center(
      child: Text(
        'no_category_image'.tr,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: const TextStyle(
          color: ColorConstants.whiteMainColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget errorData(String error) {
    return Center(child: Text('Error: $error'));
  }

  Widget noDataAvailable() {
    return Center(
      child: Text(
        'no_data_available'.tr,
        style: TextStyle(
          color: ColorConstants.kPrimaryColor,
          fontSize: AppFontSizes.fontSize20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget noDataAvailablePage({required Color textColor}) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Lottie.asset('assets/lottie/nodata.json'),
          ),
          Text(
            'no_data_available'.tr,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: AppFontSizes.getFontSize(6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget noFavoritesFound() {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Lottie.asset('assets/lottie/nodata.json'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'noFavoritesFound'.tr,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorConstants.darkMainColor,
                fontSize: AppFontSizes.fontSize20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget noBannersAvailable() {
    return Center(
      child: Text(
        'no_banners_to_display'.tr,
        style: const TextStyle(
          color: ColorConstants.kPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget noCategoriesAvailable() {
    return Center(
      child: Text(
        'no_categories_to_display'.tr,
        style: const TextStyle(
          color: ColorConstants.kPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget loadingData() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.grey,
        highlightColor: ColorConstants.kThirdColor,
        child: const Text(
          'Atelyam',
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
