// lib/app/data/services/hashtag_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:atelyam/app/data/models/hashtag_model.dart';
import 'package:atelyam/app/data/models/product_model.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HashtagService {
  final AuthController authController = Get.find();

  Future<List<HashtagModel>> fetchHashtags() async {
    final String url = '${authController.ipAddress.value}/mobile/hashtags/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<HashtagModel> hashtags = jsonData.map((item) => HashtagModel.fromJson(item)).toList();
        return hashtags;
      } else {
        _handleApiError(response.statusCode);
        return [];
      }
    } on SocketException {
      showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
      return [];
    } catch (e) {
      showSnackBar('unknownError'.tr, 'anErrorOccurred'.tr, Colors.red);
      return [];
    }
  }

  Future<List<ProductModel>> fetchProductsByHashtagId({
    required int hashtagId,
    int page = 1,
    int size = 20,
    String filter = 'last',
  }) async {
    try {
      final Uri uri = Uri.parse('${authController.ipAddress.value}/mobile/getProductByHashtag/$hashtagId/').replace(
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
          'filter': filter,
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = json.decode(responseBody);
        final List<dynamic> results = jsonData['results'];
        return results.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } on SocketException {
      showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
      return [];
    } catch (e) {
      showSnackBar('unknownError'.tr, 'anErrorOccurred'.tr, Colors.red);
      return [];
    }
  }

  void _handleApiError(int statusCode) {
    showSnackBar('apiError'.tr, 'anErrorOccurred'.tr, Colors.red);
  }
}
