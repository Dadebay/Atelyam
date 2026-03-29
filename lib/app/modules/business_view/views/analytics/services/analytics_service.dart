import 'dart:convert';

import 'package:atelyam/app/data/service/auth_service.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/analytics_data.dart';

class AnalyticsService {
  final AuthController _authController = Get.find<AuthController>();
  final Auth _authService = Auth();

  String get _baseUrl => _authController.ipAddress.value;

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<AnalyticsData> getAnalyticsData() async {
    print('📊 FETCH ANALYTICS DATA REQUEST');

    final url = '$_baseUrl/mobile/analytics/';
    print('📊 URL: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    print('📊 Response Status: ${response.statusCode}');

    if (response.statusCode != 200) {
      print('❌ FETCH FAILED: Status ${response.statusCode}');
      throw Exception('fetch_analytics_data_failed');
    }

    final decoded = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    print('✅ Analytics data fetched successfully');

    return AnalyticsData.fromJson(decoded);
  }
}
