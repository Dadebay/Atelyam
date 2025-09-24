// lib/app/data/services/image_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:atelyam/app/data/models/images_model.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class ImageService {
  final AuthController authController = Get.find();
  final http.Client _client = http.Client();

  Future<ImageModel?> fetchImageByProductID(int productId) async {
    try {
      final response = await _client.get(
        Uri.parse('${authController.ipAddress.value}/mobile/images/$productId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(data);
        if (data.isNotEmpty) {
          return ImageModel.fromJson(data[0]);
        }
        return ImageModel(id: 0, images: [], product: 0);
      } else {
        _handleApiError(response.statusCode);
        return null;
      }
    } on SocketException {
      showSnackBar('networkError'.tr, 'noInternet'.tr, ColorConstants.redColor);
      return null;
    } catch (e) {
      showSnackBar('unknownError'.tr, 'anErrorOccurred'.tr, ColorConstants.redColor);
      return null;
    }
  }

  Future<ProductModel?> fetchProductById(int productId) async {
    String? deviceToken = '';
    if (Platform.isIOS) {
      deviceToken = await FirebaseMessaging.instance.getAPNSToken();
    } else if (Platform.isAndroid) {
      deviceToken = await FirebaseMessaging.instance.getToken();
    } else {}

    if (deviceToken == null || deviceToken.isEmpty) {
      debugPrint('Failed to get device token.');
      deviceToken = 'unknown_device'; // Or provide a default value.
    }
    try {
      final response = await _client.get(
        Uri.parse(
          '${authController.ipAddress.value}/mobile/product/$productId?device=$deviceToken',
        ),
      );
      if (response.statusCode == 200) {
        return ProductModel.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } on SocketException {
      return null;
    } catch (e) {
      return null;
    }
  }

  void _handleApiError(int statusCode) {
    showSnackBar('apiError'.tr, 'anErrorOccurred'.tr, Colors.red);
  }
}
