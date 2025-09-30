// lib/app/data/services/product_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:atelyam/app/data/models/product_model.dart';
import 'package:atelyam/app/data/service/auth_service.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../modules/auth_view/controllers/auth_controller.dart';

class ProductService {
  final AuthController authController = Get.find();
  final http.Client _client = http.Client();
  final Auth _auth = Auth();

  Future<List<ProductModel>?> fetchProducts(int categoryId, int userId) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '${authController.ipAddress.value}/mobile/products/$categoryId/$userId/',
        ),
      );
      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(responseBody);
        final List<ProductModel> products =
            data.map((json) => ProductModel.fromJson(json)).toList();
        return products;
      } else {
        _handleApiError(response.statusCode);
        return null;
      }
    } on SocketException {
      return null;
    } catch (e) {
      print(e);
      showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);

      return null;
    }
  }

  Future<List<ProductModel>?> fetchPopularProductsByUserID(int userId) async {
    print(userId);
    try {
      final response = await _client.get(
        Uri.parse(
          '${authController.ipAddress.value}/mobile/getProduct/$userId/',
        ),
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(responseBody)['results'];
        final List<ProductModel> products =
            data.map((json) => ProductModel.fromJson(json)).toList();
        return products;
      } else {
        return null;
      }
    } on SocketException catch (e) {
      print(e);
      showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    } catch (e) {
      print(e);
      showSnackBar('unknownError'.tr, 'anErrorOccurred'.tr, Colors.red);
      return null;
    }
  }

  Future<List<ProductModel>?> getMyProducts() async {
    try {
      final token = await _auth.getToken();
      final uri =
          Uri.parse('${authController.ipAddress.value}/mobile/GetMyProducts/');
      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(responseBody);
        final List<ProductModel> products =
            data.map((json) => ProductModel.fromJson(json)).toList();
        return products;
      } else {
        return [];
      }
    } on SocketException catch (e) {
      print(e);
      showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    } catch (e) {
      print(e);
      showSnackBar('unknownError'.tr, 'anErrorOccurred'.tr, Colors.red);
      return null;
    }
  }

  Future<List<ProductModel>?> fetchPopularProducts({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '${authController.ipAddress.value}/mobile/getProductsPopular/?page=$page&size=$size',
        ),
      );
      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(responseBody);
        final List<dynamic> results = data['results'];
        return results.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        return null;
      }
    } on SocketException catch (e) {
      print(e);
      showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    } catch (e) {
      print(e);
      showSnackBar('unknownError'.tr, 'anErrorOccurred'.tr, Colors.red);
      return null;
    }
  }

  Future<List<ProductModel>?> searchProducts({required String name}) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '${authController.ipAddress.value}/mobile/search/?name=$name',
        ),
      );
      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(responseBody);
        final List<dynamic> results = data['results'];
        return results.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        return null;
      }
    } on SocketException catch (e) {
      print(e);
      showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    } catch (e) {
      print(e);

      return null;
    }
  }

  void _handleApiError(int statusCode) {
    print('Api Error: $statusCode');
    showSnackBar('apiError'.tr, 'anErrorOccurred'.tr, Colors.red);
  }
}
