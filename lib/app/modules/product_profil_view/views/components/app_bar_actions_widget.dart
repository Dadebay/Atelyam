import 'package:atelyam/app/modules/settings_view/components/fav_button_product.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';

class AppBarActionsWidget extends StatelessWidget {
  AppBarActionsWidget({required this.productModel, required this.phoneNumber});

  final ProductProfilController controller = Get.find<ProductProfilController>();
  final ProductModel productModel;
  final String phoneNumber;
  Future<void> _makePhoneCall(String phoneNumber) async {
    String raw = phoneNumber.trim();
    print('📞********************************************************************************** Ham numara (gelen): $raw');
    // Eğer zaten + ile başlıyorsa dokunma
    if (!raw.startsWith('+')) {
      final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly.length == 9 && digitsOnly.startsWith('9')) {
        // Özbek numarası (ör: 950911802 → +998950911802)
        raw = '+998$digitsOnly';
      } else if (digitsOnly.length == 8 && digitsOnly.startsWith('6')) {
        // Türkmenistan numarası (ör: 61234567 → +99361234567)
        raw = '+993$digitsOnly';
      } else if (digitsOnly.startsWith('998') || digitsOnly.startsWith('993') || digitsOnly.startsWith('90') || digitsOnly.startsWith('994') || digitsOnly.startsWith('7')) {
        raw = '+$digitsOnly';
      } else {
        raw = '+993$digitsOnly';
      }
    }
    print('📞 Formatlanan numara (aranacak): $raw');

    final Uri launchUri = Uri(scheme: 'tel', path: raw);

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
              _makePhoneCall(phoneNumber);
            },
          ),
        ),
      ],
    );
  }
}
