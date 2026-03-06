// ignore_for_file: deprecated_member_use

import 'package:atelyam/app/data/service/product_service.dart';
import 'package:atelyam/app/modules/discovery_view/components/discovery_card.dart';
import 'package:atelyam/app/modules/settings_view/controllers/settings_controller.dart';
import 'package:atelyam/app/modules/settings_view/views/business_acc_components_view/edit_business_account_view.dart';
import 'package:atelyam/app/modules/settings_view/views/product_components/create_product.view.dart';
import 'package:atelyam/app/modules/settings_view/views/product_components/edit_product_view.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hugeicons/hugeicons.dart';

class BusinessProfileSettingsView extends StatefulWidget {
  final GetMyStatusModel businessUser;
  const BusinessProfileSettingsView({required this.businessUser, super.key});

  @override
  State<BusinessProfileSettingsView> createState() => _BusinessProfileSettingsViewState();
}

class _BusinessProfileSettingsViewState extends State<BusinessProfileSettingsView> with SingleTickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final NewSettingsPageController settingsController = Get.put(NewSettingsPageController());

  late final TabController _tabController;
  List<ProductModel>? _products;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final products = await ProductService().getMyProducts();
    if (mounted) {
      setState(() {
        _products = products ?? [];
        _loading = false;
      });
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _buildSliverHeader(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── Tab 1: My Products ──
            _loading
                ? EmptyStates().loadingData()
                : (_products == null || _products!.isEmpty)
                    ? _buildEmptyProducts()
                    : _buildProductsGrid(),
            // ── Tab 2: Favorites ──
            _buildFavoritesTab(),
          ],
        ),
      ),
    );
  }

  // ─── Sliver header ────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildSliverHeader() {
    final bu = widget.businessUser;
    final String photoUrl = (bu.backPhoto != null && bu.backPhoto!.isNotEmpty) ? authController.ipAddress.value + bu.backPhoto! : '';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + stats ──
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16, bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ColorConstants.kSecondaryColor, width: 2),
                    ),
                    child: ClipOval(
                      child: photoUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: photoUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => EmptyStates().loadingData(),
                              errorWidget: (_, __, ___) => _defaultAvatar(),
                            )
                          : _defaultAvatar(),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Stats
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatColumn(
                          count: _products?.length ?? 0,
                          label: 'posts'.tr,
                        ),
                        _StatColumn(
                          count: _products?.length ?? 0,
                          label: 'clients'.tr,
                        ),
                        _StatColumn(
                          count: _products?.length ?? 0,
                          label: 'view_count'.tr,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Name ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                bu.businessName ?? '',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),

            // ── Description / bio ──
            if (bu.description != null && bu.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  bu.description!,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // ── Address ──
            if (bu.address != null && bu.address!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    Icon(HugeIcons.strokeRoundedMaping, size: 18, color: Colors.black87),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        bu.address!,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Contact info & Business buttons ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: _ActionButton(
                label: 'business'.tr,
                onTap: () async {
                  final result = await Get.to(() => EditBusinessAccountView(businessUser: bu));
                  if (result == true) setState(() {});
                },
              ),
            ),

            // ── Tab bar ──
            TabBar(
              controller: _tabController,
              labelColor: ColorConstants.kSecondaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: ColorConstants.kSecondaryColor,
              splashBorderRadius: BorderRadii.borderRadius20,
              dividerColor: Colors.transparent,
              indicator: const UnderlineTabIndicator(
                borderRadius: BorderRadii.borderRadius40,
                borderSide: BorderSide(color: ColorConstants.kSecondaryColor, width: 5.0),
              ),
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: Fonts.gilroy,
                fontSize: AppFontSizes.fontSize20 - 2,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: Fonts.gilroy,
                fontSize: AppFontSizes.fontSize20 - 2,
              ),
              tabs: [
                Tab(text: 'tab2Settings'.tr),
                Tab(text: 'favorites'.tr),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Product grid (uses DiscoveryCard for view count + fav button) ──────────
  Widget _buildProductsGrid() {
    return MasonryGridView.builder(
      padding: const EdgeInsets.all(4),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: _products!.length,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemBuilder: (context, index) {
        final product = _products![index];
        return SizedBox(
          height: index % 2 == 0 ? 250 : 220,
          child: GestureDetector(
            onTap: () async {
              final result = await Get.to(() => UpdateProductView(product: product));
              if (result == true) _loadProducts();
            },
            child: DiscoveryCard(
              productModel: product,
              homePageStyle: false,
              showFavButton: true,
            ),
          ),
        );
      },
    );
  }

  // ─── Favorites tab (inline) ───────────────────────────────────────────────
  Widget _buildFavoritesTab() {
    return Obx(() {
      final favorites = settingsController.favoriteProducts;
      if (favorites.isEmpty) {
        return SingleChildScrollView(child: EmptyStates().noFavoritesFound());
      }
      return MasonryGridView.builder(
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        itemCount: favorites.length,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          final product = favorites[index];
          return SizedBox(
            height: index % 2 == 0 ? 250 : 220,
            child: DiscoveryCard(productModel: product, homePageStyle: false),
          );
        },
      );
    });
  }

  Widget _buildEmptyProducts() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmptyStates().noDataAvailablePage(textColor: ColorConstants.kPrimaryColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AgreeButton(
              onTap: () async {
                final result = await Get.to(() => CreateProductView());
                if (result == true) _loadProducts();
              },
              text: 'add_product',
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(IconlyLight.profile, size: 40, color: Colors.grey),
    );
  }
}

// ─── Stat column widget ───────────────────────────────────────────────────────
class _StatColumn extends StatelessWidget {
  final int count;
  final String label;
  const _StatColumn({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      ],
    );
  }
}

// ─── Action button widget ─────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadii.borderRadius10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
            const SizedBox(width: 8),
            const Icon(IconlyLight.arrow_right_circle, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
