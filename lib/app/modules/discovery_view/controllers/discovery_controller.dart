import 'package:atelyam/app/data/models/product_model.dart';
import 'package:atelyam/app/data/service/product_service.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DiscoveryController extends GetxController {
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);
  final List<ProductModel> products = <ProductModel>[].obs;
  int page = 1;
  final int size = 15;
  bool hasMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
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
      showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
    } finally {
      if (isRefresh) {
        refreshController.refreshCompleted();
      } else {
        refreshController.loadComplete();
      }
    }
  }

  void onRefresh() => fetchProducts(isRefresh: true);
  void onLoading() => fetchProducts();
}
