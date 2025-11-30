import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:atelyam/app/data/models/business_category_model.dart';
import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/data/models/hashtag_model.dart';
import 'package:atelyam/app/data/service/auth_service.dart';
import 'package:atelyam/app/data/service/business_category_service.dart';
import 'package:atelyam/app/data/service/hashtag_service.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/modules/home_view/controllers/home_controller.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProductController extends GetxController {
  final AuthController authController = Get.find();
  RxList<BusinessCategoryModel> categories = <BusinessCategoryModel>[].obs;
  RxList<HashtagModel> hashtags = <HashtagModel>[].obs;
  final HomeController homeController = Get.find<HomeController>();
  final maxImageCount = 4; // Maksimum resim sayısı
  Rx<BusinessCategoryModel?> selectedCategory = Rx<BusinessCategoryModel?>(null);
  Rx<HashtagModel?> selectedHashtag = Rx<HashtagModel?>(null);
  Rx<File?> selectedImage = Rx<File?>(null);
  RxList<File?> selectedImages = RxList<File?>([]); // 1. Değişiklik: Liste yapısı
  RxList<String?> selectedImagesEditProduct = RxList<String?>([]); // 1. Değişiklik: Liste yapısı
  RxList<String?> deleteImageNames = RxList<String?>([]); // 1. Değişiklik: Liste yapısı

  final BusinessCategoryService _categoryService = BusinessCategoryService();
  final dio.Dio _dio = dio.Dio(); // Dio örneğini oluştur
  final HashtagService _hashtagService = HashtagService();
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadHashtags();
  }

  Future<XFile?> compressImage(File file) async {
    final int fileSizeInBytes = await file.length();
    final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    final double fileSizeInKB = fileSizeInBytes / 1024;

    int quality = 60;

    if (fileSizeInMB < 5) {
      quality = 60; // Reduced from 70 for faster loading
    } else if (fileSizeInMB >= 5 && fileSizeInMB < 10) {
      quality = 40; // Reduced from 50 for faster loading
    } else {
      quality = 25; // Reduced from 30 for faster loading
    }

    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path + '_compressed.jpg',
      quality: quality,
      minWidth: 800, // Reduced from 1000 for faster loading
      minHeight: 800, // Reduced from 1000 for faster loading
    );

    final int compressedFileSizeInBytes = await compressedImage!.length();
    final double compressedFileSizeInKB = compressedFileSizeInBytes / 1024;
    final double compressedFileSizeInMB = compressedFileSizeInBytes / (1024 * 1024);

    print('Original File Size: ${fileSizeInBytes} B');
    print('Original File Size: ${fileSizeInKB.toStringAsFixed(2)} KB');
    print('Original File Size: ${fileSizeInMB.toStringAsFixed(2)} MB');
    print('Compressed File Size: ${compressedFileSizeInBytes} B');
    print('Compressed File Size: ${compressedFileSizeInKB.toStringAsFixed(2)} KB');
    print('Compressed File Size: ${compressedFileSizeInMB.toStringAsFixed(2)} MB');
    return compressedImage;
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final File file = File(image.path);
      final compressedImage = await compressImage(file);
      if (compressedImage != null) {
        selectedImage.value = File(compressedImage.path);
      }
    }
  }

  Future<void> pickImages({bool isEditProduct = false}) async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      if (selectedImages.length + images.length > maxImageCount) {
        showSnackBar('error', 'max_4_images'.tr, ColorConstants.redColor);
        return;
      }

      for (var image in images) {
        final File file = File(image.path);

        // Print the original image size
        final int originalFileSizeInBytes = await file.length();
        final double originalFileSizeInKB = originalFileSizeInBytes / 1024;
        final double originalFileSizeInMB = originalFileSizeInBytes / (1024 * 1024);
        print('Original Image Size: ${originalFileSizeInBytes} B');
        print('Original Image Size: ${originalFileSizeInKB.toStringAsFixed(2)} KB');
        print('Original Image Size: ${originalFileSizeInMB.toStringAsFixed(2)} MB');

        final compressedImage = await compressImage(file);
        if (compressedImage != null) {
          // Print the compressed image size
          final int compressedFileSizeInBytes = await compressedImage.length();
          final double compressedFileSizeInKB = compressedFileSizeInBytes / 1024;
          final double compressedFileSizeInMB = compressedFileSizeInBytes / (1024 * 1024);
          print('Compressed Image Size: ${compressedFileSizeInBytes} B');
          print('Compressed Image Size: ${compressedFileSizeInKB.toStringAsFixed(2)} KB');
          print('Compressed Image Size: ${compressedFileSizeInMB.toStringAsFixed(2)} MB');

          if (isEditProduct) {
            selectedImagesEditProduct.add(compressedImage.path);
          } else {
            selectedImages.add(File(compressedImage.path));
          }
        }
      }
    }
  }

  Future<void> addProductToBackend({required String nameController, required String descriptionController, required String priceController}) async {
    if (selectedCategory.value == null || selectedHashtag.value == null) {
      showSnackBar('error', 'fill_all_fields'.tr, ColorConstants.redColor);
      return;
    }

    homeController.agreeButton.toggle();
    final token = await Auth().getToken();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${authController.ipAddress.value}/mobile/uploadProducts/'),
      );
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      });

      request.fields.addAll({
        'category_id': selectedCategory.value!.id.toString(),
        'hashtag_id': selectedHashtag.value!.id.toString(),
        'name': nameController,
        'description': descriptionController,
        'price': priceController,
      });

      if (selectedImage.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            selectedImage.value!.path,
          ),
        );
      }
      final response = await request.send();

      print('Response Status Code: ${response.statusCode}');
      final responseBytes = await response.stream.toBytes(); // Byte olarak oku
      final responseBody = utf8.decode(responseBytes); // UTF-8 formatına çevir
      print('Response Body: $responseBody');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(responseBody);
        print(int.parse(responseData['id'].toString()));
        if (selectedImages.isNotEmpty) {
          await uploadProductImages(int.parse(responseData['id'].toString())); // Resimleri yükle
        } else {
          Get.back(result: true);
          showSnackBar('success', 'product_upload_success'.tr, ColorConstants.greenColor);
        }
      } else {
        showSnackBar('error', 'product_creation_failed'.tr, ColorConstants.redColor);
      }
    } catch (e) {
      showSnackBar('error', 'error_occured'.tr, ColorConstants.redColor);
    } finally {
      homeController.agreeButton.toggle();
    }
  }

  Future<void> uploadProductImages(int productId) async {
    final token = await Auth().getToken();
    print('Selected Images Length: ${selectedImages.length}');
    print('Selected Images Length: ${selectedImagesEditProduct.length}');

    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${authController.ipAddress.value}/mobile/uploadImage/$productId/'),
      );
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      });

      // selectedImages listesinin boyutunu kontrol et
      if (selectedImages.isEmpty) {
        for (int i = 0; i < selectedImagesEditProduct.length; i++) {
          if (selectedImagesEditProduct[i] != null) {
            log(selectedImagesEditProduct[i].toString());
            if (selectedImagesEditProduct[i]!.startsWith('/media/')) {
            } else {
              request.files.add(
                await http.MultipartFile.fromPath(
                  'img${i + 1}', // img1, img2, img3, img4
                  selectedImagesEditProduct[i]!,
                ),
              );
            }
          } else {
            print('Image at index $i is null.');
          }
        }
      } else {
        for (int i = 0; i < selectedImages.length; i++) {
          if (selectedImages[i] != null) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'img${i + 1}', // img1, img2, img3, img4
                selectedImages[i]!.path,
              ),
            );
          } else {
            print('Image at index $i is null.');
          }
        }
      }
      request.fields.forEach((key, value) {
        print('Field: $key, Value: $value');
      });
      if (selectedImagesEditProduct.isNotEmpty || selectedImages.isNotEmpty) {
        final response = await request.send();
        print('Response Status Code: ${response.statusCode}');
        final responseBytes = await response.stream.toBytes(); // Byte olarak oku
        final responseBody = utf8.decode(responseBytes); // UTF-8 formatına çevir
        print('Response Body: $responseBody');

        if (response.statusCode == 200) {
          Get.back(result: true);
          showSnackBar('success', 'product_upload_success'.tr, ColorConstants.greenColor);
        } else {
          showSnackBar('error', 'image_upload_failed'.tr, ColorConstants.redColor);
        }
      }
    } catch (e) {
      print('Error occurred: $e');
      showSnackBar('error', 'error_occured'.tr, ColorConstants.redColor);
    }
  }

  Future<void> deleteSelectedImage(int productId, int imageIndex) async {
    final token = await Auth().getToken();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${authController.ipAddress.value}/mobile/uploadImage/$productId/'),
      );
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      });

      request.fields['img${imageIndex}'] = '1'; // Sadece index numarasını gönderiyoruz

      request.fields.forEach((key, value) {
        print('Field: $key, Value: $value');
      });
      final response = await request.send();
      print('Response Status Code: ${response.statusCode}');
      final responseBytes = await response.stream.toBytes(); // Byte olarak oku
      final responseBody = utf8.decode(responseBytes); // UTF-8 formatına çevir
      print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        showSnackBar('success', 'image_deleted'.tr, ColorConstants.greenColor);
      } else {
        showSnackBar('error', 'image_upload_failed'.tr, ColorConstants.redColor);
      }
    } catch (e) {
      print('Error occurred: $e');
      showSnackBar('error', 'error_occured'.tr, ColorConstants.redColor);
    }
  }

  Future<void> updateProduct({required int productId, required String nameController, required String descriptionController, required String priceController}) async {
    if (selectedCategory.value == null || selectedHashtag.value == null) {
      showSnackBar('error', 'fill_all_fields'.tr, ColorConstants.redColor);
      return;
    }
    homeController.agreeButton.toggle();
    final token = await Auth().getToken();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${authController.ipAddress.value}/mobile/productUpdate/$productId/'),
      );
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      });
      request.fields.addAll({
        'category_id': selectedCategory.value!.id.toString(),
        'hashtag_id': selectedHashtag.value!.id.toString(),
        'name': nameController,
        'description': descriptionController,
        'price': priceController,
      });
      if (selectedImage.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'img',
            selectedImage.value!.path,
          ),
        );
      }
      final response = await request.send();
      print('Response Status Code: ${response.statusCode}');
      final responseBytes = await response.stream.toBytes(); // Byte olarak oku
      final responseBody = utf8.decode(responseBytes); // UTF-8 formatına çevir
      print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        Get.back(result: true);
        showSnackBar('success', 'product_updated'.tr, ColorConstants.greenColor);
      } else {
        showSnackBar('error', 'update_failed'.tr, ColorConstants.redColor);
      }
    } catch (e) {
      showSnackBar('error', 'error_occurred'.tr, ColorConstants.redColor);
    } finally {
      homeController.agreeButton.toggle();
    }
  }

  Future<void> deleteProduct(int productID) async {
    final token = await Auth().getToken();
    final headers = {
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.delete(
        Uri.parse('${authController.ipAddress.value}/mobile/productDelete/$productID/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        Get.back(result: true);
        Get.back(result: true);
        showSnackBar('success', 'product_deleted'.tr, ColorConstants.greenColor);
      } else {
        showSnackBar('error', 'anErrorOccurred'.tr + '${response.reasonPhrase}', ColorConstants.redColor);
      }
    } catch (e) {
      Get.back(result: true);
      showSnackBar('error', 'anErrorOccurred'.tr + '$e', ColorConstants.redColor);
    }
  }

  Future<void> submitBusinessAccount(GetMyStatusModel businessUser) async {
    if (selectedCategory.value == null) {
      showSnackBar('error', 'fill_all_fields', ColorConstants.redColor);
      return;
    }
    if (selectedImage.value == null) {
      showSnackBar('error', 'logo_upload', ColorConstants.redColor);
      return;
    }

    final token = await Auth().getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    };
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${authController.ipAddress.value}/mobile/createUser/'),
    );
    request.fields.addAll({
      'title_id': selectedCategory.value!.id.toString(),
      'businessName': businessUser.businessName!,
      'businessPhone': businessUser.businessPhone!,
      'description': businessUser.description!,
      'address': businessUser.address!,
      'tiktok': businessUser.tiktok!,
      'instagram': businessUser.instagram!,
      'youtube': businessUser.youtube!,
      'website': businessUser.website!,
    });
    request.files.add(
      await http.MultipartFile.fromPath('file', selectedImage.value!.path),
    );
    request.headers.addAll(headers);
    try {
      final response = await request.send();
      print(response.statusCode);
      print(response.stream.toBytes());
      if (response.statusCode == 201) {
        Get.back(result: true);
      } else if (response.statusCode == 400) {
        showSnackBar('error', 'account_already_exist', ColorConstants.redColor);
      } else {
        showSnackBar('error', '${'account_create_failed'} ${response.reasonPhrase}', ColorConstants.redColor);
      }
    } catch (e) {
      Get.back(result: true);
      showSnackBar('error', '${'anErrorOccurred'} $e', ColorConstants.redColor);
    }
  }

  Future<void> updateBusinessAccount(GetMyStatusModel businessUser, String backPhoto) async {
    homeController.agreeButton.toggle();
    final token = await Auth().getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    };
    final dio.FormData formData = dio.FormData.fromMap({
      'businessName': businessUser.businessName!,
      'businessPhone': businessUser.businessPhone!,
      'description': businessUser.description!,
      'address': businessUser.address!,
      'tiktok': businessUser.tiktok!,
      'instagram': businessUser.instagram!,
      'youtube': businessUser.youtube!,
      'website': businessUser.website!,
    });
    if (selectedImage.value != null) {
      formData.files.add(
        MapEntry(
          'img',
          await dio.MultipartFile.fromFile(
            selectedImage.value!.path,
          ),
        ),
      );
    }
    try {
      final response = await _dio.post(
        '${authController.ipAddress.value}/mobile/updateBusiness/',
        data: formData,
        options: dio.Options(headers: headers),
      );
      if (response.statusCode == 200) {
        Get.back(result: true);
        showSnackBar('success', 'business_account_updated', ColorConstants.greenColor);
      } else {
        showSnackBar('error', '${'business_account_not_updated'} ${response.statusMessage}', ColorConstants.redColor);
      }
    } on dio.DioError catch (e) {
      Get.back(result: true);
      showSnackBar('error', '${'anErrorOccurred'} $e', ColorConstants.redColor);
    } finally {
      homeController.agreeButton.toggle();
    }
  }

  Future<void> deleteBusiness() async {
    final token = await Auth().getToken();
    final headers = {
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.delete(
        Uri.parse('${authController.ipAddress.value}/mobile/deleteBusiness/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        Get.back(result: true);
        Get.back(result: true);
        showSnackBar('success', 'deleted_success', ColorConstants.greenColor);
      } else {
        showSnackBar('error', 'anErrorOccurred'.tr + '${response.reasonPhrase}', ColorConstants.redColor);
      }
    } catch (e) {
      Get.back(result: true);
      showSnackBar('error', '${'anErrorOccurred'} $e', ColorConstants.redColor);
    } finally {}
  }

  Future<void> loadCategories() async {
    final result = await _categoryService.fetchCategories();
    if (result != null) {
      categories.value = result;
    }
  }

  Future<void> loadHashtags() async {
    final result = await _hashtagService.fetchHashtags();
    hashtags.value = result;
  }
}
