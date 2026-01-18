import 'package:atelyam/app/modules/product_profil_view/views/components/app_bar_actions_widget.dart';
import 'package:atelyam/app/modules/product_profil_view/views/components/business_user_card.dart';
import 'package:atelyam/app/modules/product_profil_view/views/components/product_description_section.dart';
import 'package:atelyam/app/modules/product_profil_view/views/components/product_image_page_view.dart';
import 'package:atelyam/app/modules/product_profil_view/views/components/product_thumbnail_list.dart';
import 'package:atelyam/app/modules/virtual_tryon/views/virtual_tryon_view.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ProductProfilView extends StatefulWidget {
  const ProductProfilView({
    required this.productModel,
    super.key,
    this.businessUserID,
  });
  final ProductModel productModel;
  final String? businessUserID;
  @override
  State<ProductProfilView> createState() => _ProductProfilViewState();
}

class _ProductProfilViewState extends State<ProductProfilView> {
  final ProductProfilController controller = Get.put(ProductProfilController());
  BusinessUserModel? outSideBusinessuserModel;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    controller.fetchImages(widget.productModel.id, widget.productModel.img);
    controller.fetchViewCount(widget.productModel.id);
    _pageController = PageController(initialPage: controller.selectedImageIndex.value);

    ever(controller.selectedImageIndex, (int index) {
      if (_pageController.hasClients && _pageController.page?.round() != index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          _buildSliverAppBar(),
          FutureBuilder<BusinessUserModel?>(
            future: BusinessUserService().fetchBusinessAccountKICI(widget.productModel.user.toInt()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(child: EmptyStates().loadingData());
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: EmptyStates().errorData(snapshot.hasError.toString()),
                );
              } else if (snapshot.hasData) {
                outSideBusinessuserModel = snapshot.data;
                return MultiSliver(
                  children: [
                    SliverPadding(
                      padding: const EdgeInsets.all(12),
                      sliver: SliverToBoxAdapter(
                        child: BusinessUserCard(
                          businessUserModel: snapshot.data!,
                          productModel: widget.productModel,
                          businessUserID: widget.businessUserID,
                        ),
                      ),
                    ),
                    ProductDescriptionSection(productModel: widget.productModel),
                  ],
                );
              }
              return SliverToBoxAdapter(
                child: EmptyStates().noDataAvailable(),
              );
            },
          ),
        ],
      ),
      // Virtual Try-On butonu ekle
      bottomNavigationBar: _buildTryOnButton(),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: Get.size.height * 0.78,
      pinned: false,
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: ProductImagePageView(controller: controller, pageController: _pageController),
              ),
            ),
            Positioned(
                top: 35,
                left: 10,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.7), border: Border.all(color: Colors.white.withOpacity(.3)), borderRadius: BorderRadii.borderRadius15),
                    child: Icon(IconlyLight.arrow_left_circle, color: ColorConstants.kPrimaryColor, size: AppFontSizes.fontSize24),
                  ),
                )),
            Positioned(top: kToolbarHeight - 20, right: 10, child: AppBarActionsWidget(productModel: widget.productModel, phoneNumber: outSideBusinessuserModel?.businessPhone ?? '')),
            Positioned(top: 0, bottom: 0, left: 12, child: Center(child: ProductThumbnailList(controller: controller, outSideBusinessuserModel: outSideBusinessuserModel))),
          ],
        ),
      ),
    );
  }

  /// Virtual Try-On Butonu
  Widget _buildTryOnButton() {
    final authController = Get.find<AuthController>();
    final garmentImageUrl = authController.ipAddress.value + widget.productModel.img;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.whiteMainColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(
                    () => VirtualTryOnView(
                      productModel: widget.productModel,
                      garmentImageUrl: garmentImageUrl,
                    ),
                  );
                },
                icon: Icon(Icons.checkroom_rounded, size: 24),
                label: Text(
                  'Üzerimde Dene (AI)',
                  style: TextStyle(
                    fontSize: AppFontSizes.fontSize18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadii.borderRadius20,
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
