import 'dart:convert';
import 'dart:io';

import 'package:atelyam/app/data/service/auth_service.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final GetStorage _storage = GetStorage();
  final AuthController authController = Get.find();

  static const String deviceIdEndpoint = '/notifications/deviceid/';

  Future<void> sendDeviceToken({bool force = false}) async {
    final Auth _auth = Auth();

    try {
      final String? token = await FirebaseMessaging.instance.getToken();
      final String? bearerToken = await _auth.getToken();

      if (token != null) {
        try {
          final response = await http.post(
            Uri.parse('${authController.ipAddress.value}${deviceIdEndpoint}'),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
              HttpHeaders.authorizationHeader: 'Bearer $bearerToken',
            },
            body: jsonEncode(<String, String>{'device_id': token}),
          );
          if (response.statusCode == 201 || response.statusCode == 200) {
            await _storage.write('fcm_token', token);
          }
        } catch (e) {
          print('❌ POST hatası: $e');
        }
      }
    } catch (e) {
      print('❌ sendDeviceToken hatası: $e');
    }
  }
}
