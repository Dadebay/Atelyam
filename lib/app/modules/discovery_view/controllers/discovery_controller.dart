import 'package:atelyam/app/data/models/product_model.dart';
import 'package:atelyam/app/data/service/product_service.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DiscoveryController extends GetxController {
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);
  final TextEditingController textEditingController = TextEditingController();
  final List<ProductModel> products = <ProductModel>[].obs;
  int page = 1;
  final int size = 15;
  bool hasMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  @override
  void onClose() {
    textEditingController.dispose();
    super.onClose();
  }

  Future<void> fetchProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      page = 1;
      hasMore = true;
      products.clear();
      refreshController.resetNoData();
    }

    if (!hasMore) {
      refreshController.loadNoData();
      return;
    }

    try {
      final newProducts =
          await ProductService().fetchPopularProducts(page: page, size: size);
      if (newProducts != null && newProducts.isNotEmpty) {
        products.addAll(newProducts);
        page++;
      } else {
        hasMore = false;
        refreshController.loadNoData();
      }
    } catch (e) {
      print(e);
      showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
    } finally {
      if (isRefresh) {
        refreshController.refreshCompleted();
      } else {
        refreshController.loadComplete();
      }
    }
  }

  Future<void> searchProducts(String name) async {
    if (name.isEmpty) {
      await fetchProducts(isRefresh: true);
      return;
    }
    try {
      final newProducts = await ProductService().searchProducts(name: name);
      if (newProducts != null && newProducts.isNotEmpty) {
        products.assignAll(newProducts);
        hasMore = true;
      } else {
        products.clear();
        hasMore = false;
      }
    } catch (e) {
      print(e);
      showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
    }
  }

  void clearSearch() {
    textEditingController.clear();
    fetchProducts(isRefresh: true);
  }

  void onRefresh() => fetchProducts(isRefresh: true);
  void onLoading() => fetchProducts();
}
