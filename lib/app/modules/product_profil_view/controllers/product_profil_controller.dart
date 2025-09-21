import 'dart:io';

import 'package:atelyam/app/data/service/image_service.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:dio/dio.dart';
// import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ProductProfilController extends GetxController {
  final ImageService _imageService = ImageService();
  final AuthController authController = Get.find();
  RxInt selectedImageIndex = 0.obs;
  RxList<String> productImages = <String>[].obs;
  RxBool isLoading = true.obs;
  RxInt viewCount = 0.obs;

  Future<void> fetchImages(final int id, final String mainImage) async {
    isLoading.value = true;
    try {
      productImages.clear();
      final imageModel = await _imageService.fetchImageByProductID(id);
      if (imageModel != null) {
        productImages.value = imageModel.images.where((img) => img != null).map((img) => authController.ipAddress.value + img!).toList();
        productImages.insert(0, authController.ipAddress.value + mainImage);
      } else {
        productImages.insert(0, authController.ipAddress.value + mainImage);
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<void> fetchViewCount(final int id) async {
    try {
      final businessUser = await _imageService.fetchProductById(id);
      if (businessUser != null) {
        viewCount.value = businessUser.viewCount;
      }
    } catch (e) {
      showSnackBar('error', 'image_download_error'.tr, ColorConstants.redColor);
    }
  }

  void updateSelectedImageIndex(int index) {
    selectedImageIndex.value = index;
  }

  Future<void> checkPermissionAndDownloadImage(String imageURL) async {
    final Map<Permission, PermissionStatus> statues = await [
      Permission.storage,
      Permission.photos,
    ].request();

    final PermissionStatus? statusStorage = statues[Permission.storage];
    final PermissionStatus? statusPhotos = statues[Permission.photos];

    final bool isPermanentlyDenied = statusStorage == PermissionStatus.permanentlyDenied || statusPhotos == PermissionStatus.permanentlyDenied;

    if (isPermanentlyDenied) {
      showSnackBar('warning', 'storage_permission_denied', ColorConstants.redColor);
    } else {
      try {
        showSnackBar('downloading', 'download_started', ColorConstants.greenColor);

        final Dio dio = Dio();
        final Directory? downloadsDir = await getExternalStorageDirectory();
        final String savePath = '${downloadsDir!.path}/Pictures';
        final Directory dir = Directory(savePath);
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        final String fileName = 'Atelyam_${DateTime.now().toString().replaceAll(RegExp(r'[^\w]'), '_')}.webp';
        final String fullPath = '$savePath/$fileName';
        await dio.download(imageURL, fullPath);
        // await Gal.putImage(fullPath);

        showSnackBar('success', 'downloaded', ColorConstants.kSecondaryColor);
      } catch (e) {
        showSnackBar('error', 'image_download_error'.tr, ColorConstants.redColor);
      }
    }
  }
}
