import 'package:atelyam/app/data/models/product_model.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

class MyProductCard extends StatelessWidget {
  final ProductModel productModel;
  final Function() onTap;

  const MyProductCard({
    required this.productModel,
    required this.onTap,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorConstants.whiteMainColor,
        borderRadius: BorderRadii.borderRadius10,
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
                color: productModel.status.toString().toLowerCase() == 'true'
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
                    border: Border.all(
                      color: ColorConstants.kSecondaryColor,
                      width: 0.5,
                    ),
                  ),
                  margin: EdgeInsets.only(right: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadii.borderRadius10,
                    child: productModel.img.toString() == 'null'
                        ? Icon(
                            IconlyLight.image_2,
                            color: Colors.grey,
                          )
                        : WidgetsMine().customCachedImage(
                            productModel.img,
                          ),
                  ),
                ),
                productModel.status.toString().toLowerCase() == 'true'
                    ? waitingDesign()
                    : Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              productModel.name.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ColorConstants.kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: AppFontSizes.getFontSize(4.5),
                              ),
                            ),
                            Text(
                              productModel.price.toString() + ' TMT ',
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
               
                IconButton(
                  onPressed: onTap,
                  icon: Icon(IconlyLight.edit_square),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded waitingDesign() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    );
  }

  Expanded inactiveDesign() {
    return Expanded(
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
    );
  }
}
