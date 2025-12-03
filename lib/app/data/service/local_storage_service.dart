import 'dart:convert';
import 'package:atelyam/app/data/models/banner_model.dart';
import 'package:atelyam/app/data/models/category_model.dart';
import 'package:atelyam/app/data/models/product_model.dart';
import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  final GetStorage _storage = GetStorage();

  // Keys for storage
  static const String _productsPrefix = 'products_';
  static const String _popularProductsKey = 'popular_products';
  static const String _myProductsKey = 'my_products';
  static const String _categoriesKey = 'categories';
  static const String _bannersKey = 'banners';
  static const String _lastSyncKey = 'last_sync_time';

  // Products
  Future<void> saveProducts(List<ProductModel> products, String key) async {
    try {
      final jsonList = products.map((p) => p.toJson()).toList();
      await _storage.write(_productsPrefix + key, jsonEncode(jsonList));
      await _updateLastSyncTime();
    } catch (e) {
      print('Error saving products: $e');
    }
  }

  List<ProductModel>? getProducts(String key) {
    try {
      final data = _storage.read(_productsPrefix + key);
      if (data == null) return null;

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print('Error reading products: $e');
      return null;
    }
  }

  // Popular Products
  Future<void> savePopularProducts(List<ProductModel> products) async {
    await saveProducts(products, _popularProductsKey.replaceAll(_productsPrefix, ''));
  }

  List<ProductModel>? getPopularProducts() {
    return getProducts(_popularProductsKey.replaceAll(_productsPrefix, ''));
  }

  // My Products
  Future<void> saveMyProducts(List<ProductModel> products) async {
    await saveProducts(products, _myProductsKey.replaceAll(_productsPrefix, ''));
  }

  List<ProductModel>? getMyProducts() {
    return getProducts(_myProductsKey.replaceAll(_productsPrefix, ''));
  }

  // Categories
  Future<void> saveCategories(List<Map<String, dynamic>> categoriesJson) async {
    try {
      await _storage.write(_categoriesKey, jsonEncode(categoriesJson));
      await _updateLastSyncTime();
    } catch (e) {
      print('Error saving categories: $e');
    }
  }

  List<CategoryModel>? getCategories() {
    try {
      final data = _storage.read(_categoriesKey);
      if (data == null) return null;

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      print('Error reading categories: $e');
      return null;
    }
  }

  // Banners
  Future<void> saveBanners(List<Map<String, dynamic>> bannersJson) async {
    try {
      await _storage.write(_bannersKey, jsonEncode(bannersJson));
      await _updateLastSyncTime();
    } catch (e) {
      print('Error saving banners: $e');
    }
  }

  List<BannerModel>? getBanners() {
    try {
      final data = _storage.read(_bannersKey);
      if (data == null) return null;

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => BannerModel.fromJson(json)).toList();
    } catch (e) {
      print('Error reading banners: $e');
      return null;
    }
  }

  // Utility methods
  Future<void> _updateLastSyncTime() async {
    await _storage.write(_lastSyncKey, DateTime.now().toIso8601String());
  }

  DateTime? getLastSyncTime() {
    final timeStr = _storage.read(_lastSyncKey);
    if (timeStr == null) return null;
    return DateTime.tryParse(timeStr);
  }

  Future<void> clearAll() async {
    await _storage.erase();
  }

  bool hasCache() {
    return _storage.read(_categoriesKey) != null;
  }
}
