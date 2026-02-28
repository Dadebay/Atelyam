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
      // Tam profil detayları için getUserById endpointini kullan (instagram, tiktok, website vb.)
      // Endpoint user ID beklediği için .user kullanılıyor, .id değil
      // Tam profil verileri için getUserById endpointini kullanıyoruz
      // .user = User ID, .id = Business Account ID — endpoint User ID bekliyor
      final fetched = await _businessUserService.fetchBusinessAccountKICI(businessUserModelFromOutside.userID!);
      // API null döndürürse dışarıdan gelen model ile devam et
      businessUser.value = fetched ?? businessUserModelFromOutside;
      print(whichPage);
      print(businessUser.value?.instagram);
      print(businessUser.value?.tiktok);
      print(businessUser.value?.youtube);
      print(businessUser.value?.address);
      print(businessUser.value?.businessPhone);
      if (whichPage == 'popular' || whichPage == 'map') {
        final uid = (businessUser.value?.userID ?? 0) != 0 ? businessUser.value!.userID! : (businessUser.value?.user ?? 0);
        productsFuture.value = _productService.fetchPopularProductsByUserID(uid);
      } else {
        productsFuture.value = _productService.fetchProducts(categoryID, businessUser.value?.user ?? 0);
      }
    } catch (e, stackTrace) {
      print('fetchBusinessUserData ERROR: $e');
      print('STACK: $stackTrace');
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
