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
      // userID 0 veya null gelirse API çağrısı atla, dışarıdan gelen modeli kullan
      final userId = (businessUserModelFromOutside.userID != null && businessUserModelFromOutside.userID! > 0)
          ? businessUserModelFromOutside.userID!
          : (businessUserModelFromOutside.user > 0 ? businessUserModelFromOutside.user : null);

      print('[BrandsController] id=${businessUserModelFromOutside.id} userID=${businessUserModelFromOutside.userID} user=${businessUserModelFromOutside.user} → userId=$userId');

      if (userId != null && userId > 0) {
        final fetched = await _businessUserService.fetchBusinessAccountKICI(userId);
        businessUser.value = fetched ?? businessUserModelFromOutside;
      } else {
        // cats_id endpoint'i user field'ı döndürmüyor — business ID ile tam modeli al
        print('[BrandsController] userId null, GetUserId/${businessUserModelFromOutside.id}/ ile tam model alınıyor...');
        final fetched = await _businessUserService.fetchBusinessAccountByID(businessUserModelFromOutside.id);
        businessUser.value = fetched ?? businessUserModelFromOutside;
        print('[BrandsController] GetUserId sonucu: id=${businessUser.value?.id} user=${businessUser.value?.user} userID=${businessUser.value?.userID}');
      }

      print(whichPage);

      if (whichPage == 'popular' || whichPage == 'map') {
        final uid = (businessUser.value?.userID ?? 0) != 0 ? businessUser.value!.userID! : (businessUser.value?.user ?? 0);
        productsFuture.value = _productService.fetchPopularProductsByUserID(uid);
        print("Menden hartylary aldy ---------------------- productsFuture.value = _productService.fetchPopularProductsByUserID(uid);");
      } else {
        final userVal = businessUser.value?.user ?? 0;

        print('[BrandsController] fetchProducts categoryID=$categoryID userId=$userVal');
        productsFuture.value = _productService.fetchProducts(categoryID, userVal);
        print("Menden hartylary aldy ---------------------- productsFuture.value = _productService.fetchProducts(uid);");
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
