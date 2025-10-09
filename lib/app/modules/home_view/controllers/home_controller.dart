import 'package:atelyam/app/data/models/banner_model.dart';
import 'package:atelyam/app/data/models/business_category_model.dart';
import 'package:atelyam/app/data/models/hashtag_model.dart';
import 'package:atelyam/app/data/models/product_model.dart';
import 'package:atelyam/app/data/service/banner_service.dart';
import 'package:atelyam/app/data/service/business_category_service.dart';
import 'package:atelyam/app/data/service/hashtag_service.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeController extends GetxController {
  RxString activeFilter = 'last'.obs;
  RxBool agreeButton = false.obs;
  RxInt selectedIndex = 0.obs;
  RxInt carouselSelectedIndex = 0.obs;
  RxInt currentPage = 1.obs;
  RxBool isFilterExpanded = false.obs;
  RxBool isLoadingProducts = false.obs;
  final RefreshController refreshController = RefreshController();
  RxList<ProductModel> allProducts = <ProductModel>[].obs;
  RxMap<int, Future<List<ProductModel>>> productsFutures =
      <int, Future<List<ProductModel>>>{}.obs;
  Rx<FilterOption?> selectedFilter = Rx<FilterOption?>(FilterOption.last);
  late Rx<Future<List<BannerModel>>> bannersFuture;
  late Rx<Future<List<BusinessCategoryModel>?>> categoriesFuture;
  late Rx<Future<List<HashtagModel>>> hashtagsFuture;
  final BannerService _bannerService = BannerService();
  final BusinessCategoryService _categoryService = BusinessCategoryService();
  final HashtagService _hashtagService = HashtagService();

  @override
  void onInit() {
    super.onInit();
    bannersFuture = _bannerService.fetchBanners().obs;
    categoriesFuture = _categoryService.fetchCategories().obs;
    hashtagsFuture = _hashtagService.fetchHashtags().obs;
  }

  void initializeProducts(int hashtagId) {
    isLoadingProducts.value = true;
    activeFilter = 'last'.obs;
    selectedFilter.value = FilterOption.last;
    allProducts.clear();
    loadProducts(hashtagId);
    currentPage.value = 1;
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

  Future<void> refreshProducts(int hashtagId) async {
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

  Future<List<ProductModel>> fetchProductsByHashtagId(int hashtagId) async {
    return _hashtagService.fetchProductsByHashtagId(hashtagId: hashtagId);
  }

  Future<void> refreshBanners() async {
    bannersFuture.value = Future.value([]);
    categoriesFuture.value = Future.value([]);
    hashtagsFuture.value = Future.value([]);

    bannersFuture.value = _bannerService.fetchBanners();
    categoriesFuture.value = _categoryService.fetchCategories();
    hashtagsFuture.value = _hashtagService.fetchHashtags();

    refreshController.refreshCompleted();
  }
}
