import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/data/models/product_model.dart';
import 'package:atelyam/app/data/service/business_user_service.dart';
import 'package:atelyam/app/data/service/product_service.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class BrandsController extends GetxController {
  final ProductService _productService = ProductService();
  final BusinessUserService _businessUserService = BusinessUserService();
  RxBool isLoadingBrandsProfile = false.obs;
  late Rx<BusinessUserModel?> businessUser = Rx<BusinessUserModel?>(null);
  late Rx<Future<List<ProductModel>?>> productsFuture = Rx<Future<List<ProductModel>?>>(Future.value(null));
  Future<void> fetchBusinessUserData({
    required BusinessUserModel businessUserModelFromOutside,
    required int categoryID,
    required String whichPage,
  }) async {
    isLoadingBrandsProfile.value = true;
    try {
      businessUser.value = await _businessUserService.fetchBusinessAccountByID(businessUserModelFromOutside.id);
      print(whichPage);
      if (whichPage == 'popular') {
        productsFuture.value = _productService.fetchPopularProductsByUserID(categoryID);
      } else {
        productsFuture.value = _productService.fetchProducts(categoryID, businessUser.value!.user);
      }
    } catch (e) {
      showSnackBar('error', 'anErrorOccurred' + '$e', ColorConstants.redColor);
    } finally {
      isLoadingBrandsProfile.value = false;
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    print(phoneNumber);
    final Uri launchUri = Uri.parse('tel:$phoneNumber');

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      showSnackBar('error', 'phone_call_error'.tr, ColorConstants.redColor);
    }
  }
}
