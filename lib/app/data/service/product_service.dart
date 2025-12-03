// lib/app/data/services/product_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:atelyam/app/data/models/product_model.dart';
import 'package:atelyam/app/data/service/auth_service.dart';
import 'package:atelyam/app/data/service/local_storage_service.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../modules/auth_view/controllers/auth_controller.dart';

class ProductService {
  final AuthController authController = Get.find();
  final http.Client _client = http.Client();
  final Auth _auth = Auth();
  final LocalStorageService _localStorage = LocalStorageService();

  Future<List<ProductModel>?> fetchProducts(int categoryId, int userId) async {
    final cacheKey = '${categoryId}_$userId';

    try {
      List<ProductModel> allProducts = [];
      int page = 1;
      bool hasMore = true;

      while (hasMore) {
        final response = await _client.get(
          Uri.parse(
            '${authController.ipAddress.value}/mobile/products/$categoryId/$userId/?page=$page',
          ),
        );
        if (response.statusCode == 200) {
          final responseBody = utf8.decode(response.bodyBytes);
          final jsonData = json.decode(responseBody);

          // Check if response is a list or has results key
          List<dynamic> data;
          if (jsonData is List) {
            data = jsonData;
            hasMore = false; // If it's a list, no pagination
          } else if (jsonData is Map && jsonData.containsKey('results')) {
            data = jsonData['results'];
            hasMore = jsonData['next'] != null;
          } else {
            hasMore = false;
            break;
          }

          if (data.isEmpty) {
            hasMore = false;
          } else {
            allProducts.addAll(data.map((json) => ProductModel.fromJson(json)).toList());
            page++;
          }
        } else {
          _handleApiError(response.statusCode);
          hasMore = false;
        }
      }

      // Cache successful response
      if (allProducts.isNotEmpty) {
        await _localStorage.saveProducts(allProducts, cacheKey);
      }

      return allProducts.isNotEmpty ? allProducts : null;
    } on SocketException {
      // Return cached data when offline
      print('Offline: Loading products from cache');
      return _localStorage.getProducts(cacheKey);
    } catch (e) {
      print(e);
      // Try to return cached data on error
      return _localStorage.getProducts(cacheKey);
    }
  }

  Future<List<ProductModel>?> fetchPopularProductsByUserID(int userId) async {
    print(userId);
    final cacheKey = 'user_$userId';

    try {
      List<ProductModel> allProducts = [];
      int page = 1;
      bool hasMore = true;

      while (hasMore) {
        final response = await _client.get(
          Uri.parse(
            '${authController.ipAddress.value}/mobile/getProduct/$userId/?page=$page',
          ),
        );
        print(response.body);
        print(response.statusCode);
        if (response.statusCode == 200) {
          final responseBody = utf8.decode(response.bodyBytes);
          final jsonData = json.decode(responseBody);
          final List<dynamic> data = jsonData['results'];

          if (data.isEmpty) {
            hasMore = false;
          } else {
            allProducts.addAll(data.map((json) => ProductModel.fromJson(json)).toList());

            // Check if there's a next page
            hasMore = jsonData['next'] != null;
            page++;
          }
        } else {
          hasMore = false;
        }
      }

      // Cache successful response
      if (allProducts.isNotEmpty) {
        await _localStorage.saveProducts(allProducts, cacheKey);
      }

      return allProducts.isNotEmpty ? allProducts : null;
    } on SocketException catch (e) {
      print(e);
      print('Offline: Loading user products from cache');
      return _localStorage.getProducts(cacheKey);
    } catch (e) {
      print(e);
      return _localStorage.getProducts(cacheKey);
    }
  }

  Future<List<ProductModel>?> getMyProducts() async {
    try {
      final token = await _auth.getToken();
      final uri = Uri.parse('${authController.ipAddress.value}/mobile/GetMyProducts/');
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
        final List<ProductModel> products = data.map((json) => ProductModel.fromJson(json)).toList();

        // Cache my products
        await _localStorage.saveMyProducts(products);

        return products;
      } else {
        return [];
      }
    } on SocketException catch (e) {
      print(e);
      print('Offline: Loading my products from cache');
      return _localStorage.getMyProducts();
    } catch (e) {
      print(e);
      return _localStorage.getMyProducts();
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
        final products = results.map((json) => ProductModel.fromJson(json)).toList();

        // Cache popular products (only first page)
        if (page == 1) {
          await _localStorage.savePopularProducts(products);
        }

        return products;
      } else {
        return null;
      }
    } on SocketException catch (e) {
      print(e);
      print('Offline: Loading popular products from cache');
      return _localStorage.getPopularProducts();
    } catch (e) {
      print(e);
      return _localStorage.getPopularProducts();
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
