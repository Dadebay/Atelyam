import 'package:atelyam/app/data/models/product_model.dart';
import 'package:atelyam/app/data/service/hashtag_service.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CategoryController extends GetxController {
  RxList<ProductModel> allProducts = <ProductModel>[].obs;
  RxBool isLoadingProducts = false.obs;
  RxString activeFilter = 'last'.obs;
  RxInt currentPage = 1.obs;
  final RefreshController refreshController = RefreshController();
  RxBool isFilterExpanded = false.obs;
  Rx<FilterOption?> selectedFilter = Rx<FilterOption?>(FilterOption.last);

  void toggleFilterExpanded() {
    isFilterExpanded.toggle();
  }

  void setSelectedFilter(FilterOption? value) {
    selectedFilter.value = value;
  }

  void initializeProducts(int hashtagId) {
    isLoadingProducts.value = true;
    allProducts.clear();
    currentPage.value = 1;
    loadProducts(hashtagId);
  }

  Future<void> loadProducts(int hashtagId) async {
    try {
      final products = await HashtagService().fetchProductsByHashtagId(
        hashtagId: hashtagId,
        page: currentPage.value,
        size: 10,
        filter: activeFilter.value,
      );
      if (products.isNotEmpty) {
        allProducts.addAll(products);
      }
    } catch (e) {
    } finally {
      isLoadingProducts.value = false;
      refreshController.loadComplete();
    }
  }

  Future<void> refreshProducts(
    int hashtagId,
  ) async {
    isLoadingProducts.value = true;
    currentPage.value = 1;
    allProducts.clear();
    await loadProducts(hashtagId);
    refreshController.refreshCompleted();
  }

  Future<void> loadMoreProducts(int hashtagId) async {
    currentPage.value++;
    await loadProducts(hashtagId);
    refreshController.loadComplete();
  }
}
