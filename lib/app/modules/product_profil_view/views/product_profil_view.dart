import 'package:atelyam/app/modules/product_profil_view/views/components/app_bar_actions_widget.dart';
import 'package:atelyam/app/modules/product_profil_view/views/components/business_user_card.dart';
import 'package:atelyam/app/modules/product_profil_view/views/components/product_description_section.dart';
import 'package:atelyam/app/modules/product_profil_view/views/components/product_image_page_view.dart';
import 'package:atelyam/app/modules/product_profil_view/views/components/product_thumbnail_list.dart';
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
    _pageController =
        PageController(initialPage: controller.selectedImageIndex.value);

    ever(controller.selectedImageIndex, (int index) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != index) {
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final String phoneNumberText =
        phoneNumber.contains('+993') ? phoneNumber : '+993${phoneNumber}';

    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumberText);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      showSnackBar(
        'error',
        'phone_call_error' + launchUri.toString(),
        ColorConstants.redColor,
      );
      throw 'Could not launch $launchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification) {
          final bool isLastImage = controller.productImages.isNotEmpty &&
              controller.selectedImageIndex.value ==
                  controller.productImages.length - 1;

          if (isLastImage) {
            if (notification.metrics.pixels <
                notification.metrics.minScrollExtent) {
              Get.back();
              return true;
            }
            if (notification.metrics.extentAfter == 0 &&
                notification.metrics.pixels >
                    notification.metrics.maxScrollExtent) {
              Get.back();
              return true;
            }
          }
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: ColorConstants.whiteMainColor,
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: <Widget>[
            _buildSliverAppBar(),
            FutureBuilder<BusinessUserModel?>(
              future: BusinessUserService()
                  .fetchBusinessAccountKICI(widget.productModel.user.toInt()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(child: EmptyStates().loadingData());
                } else if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child:
                        EmptyStates().errorData(snapshot.hasError.toString()),
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
                      Obx(
                        () => controller.productImages.isNotEmpty &&
                                controller.selectedImageIndex.value ==
                                    controller.productImages.length - 1
                            ? ProductDescriptionSection(
                                productModel: widget.productModel)
                            : const SliverToBoxAdapter(
                                child: SizedBox.shrink(),
                              ),
                      ),
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
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: Get.size.height * 0.78,
      pinned: false,
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 6, top: 6),
        child: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            IconlyLight.arrow_left_circle,
            color: Colors.white,
            size: AppFontSizes.fontSize30,
          ),
        ),
      ),
      actions: [
        AppBarActionsWidget(
          controller: controller,
          productModel: widget.productModel,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: ProductImagePageView(
                  controller: controller,
                  pageController: _pageController,
                ),
              ),
            ),
            ProductThumbnailList(
              controller: controller,
              outSideBusinessuserModel: outSideBusinessuserModel,
              makePhoneCall: _makePhoneCall,
            ),
          ],
        ),
      ),
    );
  }
}
