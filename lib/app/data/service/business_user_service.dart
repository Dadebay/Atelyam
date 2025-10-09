// lib/app/data/services/business_user_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/data/service/auth_service.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class BusinessUserService {
  final AuthController authController = Get.find();

  Future<List<BusinessUserModel>?> getBusinessAccountsByCategory({required int categoryID}) async {
    final url = Uri.parse('${authController.ipAddress.value}/mobile/cats_id/$categoryID/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);

        final List<dynamic> decodedJson = jsonDecode(responseBody);
        final List<BusinessUserModel> responseData = decodedJson.map((json) => BusinessUserModel.fromJson(json as Map<String, dynamic>)).toList();
        return responseData;
      } else {
        return null;
      }
    } on SocketException {
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<BusinessUserModel?> fetchBusinessAccountByID(int id) async {
    final url = Uri.parse('${authController.ipAddress.value}/mobile/GetUserId/$id/');
    print(url);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return BusinessUserModel.fromJson(json.decode(response.body));
      } else {
        _handleApiError(response.statusCode);
        return null;
      }
    } on SocketException {
      showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    } catch (e) {
      showSnackBar('unknownError'.tr, 'anErrorOccurred'.tr, Colors.red);
      return null;
    }
  }

  Future<BusinessUserModel?> fetchBusinessAccountKICI(int id) async {
    final url = Uri.parse('${authController.ipAddress.value}/mobile/getUserById/$id/');
    print(url);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print(json.decode(response.body)[0]);
        return BusinessUserModel.fromJson(json.decode(response.body)[0]);
      } else {
        _handleApiError(response.statusCode);
        return null;
      }
    } on SocketException {
      showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    } catch (e) {
      showSnackBar('unknownError'.tr, 'anErrorOccurred'.tr, Colors.red);
      return null;
    }
  }

  Future<List<BusinessUserModel>?> fetchPopularBusinessAccounts() async {
    try {
      final uri = Uri.parse('${authController.ipAddress.value}/mobile/getPopular/');
      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> responseData = json.decode(responseBody);
        final List<BusinessUserModel> categories = responseData.map((json) => BusinessUserModel.fromJson(json)).toList();
        return categories;
      } else {
        return null;
      }
    } on SocketException {
      return null;
    } catch (e) {
      return null;
    }
  }

  final String getMyStatusEndpoint = '/getMyStatus/';

  Future<List<GetMyStatusModel>?> getMyStatus() async {
    final url = Uri.parse('${authController.ipAddress.value}/mobile' + getMyStatusEndpoint);
    final token = await Auth().getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => GetMyStatusModel.fromJson(json)).toList();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void _handleApiError(int statusCode) {
    showSnackBar('apiError'.tr, 'anErrorOccurred'.tr, Colors.red);
  }
}
