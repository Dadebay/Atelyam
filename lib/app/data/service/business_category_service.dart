// lib/app/data/services/category_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:atelyam/app/data/models/business_category_model.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class BusinessCategoryService {
  final AuthController authController = Get.find();

  Future<List<BusinessCategoryModel>?> fetchCategories() async {
    try {
      final uri = Uri.parse('${authController.ipAddress.value}/mobile/cats/');
      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8', //Setting header explicitly
        },
      );
      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes); // Force UTF-8 decoding
        final List<dynamic> responseData = json.decode(responseBody);
        final List<BusinessCategoryModel> categories = responseData.map((json) => BusinessCategoryModel.fromJson(json)).toList();
        return categories;
      } else {
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
}
