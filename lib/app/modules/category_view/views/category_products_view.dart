import 'package:atelyam/app/modules/category_view/controllers/category_controller.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/custom_widgets/transparent_app_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CategoryProductView extends StatefulWidget {
  final CategoryModel categoryModel;

  const CategoryProductView({required this.categoryModel, super.key});

  @override
  State<CategoryProductView> createState() => _CategoryProductViewState();
}

class _CategoryProductViewState extends State<CategoryProductView> {
  final CategoryController _categoryController = Get.put(CategoryController());
  final AuthController authController = Get.find();
  @override
  void initState() {
    super.initState();
    _categoryController.initializeProducts(widget.categoryModel.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _topImage(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _imagePart(),
          ),
          TransparentAppBar(
            title: widget.categoryModel.name,
            removeLeading: false,
            color: ColorConstants.whiteMainColor,
            actions: [
              Obx(
                () => Container(
                  margin: EdgeInsets.only(right: 16),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadii.borderRadius10,
                    border: Border.all(
                      color: ColorConstants.whiteMainColor,
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 26,
                    icon: Icon(
                      _categoryController.isFilterExpanded.value ? Icons.close : IconlyLight.filter,
                      color: ColorConstants.whiteMainColor,
                    ),
                    onPressed: () {
                      _showFilterBottomSheet(context);
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: Get.size.height * 0.15,
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: ColorConstants.whiteMainColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Obx(
                  () {
                    if (_categoryController.isLoadingProducts.value) {
                      return EmptyStates().loadingData();
                    } else if (_categoryController.allProducts.isEmpty) {
                      return EmptyStates().noDataAvailablePage(
                        textColor: ColorConstants.darkMainColor,
                      );
                    } else {
                      return _buildProductGrid();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Positioned _topImage() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: Get.size.height * 0.80,
        child: CachedNetworkImage(
          imageUrl: '${authController.ipAddress.value}${widget.categoryModel.logo ?? ''}',
          fit: BoxFit.cover,
          placeholder: (context, url) => EmptyStates().loadingData(),
          errorWidget: (context, url, error) => EmptyStates().noMiniCategoryImage(),
        ),
      ),
    );
  }

  SizedBox _imagePart() {
    return SizedBox(
      height: Get.size.height * 0.60,
      child: Hero(
        tag: widget.categoryModel.name,
        child: ClipRRect(
          borderRadius: BorderRadii.borderRadius30,
          child: CachedNetworkImage(
            imageUrl: '${authController.ipAddress.value}${widget.categoryModel.logo ?? ''}',
            fit: BoxFit.cover,
            placeholder: (context, url) => EmptyStates().loadingData(),
            errorWidget: (context, url, error) => EmptyStates().noMiniCategoryImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return SmartRefresher(
      controller: _categoryController.refreshController,
      enablePullUp: true,
      scrollDirection: Axis.vertical,
      onRefresh: () => _categoryController.refreshProducts(widget.categoryModel.id),
      onLoading: () => _categoryController.loadMoreProducts(widget.categoryModel.id),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: MasonryGridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: _categoryController.allProducts.length,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          itemBuilder: (context, index) {
            return Obx(
              () => _buildCard(
                index: index,
                product: _categoryController.allProducts[index],
                isAnimated: _categoryController.value.value,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard({
    required int index,
    required ProductModel product,
    required bool isAnimated,
  }) {
    if (isAnimated) {
      return Container(
        height: index % 2 == 0 ? 250 : 200,
        decoration: BoxDecoration(borderRadius: BorderRadii.borderRadius20, boxShadow: [
          BoxShadow(
            color: ColorConstants.kPrimaryColor.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]),
        child: DiscoveryCard(
          productModel: product,
          homePageStyle: false,
        ),
      );
    } else {
      return Container(
        height: index % 2 == 0 ? 250 : 200,
        decoration: BoxDecoration(borderRadius: BorderRadii.borderRadius20, boxShadow: [
          BoxShadow(
            color: ColorConstants.kPrimaryColor.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]),
        child: DiscoveryCard(
          homePageStyle: false,
          productModel: product,
        ),
      );
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 15, right: 8, left: 8, bottom: 8),
        decoration: BoxDecoration(
          color: ColorConstants.whiteMainColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'filter'.tr,
              style: TextStyle(
                color: ColorConstants.darkMainColor,
                fontSize: AppFontSizes.fontSize20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            radioListTileButton(text: 'last', value: FilterOption.last),
            radioListTileButton(text: 'first', value: FilterOption.first),
            radioListTileButton(
              text: 'viewcount',
              value: FilterOption.viewCount,
            ),
            radioListTileButton(text: 'LowPrice', value: FilterOption.lowPrice),
            radioListTileButton(
              text: 'HighPrice',
              value: FilterOption.highPrice,
            ),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'cancel'.tr,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: AppFontSizes.fontSize20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget radioListTileButton({
    required String text,
    required FilterOption value,
  }) {
    return Obx(
      () => RadioListTile(
        title: Text(
          text.tr,
          maxLines: 1,
          style: TextStyle(
            color: ColorConstants.darkMainColor,
            fontSize: AppFontSizes.fontSize16,
            fontWeight: _categoryController.selectedFilter.value == value ? FontWeight.bold : FontWeight.w400,
          ),
        ),
        value: value,
        activeColor: ColorConstants.kSecondaryColor,
        groupValue: _categoryController.selectedFilter.value,
        onChanged: (FilterOption? value) {
          if (value != null) {
            _categoryController.selectedFilter.value = value;
            _categoryController.activeFilter.value = text.toString();
            _categoryController.initializeProducts(widget.categoryModel.id);
            Get.back();
          }
        },
      ),
    );
  }
}
