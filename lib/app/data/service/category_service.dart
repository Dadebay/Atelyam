import 'dart:convert';
import 'dart:io';

import 'package:atelyam/app/data/models/category_model.dart';
import 'package:atelyam/app/data/service/local_storage_service.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  final AuthController authController = Get.find();
  final LocalStorageService _localStorage = LocalStorageService();

  Future<List<CategoryModel>> fetchCategories() async {
    final String url = '${authController.ipAddress.value}/mobile/hashtags/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes); // Force UTF-8 decoding

        final List<dynamic> jsonData = json.decode(responseBody);

        // Cache the raw JSON data
        await _localStorage.saveCategories(jsonData.cast<Map<String, dynamic>>());

        final List<CategoryModel> categories = jsonData.map((item) => CategoryModel.fromJson(item)).toList();
        return categories;
      } else {
        // Try to return cached data
        final cached = _localStorage.getCategories();
        return cached ?? [];
      }
    } on SocketException {
      print('Offline: Loading categories from cache');
      final cached = _localStorage.getCategories();
      return cached ?? [];
    } catch (e) {
      print('Error fetching categories: $e');
      final cached = _localStorage.getCategories();
      return cached ?? [];
    }
  }
}
