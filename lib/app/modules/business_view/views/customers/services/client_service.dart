import 'dart:convert';

import 'package:atelyam/app/data/service/auth_service.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/client_model.dart';
import '../models/measurement_type.dart';

class ClientService {
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

  Future<List<ClientModel>> fetchClients() async {
    print('🔷 FETCH CLIENTS REQUEST');
    print('🔷 URL: $_baseUrl/mobile/clients/');

    final response = await http.get(
      Uri.parse('$_baseUrl/mobile/clients/'),
      headers: await _headers(),
    );

    print('🔷 Response Status: ${response.statusCode}');

    if (response.statusCode != 200) {
      print('❌ FETCH FAILED: Status ${response.statusCode}');
      throw Exception('fetch_clients_failed');
    }

    final dynamic decoded = json.decode(utf8.decode(response.bodyBytes));
    if (decoded is Map<String, dynamic>) {
      final List<dynamic> results = decoded['results'] as List<dynamic>? ?? <dynamic>[];
      print('✅ Fetched ${results.length} clients');
      return results.whereType<Map<String, dynamic>>().map(ClientModel.fromJson).toList();
    }

    if (decoded is List<dynamic>) {
      print('✅ Fetched ${decoded.length} clients');
      return decoded.whereType<Map<String, dynamic>>().map(ClientModel.fromJson).toList();
    }

    print('✅ Fetched 0 clients (empty response)');
    return <ClientModel>[];
  }

  Future<List<MeasurementType>> fetchMeasurementTypes() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/mobile/getvalues/'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('fetch_measurement_types_failed');
    }

    final dynamic decoded = json.decode(utf8.decode(response.bodyBytes));
    if (decoded is! List<dynamic>) return <MeasurementType>[];

    return decoded.whereType<Map<String, dynamic>>().map(MeasurementType.fromJson).toList();
  }

  Future<ClientModel> createClient({
    required String name,
    required String phone,
    required List<Map<String, dynamic>> measurements,
  }) async {
    final Map<String, dynamic> requestBody = <String, dynamic>{
      'name': name,
      'phone': phone,
      'new_measurements': measurements,
    };

    print('🔷 CREATE CLIENT REQUEST');
    print('🔷 URL: $_baseUrl/mobile/clients/');
    print('🔷 Body: ${json.encode(requestBody)}');

    final response = await http.post(
      Uri.parse('$_baseUrl/mobile/clients/'),
      headers: await _headers(),
      body: json.encode(requestBody),
    );

    print('🔷 Response Status: ${response.statusCode}');
    print('🔷 Response Body: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode != 201) {
      print('❌ CREATE FAILED: Status ${response.statusCode}');
      throw Exception('create_client_failed: ${response.statusCode}');
    }

    print('✅ Client created successfully');
    return ClientModel.fromJson(
      json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<ClientModel> updateClient({
    required int id,
    required String name,
    required String phone,
    List<Map<String, dynamic>>? newMeasurements,
  }) async {
    final Map<String, dynamic> requestBody = <String, dynamic>{
      'name': name,
      'phone': phone,
    };

    if (newMeasurements != null && newMeasurements.isNotEmpty) {
      requestBody['new_measurements'] = newMeasurements;
    }

    print('🔷 UPDATE CLIENT REQUEST - ID: $id');
    print('🔷 URL: $_baseUrl/mobile/clients/$id/');
    print('🔷 Body: ${json.encode(requestBody)}');

    final response = await http.put(
      Uri.parse('$_baseUrl/mobile/clients/$id/'),
      headers: await _headers(),
      body: json.encode(requestBody),
    );

    print('🔷 Response Status: ${response.statusCode}');
    print('🔷 Response Body: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode != 200) {
      print('❌ UPDATE FAILED: Status ${response.statusCode}');
      throw Exception('update_client_failed: ${response.statusCode}');
    }

    print('✅ Client updated successfully');
    return ClientModel.fromJson(
      json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<void> deleteClient(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/mobile/clients/$id/'),
      headers: await _headers(),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('delete_client_failed');
    }
  }
}
