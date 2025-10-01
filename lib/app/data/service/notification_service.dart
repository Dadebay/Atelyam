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

  Future<void> sendDeviceToken() async {
    final String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      final String? storedToken = _storage.read('fcm_token');
      if (storedToken != token) {
        try {
          print('FCM Token: $token');
          final response = await http.post(
            Uri.parse('http://216.250.12.49:8000/notifications/deviceid/'),
            headers: {HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8'},
            body: jsonEncode(<String, String>{'device_id': token}),
          );
          print('Response: ${response.body}');
          if (response.statusCode == 201 || response.statusCode == 200) {
            await _storage.write('fcm_token', token);
            print('FCM token sent successfully');
          } else {
            print('Failed to send FCM token. Status code: ${response.statusCode}');
          }
        } catch (e) {
          print('Error sending FCM token: $e');
        }
      }
    }
  }
}
