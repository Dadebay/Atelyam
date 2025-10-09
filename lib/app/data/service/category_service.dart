import 'dart:convert';

import 'package:atelyam/app/data/models/category_model.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  final AuthController authController = Get.find();
  Future<List<CategoryModel>> fetchCategories() async {
    final String url = '${authController.ipAddress.value}/mobile/hashtags/';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes); // Force UTF-8 decoding

      final List<dynamic> jsonData = json.decode(responseBody);
      final List<CategoryModel> categories = jsonData.map((item) => CategoryModel.fromJson(item)).toList();
      return categories;
    } else {
      showSnackBar('networkError'.tr, 'noInternet'.tr, ColorConstants.redColor);
      return [];
    }
  }
}
