import 'dart:convert';
import 'dart:io';

import 'package:atelyam/app/data/service/auth_service.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/order_item.dart';

class OrderService {
  final AuthController _authController = Get.find<AuthController>();
  final Auth _authService = Auth();

  String get _baseUrl => _authController.ipAddress.value;

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return <String, String>{
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<OrderItem>> fetchOrders() async {
    print('🔷 FETCH ORDERS REQUEST');
    print('🔷 URL: $_baseUrl/mobile/orders/');

    final response = await http.get(
      Uri.parse('$_baseUrl/mobile/orders/'),
      headers: await _headers(),
    );

    print('🔷 Response Status: ${response.statusCode}');

    if (response.statusCode != 200) {
      print('❌ FETCH FAILED: Status ${response.statusCode}');
      throw Exception('fetch_orders_failed');
    }

    final dynamic decoded = json.decode(utf8.decode(response.bodyBytes));

    if (decoded is Map<String, dynamic>) {
      final List<dynamic> results = decoded['results'] as List<dynamic>? ?? <dynamic>[];
      print('✅ Fetched ${results.length} orders');
      return results.whereType<Map<String, dynamic>>().map(OrderItem.fromJson).toList();
    }

    if (decoded is List<dynamic>) {
      print('✅ Fetched ${decoded.length} orders');
      return decoded.whereType<Map<String, dynamic>>().map(OrderItem.fromJson).toList();
    }

    print('✅ Fetched 0 orders (empty response)');
    return <OrderItem>[];
  }

  Future<OrderItem> createOrder({
    required int clientId,
    required String orderName,
    required String price,
    required String due,
    required String status,
    File? image,
  }) async {
    print('🔷 CREATE ORDER REQUEST');
    print('🔷 URL: $_baseUrl/mobile/orders/');
    print('🔷 Client: $clientId, Name: $orderName, Price: $price, Due: $due, Status: $status');

    final headers = await _headers();
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/mobile/orders/'));
    request.headers.addAll(headers);

    request.fields['client'] = clientId.toString();
    request.fields['order_name'] = orderName;
    request.fields['price'] = price;
    request.fields['due'] = due;
    request.fields['status'] = status;

    if (image != null) {
      print('🔷 Adding image: ${image.path}');
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('🔷 Response Status: ${response.statusCode}');
    print('🔷 Response Body: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode != 201) {
      print('❌ CREATE FAILED: Status ${response.statusCode}');
      throw Exception('create_order_failed: ${response.statusCode}');
    }

    print('✅ Order created successfully');
    return OrderItem.fromJson(
      json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<OrderItem> updateOrder({
    required int id,
    required int clientId,
    required String orderName,
    required String price,
    required String due,
    required String status,
    File? image,
  }) async {
    print('🔷 UPDATE ORDER REQUEST - ID: $id');
    print('🔷 URL: $_baseUrl/mobile/orders/$id/');

    final headers = await _headers();
    final request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl/mobile/orders/$id/'));
    request.headers.addAll(headers);

    request.fields['client'] = clientId.toString();
    request.fields['order_name'] = orderName;
    request.fields['price'] = price;
    request.fields['due'] = due;
    request.fields['status'] = status;

    if (image != null) {
      print('🔷 Updating image: ${image.path}');
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('🔷 Response Status: ${response.statusCode}');
    print('🔷 Response Body: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode != 200) {
      print('❌ UPDATE FAILED: Status ${response.statusCode}');
      throw Exception('update_order_failed: ${response.statusCode}');
    }

    print('✅ Order updated successfully');
    return OrderItem.fromJson(
      json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<void> deleteOrder(int id) async {
    print('🔷 DELETE ORDER REQUEST - ID: $id');
    print('🔷 URL: $_baseUrl/mobile/orders/$id/');

    final response = await http.delete(
      Uri.parse('$_baseUrl/mobile/orders/$id/'),
      headers: await _headers(),
    );

    print('🔷 Response Status: ${response.statusCode}');

    if (response.statusCode != 204 && response.statusCode != 200) {
      print('❌ DELETE FAILED: Status ${response.statusCode}');
      throw Exception('delete_order_failed');
    }

    print('✅ Order deleted successfully');
  }
}
