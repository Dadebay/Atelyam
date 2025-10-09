// ignore_for_file: file_names, require_trailing_commas, avoid_void_async, avoid_bool_literals_in_conditional_expressions, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:atelyam/app/modules/home_view/views/bottom_nav_bar_view.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:http/http.dart' as http;

class Auth {
  final storage = GetStorage();

  void login(String? data) async {
    await storage.write('data', data);
  }

  Future<bool> logout() async {
    await storage.remove('AccessToken');
    await storage.remove('RefreshToken');
    return storage.read('AccessToken') == null ? true : false;
  }

  /////////////////////////////////////////User Token///////////////////////////////////
  Future<bool> setToken(String token) async {
    await storage.write('AccessToken', token);
    return storage.read('AccessToken') == null ? false : true;
  }

  Future<String?> getToken() async {
    return storage.read('AccessToken');
  }

  Future<bool> removeToken() async {
    await storage.remove('AccessToken');
    return storage.read('AccessToken') == null ? true : false;
  }

/////////////////////////////////////////User Refresh Token///////////////////////////////////

  Future<bool> setRefreshToken(String token) async {
    await storage.write('RefreshToken', token);
    return storage.read('AccessToken') == null ? false : true;
  }

  Future<String?> getRefreshToken() async {
    return storage.read('RefreshToken');
  }

  Future<bool> removeRefreshToken() async {
    await storage.remove('RefreshToken');
    return storage.read('RefreshToken') == null ? true : false;
  }
}

class SignInService {
  final AuthController authController = Get.find();

  final Auth _auth = Auth();

  Future<int?> otpCheck({required String phoneNumber, String? otp}) async {
    print(phoneNumber);
    print(otp);
    return _handleApiRequest(
      '/mobile/auth/',
      body: <String, dynamic>{
        'phone': phoneNumber,
        'otp': otp,
      },
      method: 'POST',
      requiresToken: true,
      isForm: true,
      handleSuccess: (responseJson) async {
        print(responseJson);
        _auth.login(responseJson['data']);
        await _auth.setToken(responseJson['access_token']);
        await _auth.setRefreshToken(responseJson['refresh']);
        return responseJson;
      },
    );
  }

  Future<int?> register({required String phoneNumber, required String name}) async {
    print(phoneNumber);
    print('REGISTER');
    final result = await _handleApiRequest(
      '/mobile/signup/',
      body: <String, dynamic>{
        'phone': phoneNumber,
        'user_name': name,
      },
      method: 'POST',
      requiresToken: false,
      handleSuccess: (responseJson) async {
        print(responseJson);

        return responseJson;
      },
      isForm: true,
    );

    return result;
  }

  Future<int?> login({required String phone}) async {
    print(phone);
    print('LOGIN-------------------');

    return _handleApiRequest(
      '/mobile/login/',
      body: <String, dynamic>{
        'phone': phone,
      },
      method: 'POST',
      requiresToken: false,
      handleSuccess: (responseJson) async {
        print(responseJson);

        return responseJson;
      },
      isForm: true,
    );
  }

  Future<int?> _handleApiRequest(
    String endpoint, {
    required Map<String, dynamic> body,
    required String method,
    required bool requiresToken,
    bool isForm = false,
    Future<dynamic> Function(dynamic)? handleSuccess,
  }) async {
    try {
      final token = await _auth.getToken();
      final uri = Uri.parse('${authController.ipAddress.value}$endpoint');
      late http.BaseRequest request;
      if (isForm) {
        request = http.MultipartRequest(method, uri);
        (request as http.MultipartRequest).fields.addAll(body.cast<String, String>());
      } else {
        request = http.Request(method, uri);
        if (body.isNotEmpty) {
          (request as http.Request).body = jsonEncode(body);
        }
      }

      request.headers.addAll(<String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        if (requiresToken && token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
      });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseJson = json.decode(responseBody);
      if (response.statusCode == 200) {
        if (handleSuccess != null) {
          await handleSuccess(responseJson);
        }
        return response.statusCode;
      } else {
        _handleApiError(response.statusCode, responseJson['message']?.toString() ?? 'anErrorOccurred'.tr);
        return response.statusCode;
      }
    } on SocketException {
      showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    } catch (e) {
      showSnackBar('unknownError'.tr, 'anErrorOccurred'.tr, Colors.red);
      return null;
    }
  }

  Future<void> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        await Future.delayed(const Duration(seconds: 3), () {
          Get.offAll(() => BottomNavBar());
        });
      }
    } on SocketException catch (_) {
      Dialogs().showNoConnectionDialog(() {
        checkConnection();
      });
    }
  }

  void _handleApiError(int statusCode, String message) {
    String errorMessage = 'anErrorOccurred'.tr;
    switch (statusCode) {
      case 400:
        errorMessage = 'invalidNumber'.tr;
        break;
      case 401:
        errorMessage = '${'unauthorized'.tr}: $message';
        break;
      case 404:
        errorMessage = '${'notFound'.tr}: $message';
        break;
      case 405:
        errorMessage = 'userDoesNotExist'.tr;
        break;
      case 500:
        errorMessage = '${'serverError'.tr}: $message';
        break;
      default:
        errorMessage = '${'errorStatus'.tr} $statusCode: $message';
    }
    if (statusCode == 409) {
    } else {
      showSnackBar('apiError'.tr, errorMessage, Colors.red);
    }
  }
}
