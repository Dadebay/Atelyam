import 'package:atelyam/app/modules/settings_view/components/fav_button_product.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:sliver_tools/sliver_tools.dart';
// Make sure this path is correct

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
                          child: brendData(snapshot.data!),
                        ),
                      ),
                      Obx(
                        () => controller.productImages.isNotEmpty &&
                                controller.selectedImageIndex.value ==
                                    controller.productImages.length - 1
                            ? SliverPadding(
                                padding: const EdgeInsets.all(12),
                                sliver: SliverList(
                                  delegate: SliverChildListDelegate([
                                    widget.productModel.description.isEmpty
                                        ? const SizedBox.shrink()
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            child: Text(
                                              'info_product'.tr,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize:
                                                    AppFontSizes.fontSize20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                    Text(
                                      widget.productModel.description,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: AppFontSizes.fontSize16 - 2,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: ColorConstants.kSecondaryColor,
                                        borderRadius:
                                            BorderRadii.borderRadius15,
                                      ),
                                      child: Text(
                                        '${'sold'.tr} - ${widget.productModel.price.substring(0, widget.productModel.price.length - 3)} TMT',
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: ColorConstants.whiteMainColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: AppFontSizes.fontSize20,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                        top: 15,
                                      ),
                                      child: Text(
                                        widget.productModel.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: ColorConstants.darkMainColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: AppFontSizes.fontSize20,
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              )
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

  Widget brendData(BusinessUserModel businessUserModel) {
    return GestureDetector(
      onTap: () {
        if (widget.productModel.user.toString() ==
            widget.businessUserID.toString()) {
          Get.back();
        } else {
          Get.to(
            () => BusinessUserProfileView(
              categoryID: businessUserModel.userID!,
              businessUserModelFromOutside: businessUserModel,
              whichPage: 'popular',
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: ColorConstants.whiteMainColor,
          borderRadius: BorderRadii.borderRadius25,
          boxShadow: [
            BoxShadow(
              color: ColorConstants.kThirdColor.withOpacity(0.4),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
          border:
              Border.all(color: ColorConstants.kPrimaryColor.withOpacity(.2)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.only(right: 15),
              child: ClipRRect(
                borderRadius: BorderRadii.borderRadius99,
                child: WidgetsMine()
                    .customCachedImage(businessUserModel.backPhoto),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    businessUserModel.businessName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorConstants.darkMainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppFontSizes.fontSize20 - 2,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    businessUserModel.address.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorConstants.darkMainColor.withOpacity(.6),
                      fontWeight: FontWeight.w600,
                      fontSize: AppFontSizes.fontSize16,
                    ),
                  ),
                ],
              ),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: controller.showMoreOptions.value
                    ? Container(
                        key: const ValueKey('rightPanel'),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadii.borderRadius15,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              margin: EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Icon(
                                      IconlyLight.show,
                                      color: ColorConstants.whiteMainColor,
                                      size: AppFontSizes.fontSize24,
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      controller.viewCount.toString(),
                                      style: TextStyle(
                                        color: ColorConstants.whiteMainColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppFontSizes.fontSize20 - 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            // FavButton
                            FavButtonProduct(
                              productProfilStyle: true,
                              product: widget.productModel,
                            ),
                            const SizedBox(height: 10),

                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: IconButton(
                                style: IconButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadii.borderRadius15,
                                  ),
                                  backgroundColor: Colors.grey.withOpacity(0.7),
                                ),
                                icon: Icon(
                                  IconlyLight.download,
                                  color: ColorConstants.whiteMainColor,
                                  size: AppFontSizes.fontSize24,
                                ),
                                onPressed: () {
                                  controller.checkPermissionAndDownloadImage(
                                    controller.productImages[
                                        controller.selectedImageIndex.value],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            GestureDetector(
              onTap: () {
                controller.showMoreOptions.toggle();
              },
              child: Container(
                child: Icon(
                  Icons.more_vert,
                  color: ColorConstants.whiteMainColor,
                  size: AppFontSizes.fontSize30,
                ),
              ),
            ),
          ],
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
                child: Obx(
                  () => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: controller.isLoading.value
                        ? EmptyStates().loadingData()
                        : GestureDetector(
                            onTap: () {
                              Get.to(
                                () => PhotoViewPage(
                                  images: controller.productImages,
                                  initialIndex:
                                      controller.selectedImageIndex.value,
                                ),
                              );
                            },
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: PageView.builder(
                                scrollDirection: Axis.vertical,
                                controller: _pageController,
                                itemCount: controller.productImages.length,
                                onPageChanged: (index) {
                                  controller.updateSelectedImageIndex(index);
                                },
                                itemBuilder: (context, index) {
                                  return CachedNetworkImage(
                                    imageUrl:
                                        controller.productImages.isNotEmpty
                                            ? controller.productImages[index]
                                            : '',
                                    key: ValueKey<int>(index),
                                    fit: BoxFit.cover,
                                    height: Get.size.height,
                                    width: Get.size.width,
                                    placeholder: (context, url) =>
                                        EmptyStates().loadingData(),
                                    errorWidget: (context, url, error) =>
                                        EmptyStates().noMiniCategoryImage(),
                                  );
                                },
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: AppBar().preferredSize.height + 20,
              bottom: 20,
              child: SizedBox(
                width: 45,
                child: Obx(() {
                  final itemsCount = controller.productImages.length + 1;
                  final displayCount = itemsCount > 4 ? 4 : itemsCount;
                  return Container(
                    height: displayCount * 85.0,
                    child: ListView.builder(
                      itemCount: itemsCount,
                      itemBuilder: (context, index) {
                        if (index == controller.productImages.length) {
                          return GestureDetector(
                            onTap: () {
                              if (outSideBusinessuserModel != null) {
                                _makePhoneCall(
                                  '+${outSideBusinessuserModel!.businessPhone}',
                                );
                              } else {
                                showSnackBar(
                                  'error',
                                  'phone_call_error',
                                  ColorConstants.redColor,
                                );
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              width: 45,
                              height: 75,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                IconlyLight.call,
                                color: ColorConstants.whiteMainColor,
                                size: 28,
                              ),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () {
                              controller.updateSelectedImageIndex(index);
                            },
                            child: Obx(
                              () => Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                width: 42,
                                height: 75,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadii.borderRadius15,
                                  border: Border.all(
                                    color: index ==
                                            controller.selectedImageIndex.value
                                        ? Colors.white
                                        : Colors.grey.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadii.borderRadius15,
                                  child: CachedNetworkImage(
                                    imageUrl: controller.productImages[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        EmptyStates().loadingData(),
                                    errorWidget: (context, url, error) =>
                                        EmptyStates().noMiniCategoryImage(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
