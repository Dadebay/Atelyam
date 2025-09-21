import 'package:atelyam/app/data/models/category_model.dart';
import 'package:atelyam/app/data/models/product_model.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/modules/category_view/controllers/category_controller.dart';
import 'package:atelyam/app/modules/discovery_view/components/discovery_card.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/empty_states/empty_states.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
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
            color: Colors.white,
          ),
          Positioned(
            top: Get.size.height * 0.15,
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Obx(
                  () {
                    if (_categoryController.isLoadingProducts.value) {
                      return EmptyStates().loadingData();
                    } else if (_categoryController.allProducts.isEmpty) {
                      return EmptyStates().noDataAvailablePage(textColor: ColorConstants.darkMainColor);
                    } else {
                      return _buildProductGrid();
                    }
                  },
                ),
              ),
            ),
          ),
          _buildFilterContainer(context),
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
          imageUrl: '${authController.ipAddress.value}${widget.categoryModel.logo}',
          fit: BoxFit.cover,
          placeholder: (context, url) => EmptyStates().loadingData(),
          errorWidget: (context, url, error) => EmptyStates().noMiniCategoryImage(),
        ),
      ),
    );
  }

  SizedBox _imagePart() {
    return SizedBox(
      height: Get.size.height * 0.60, // Reduced height for better layout
      child: Hero(
        tag: widget.categoryModel.name,
        child: ClipRRect(
          borderRadius: BorderRadii.borderRadius30,
          child: CachedNetworkImage(
            imageUrl: '${authController.ipAddress.value}${widget.categoryModel.logo}',
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

  Widget _buildFilterContainer(BuildContext context) {
    return Obx(() {
      return Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {
            _categoryController.toggleFilterExpanded(); // Filtre durumunu değiştir
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _categoryController.isFilterExpanded.value ? MediaQuery.of(context).size.height * 0.4 : 60,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              color: ColorConstants.whiteMainColor,
              border: Border.all(color: ColorConstants.kSecondaryColor, width: 2),
              borderRadius: BorderRadii.borderRadius20,
            ),
            child: _categoryController.isFilterExpanded.value
                ? ListView(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 10),
                    children: [
                      radioListTileButton(text: 'last', value: FilterOption.last),
                      radioListTileButton(text: 'first', value: FilterOption.first),
                      radioListTileButton(text: 'viewcount', value: FilterOption.viewCount),
                      radioListTileButton(text: 'LowPrice', value: FilterOption.lowPrice),
                      radioListTileButton(text: 'HighPrice', value: FilterOption.highPrice),
                      TextButton(
                        onPressed: () {
                          _categoryController.toggleFilterExpanded(); // Filtre durumunu değiştir
                        },
                        child: Text(
                          'cancel'.tr,
                          style: TextStyle(color: Colors.black, fontSize: AppFontSizes.fontSize20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      'filter'.tr,
                      style: TextStyle(
                        color: ColorConstants.darkMainColor,
                        fontSize: AppFontSizes.fontSize20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ),
      );
    });
  }

  Widget radioListTileButton({required String text, required FilterOption value}) {
    return Obx(
      () => RadioListTile(
        title: Text(
          text.tr,
          maxLines: 1,
          style: TextStyle(
            color: ColorConstants.darkMainColor,
            fontSize: AppFontSizes.fontSize16,
            fontWeight: _categoryController.selectedFilter.value == value ? FontWeight.bold : FontWeight.w300,
          ),
        ),
        value: value,
        groupValue: _categoryController.selectedFilter.value,
        onChanged: (FilterOption? value) {
          if (value != null) {
            _categoryController.selectedFilter.value = value;
            _categoryController.activeFilter.value = text.toString();
            _categoryController.initializeProducts(widget.categoryModel.id);
            _categoryController.toggleFilterExpanded();
          }
        },
      ),
    );
  }

  Widget _buildCard({required int index, required ProductModel product, required bool isAnimated}) {
    if (isAnimated) {
      return SizedBox(
        height: index % 2 == 0 ? 250 : 200,
        child: DiscoveryCard(
          productModel: product,
          homePageStyle: false,
        ),
      );
    } else {
      return SizedBox(
          height: index % 2 == 0 ? 250 : 200,
          child: DiscoveryCard(
            homePageStyle: false,
            productModel: product,
          ),
      );
    }
  }
}
