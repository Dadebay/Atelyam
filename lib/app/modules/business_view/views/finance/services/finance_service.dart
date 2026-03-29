import 'dart:convert';

import 'package:atelyam/app/data/service/auth_service.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/expense_model.dart';
import '../models/finance_data.dart';
import '../models/outstanding_customer_model.dart';

class FinanceService {
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

  /// Fetch finance data (income, expenses, net profit, outstanding, recent expenses)
  Future<FinanceData> getFinanceData({String? period}) async {
    print('🔷 FETCH FINANCE DATA REQUEST');

    String url = '$_baseUrl/mobile/get_finance_data/';
    if (period != null && period.isNotEmpty) {
      url += '?filter=$period';
    }

    print('🔷 URL: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    print('🔷 Response Status: ${response.statusCode}');

    if (response.statusCode != 200) {
      print('❌ FETCH FAILED: Status ${response.statusCode}');
      throw Exception('fetch_finance_data_failed');
    }

    final decoded = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    print('✅ Finance data fetched successfully');

    return FinanceData.fromJson(decoded);
  }

  /// Create a new expense
  Future<ExpenseModel> createExpense({
    required String title,
    required String category,
    required double amount,
    required int categoryUserId, // API'nin beklediği alan
  }) async {
    print('🔷 CREATE EXPENSE REQUEST');
    print('🔷 URL: $_baseUrl/mobile/expenses/');
    print('🔷 Title: $title, Category: $category, Amount: $amount, CategoryUser: $categoryUserId');

    final headers = await _headers();
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/mobile/expenses/'));
    request.headers.addAll(headers);

    request.fields['title'] = title;
    request.fields['category'] = category;
    request.fields['amount'] = amount.toString();
    request.fields['categoryuser'] = categoryUserId.toString();

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('🔷 Response Status: ${response.statusCode}');
    print('🔷 Response Body: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode != 201) {
      print('❌ CREATE FAILED: Status ${response.statusCode}');
      throw Exception('create_expense_failed: ${response.statusCode}');
    }

    print('✅ Expense created successfully');
    return ExpenseModel.fromJson(
      json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  /// Delete an expense
  Future<void> deleteExpense(int expenseId) async {
    print('🔷 DELETE EXPENSE REQUEST');
    print('🔷 URL: $_baseUrl/mobile/expenses/$expenseId/');

    final response = await http.delete(
      Uri.parse('$_baseUrl/mobile/expenses/$expenseId/'),
      headers: await _headers(),
    );

    print('🔷 Response Status: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      print('❌ DELETE FAILED: Status ${response.statusCode}');
      throw Exception('delete_expense_failed');
    }

    print('✅ Expense deleted successfully');
  }

  /// Fetch outstanding customer list
  Future<List<OutstandingCustomer>> getOutstandingCustomers() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/mobile/outstanding/'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('fetch_outstanding_failed');
    }

    final body = utf8.decode(response.bodyBytes);
    final dynamic decoded = json.decode(body);
    final customers = _extractOutstandingList(decoded).whereType<Map<String, dynamic>>().map(OutstandingCustomer.fromJson).where((c) => c.outstanding > 0).toList();

    print('✅ Outstanding customers fetched: ${customers.length}');
    return customers;
  }

  List<dynamic> _extractOutstandingList(dynamic decoded) {
    if (decoded is List<dynamic>) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final candidates = <dynamic>[
        decoded['results'],
        decoded['data'],
        decoded['customers'],
        decoded['outstanding_customers'],
        decoded['items'],
        decoded['outstanding'],
      ];

      for (final candidate in candidates) {
        if (candidate is List<dynamic>) {
          return candidate;
        }
        if (candidate is Map<String, dynamic>) {
          final nested = _extractOutstandingList(candidate);
          if (nested.isNotEmpty) {
            return nested;
          }
        }
      }
    }

    return <dynamic>[];
  }
}
