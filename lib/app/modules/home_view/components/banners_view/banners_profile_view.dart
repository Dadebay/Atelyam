import 'package:atelyam/app/data/models/banner_model.dart';
import 'package:atelyam/app/modules/home_view/components/banners_view/banner_card.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannersProfile extends StatelessWidget {
  const BannersProfile({required this.banner, super.key});
  final BannerModel banner;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      appBar: WidgetsMine().appBar(appBarName: 'banners_profile', actions: []),
      body: ListView(
        children: [
          SizedBox(
            height: Get.size.height / 3.5,
            child: BannerCard(
              banner: banner,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              banner.description,
              style: TextStyle(
                  color: ColorConstants.kPrimaryColor,
                  fontWeight: FontWeight.w400,
                  fontSize: AppFontSizes.fontSize16),
            ),
          ),
        ],
      ),
    );
  }
}
