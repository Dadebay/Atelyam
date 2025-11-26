import 'package:atelyam/app/modules/settings_view/components/fav_button_product.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';

class AppBarActionsWidget extends StatelessWidget {
  AppBarActionsWidget({required this.productModel, required this.phoneNumber});

  final ProductProfilController controller = Get.find<ProductProfilController>();
  final ProductModel productModel;
  final String phoneNumber;
  Future<void> _makePhoneCall(String phoneNumber) async {
    final String phoneNumberText = phoneNumber.contains('+993') ? phoneNumber : '+993${phoneNumber}';

    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumberText);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      showSnackBar('error', 'phone_call_error' + launchUri.toString(), ColorConstants.redColor);
      throw 'Could not launch $launchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: controller.viewCount.toString().length > 3 ? 53 : 43,
          height: 43,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ColorConstants.whiteOpacity,
            borderRadius: BorderRadii.borderRadius15,
            border: Border.all(color: ColorConstants.whiteBorder),
          ),
          child: Obx(
            () => Text(
              controller.viewCount.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ColorConstants.kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: AppFontSizes.fontSize20 - 2,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 6),
          child: Container(
            width: 43,
            height: 43,
            child: FavButtonProduct(productProfilStyle: true, product: productModel),
          ),
        ),
        Container(
          width: 43,
          height: 43,
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: ColorConstants.whiteOpacity,
            borderRadius: BorderRadii.borderRadius15,
            border: Border.all(color: ColorConstants.whiteBorder),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(IconlyLight.download, color: ColorConstants.kPrimaryColor, size: AppFontSizes.fontSize24),
            onPressed: () {
              controller.checkPermissionAndDownloadImage(controller.productImages[controller.selectedImageIndex.value]);
            },
          ),
        ),
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: ColorConstants.whiteOpacity,
            borderRadius: BorderRadii.borderRadius15,
            border: Border.all(color: ColorConstants.whiteBorder),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(IconlyLight.call, color: ColorConstants.kPrimaryColor, size: AppFontSizes.fontSize24),
            onPressed: () {
              _makePhoneCall('+${phoneNumber}');
            },
          ),
        ),
      ],
    );
  }
}
