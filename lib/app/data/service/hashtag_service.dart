// lib/app/data/services/hashtag_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:atelyam/app/data/models/hashtag_model.dart';
import 'package:atelyam/app/data/models/product_model.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class HashtagService {
  final AuthController authController = Get.find();

  Future<List<HashtagModel>> fetchHashtags() async {
    final String url = '${authController.ipAddress.value}/mobile/hashtags/';
    const String cacheKey = 'hashtags_list';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<HashtagModel> hashtags = jsonData.map((item) => HashtagModel.fromJson(item)).toList();

        // Cache the results
        final storage = GetStorage();
        await storage.write(cacheKey, jsonEncode(jsonData));

        return hashtags;
      } else {
        _handleApiError(response.statusCode);
        return _loadHashtagsFromCache(cacheKey);
      }
    } on SocketException {
      // Offline - try to load from cache
      print('Offline mode - loading hashtags from cache');
      return _loadHashtagsFromCache(cacheKey);
    } catch (e) {
      print('Error fetching hashtags: $e');
      return _loadHashtagsFromCache(cacheKey);
    }
  }

  List<HashtagModel> _loadHashtagsFromCache(String cacheKey) {
    try {
      final storage = GetStorage();
      final cachedData = storage.read(cacheKey);
      if (cachedData != null) {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        print('Loaded ${jsonList.length} hashtags from cache');
        return jsonList.map((item) => HashtagModel.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading hashtags from cache: $e');
    }
    return [];
  }

  Future<List<ProductModel>> fetchProductsByHashtagId({
    required int hashtagId,
    int page = 1,
    int size = 20,
    String filter = 'last',
  }) async {
    final String cacheKey = 'hashtag_${hashtagId}_${filter}';

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
        final products = results.map((item) => ProductModel.fromJson(item)).toList();

        // Cache the results
        final storage = GetStorage();
        await storage.write(cacheKey, jsonEncode(results));

        return products;
      } else {
        return _loadFromCache(cacheKey);
      }
    } on SocketException {
      // Offline - try to load from cache
      print('Offline mode - loading hashtag products from cache');
      return _loadFromCache(cacheKey);
    } catch (e) {
      print('Error fetching hashtag products: $e');
      return _loadFromCache(cacheKey);
    }
  }

  List<ProductModel> _loadFromCache(String cacheKey) {
    try {
      final storage = GetStorage();
      final cachedData = storage.read(cacheKey);
      if (cachedData != null) {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        print('Loaded ${jsonList.length} products from cache for key: $cacheKey');
        return jsonList.map((item) => ProductModel.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading from cache: $e');
    }
    return [];
  }

  void _handleApiError(int statusCode) {
    showSnackBar('apiError'.tr, 'anErrorOccurred'.tr, Colors.red);
  }
}
