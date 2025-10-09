//lib/app/data/service/banner_service.dart
import 'dart:convert';

import 'package:atelyam/app/data/models/banner_model.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class BannerService {
  final String _apiEndpoint = '/mobile/banners/';
  final AuthController authController = Get.find();
  Future<List<BannerModel>> fetchBanners() async {
    final response = await http.get(Uri.parse(authController.ipAddress.value + _apiEndpoint));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => BannerModel.fromJson(json)).toList();
    } else {
      showSnackBar('networkError'.tr, 'noInternet'.tr, ColorConstants.redColor);
      return [];
    }
  }
}
