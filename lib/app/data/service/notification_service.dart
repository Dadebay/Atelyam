import 'dart:convert';
import 'dart:io';

import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final GetStorage _storage = GetStorage();
  final AuthController authController = Get.find();

  static const String baseUrl = 'http://216.250.12.49:8000';
  static const String deviceIdEndpoint = '/notifications/deviceid/';

  Future<void> sendDeviceToken() async {
    try {
      final String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final String? storedToken = _storage.read('fcm_token');
        if (storedToken != token) {
          try {
            print('FCM Token: $token');
            final response = await http.post(
              Uri.parse('${baseUrl}${deviceIdEndpoint}'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8'
              },
              body: jsonEncode(<String, String>{'device_id': token}),
            );
            if (response.statusCode == 201 || response.statusCode == 200) {
              await _storage.write('fcm_token', token);
              print('FCM token sent successfully');
            } else {
              print(
                'Failed to send FCM token. Status code: ${response.statusCode}',
              );
            }
          } catch (e) {
            print('Error sending FCM token: $e');
          }
        }
      }
    } catch (e) {
      print('Error getting FCM token: $e');
      // Release modda emulator baglanyşygy ýok bolsa, app crash etmez
    }
  }
}
