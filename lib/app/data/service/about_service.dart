//lib/app/data/service/about_service.dart
import 'dart:convert';

import 'package:atelyam/app/data/models/about_model.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AboutService {
  final AuthController authController = Get.find();
  final String _apiEndpoint = '/mobile/about/';

  Future<AboutModel> fetchAboutData() async {
    final response = await http.get(Uri.parse(authController.ipAddress.value + _apiEndpoint));

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = json.decode(responseBody);
      if (jsonList.isNotEmpty) {
        final List<AboutModel> all = jsonList.map((e) => AboutModel.fromJson(e as Map<String, dynamic>)).toList();
        final String langCode = GetStorage().read('langCode') ?? Get.locale?.languageCode ?? 'tm';
        return AboutModel.forLanguage(all, langCode) ?? all.first;
      } else {
        throw Exception('No data found.');
      }
    } else {
      throw Exception('Failed to fetch about data');
    }
  }
}
