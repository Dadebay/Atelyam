import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

class BusinessAccCard extends StatelessWidget {
  const BusinessAccCard(
      {required this.businessUser, required this.onTap, super.key,});
  final GetMyStatusModel businessUser;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorConstants.whiteMainColor, // Pasif hesap rengi
        borderRadius: BorderRadii.borderRadius10, // Köşe yuvarlaklığı
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 3,
            blurRadius: 3,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: businessUser.status.toString().toLowerCase() ==
                        'inactive'
                    ? ColorConstants.redColor.withOpacity(.8)
                    : businessUser.status.toString().toLowerCase() == 'pending'
                        ? Colors.grey.shade200
                        : ColorConstants.whiteMainColor,
                borderRadius: BorderRadii.borderRadius10,
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadii.borderRadius10,
                    color: Colors.white,
                    border: businessUser.backPhoto == null
                        ? Border.all(
                            color: ColorConstants.kSecondaryColor,
                            width: 0.5,
                          )
                        : Border.all(),
                  ),
                  margin: EdgeInsets.only(right: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadii.borderRadius10,
                    child: businessUser.backPhoto == null
                        ? Icon(
                            IconlyLight.image_2,
                            color: Colors.grey,
                          )
                        : WidgetsMine().customCachedImage(
                            businessUser.backPhoto ?? '',
                          ),
                  ),
                ),
                businessUser.status.toString().toLowerCase() == 'inactive'
                    ? Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'inactive'.tr,
                              style: TextStyle(
                                color: ColorConstants.kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: AppFontSizes.getFontSize(4.5),
                              ),
                            ),
                            Text(
                              'inactive_desc'.tr,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ColorConstants.kPrimaryColor,
                                fontWeight: FontWeight.w400,
                                fontSize: AppFontSizes.getFontSize(3.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : businessUser.status.toString().toLowerCase() == 'pending'
                        ? Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'wait'.tr,
                                  style: TextStyle(
                                    color: ColorConstants.kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppFontSizes.getFontSize(4.5),
                                  ),
                                ),
                                Text(
                                  'wait_desc'.tr,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: ColorConstants.kPrimaryColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: AppFontSizes.getFontSize(3.5),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  businessUser.businessName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: ColorConstants.kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppFontSizes.getFontSize(4.5),
                                  ),
                                ),
                                Text(
                                  '+993' +
                                      businessUser
                                          .businessPhone!, // İşletme telefonu
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: ColorConstants.kPrimaryColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: AppFontSizes.getFontSize(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                // Düzenleme butonu
                IconButton(
                  onPressed: onTap,
                  icon: Icon(IconlyLight.edit_square), // Düzenleme ikonusssss
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
