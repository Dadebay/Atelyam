//lib/app/data/service/banner_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:atelyam/app/data/models/banner_model.dart';
import 'package:atelyam/app/data/service/local_storage_service.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class BannerService {
  final String _apiEndpoint = '/mobile/banners/';
  final AuthController authController = Get.find();
  final LocalStorageService _localStorage = LocalStorageService();

  Future<List<BannerModel>> fetchBanners() async {
    try {
      final response = await http.get(Uri.parse(authController.ipAddress.value + _apiEndpoint));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        // Cache the raw JSON data
        await _localStorage.saveBanners(jsonList.cast<Map<String, dynamic>>());

        return jsonList.map((json) => BannerModel.fromJson(json)).toList();
      } else {
        // Try to return cached data
        final cached = _localStorage.getBanners();
        return cached ?? [];
      }
    } on SocketException {
      print('Offline: Loading banners from cache');
      final cached = _localStorage.getBanners();
      return cached ?? [];
    } catch (e) {
      print('Error fetching banners: $e');
      final cached = _localStorage.getBanners();
      return cached ?? [];
    }
  }

  Future<List<String>> fetchPhoneNumbers() async {
    final response = await http.get(Uri.parse(authController.ipAddress.value + '/mobile/getphones/'));

    print(authController.ipAddress.value + '/mobile/getphones/');
    print("response: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);

      if (jsonMap.containsKey('phones')) {
        return List<String>.from(jsonMap['phones']);
      } else {
        return [];
      }
    } else {
      return [];
    }
  }
}
