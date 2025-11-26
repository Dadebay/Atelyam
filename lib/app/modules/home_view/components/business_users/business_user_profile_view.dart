import 'package:atelyam/app/modules/home_view/components/business_users/social_media_button.dart';
import 'package:atelyam/app/modules/home_view/controllers/brands_controller.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class BusinessUserProfileView extends StatefulWidget {
  final BusinessUserModel businessUserModelFromOutside;
  final int categoryID;
  final String whichPage;
  const BusinessUserProfileView({
    required this.businessUserModelFromOutside,
    required this.categoryID,
    required this.whichPage,
    super.key,
  });
  State<BusinessUserProfileView> createState() => _BusinessUserProfileViewState();
}

class _BusinessUserProfileViewState extends State<BusinessUserProfileView> {
  final BrandsController _homeController = Get.put<BrandsController>(BrandsController());
  final AuthController authController = Get.find<AuthController>();
  @override
  void initState() {
    super.initState();

    _homeController.fetchBusinessUserData(
      businessUserModelFromOutside: widget.businessUserModelFromOutside,
      categoryID: widget.categoryID,
      whichPage: widget.whichPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        bottomSheet: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: AgreeButton(
            onTap: () {
              final String phoneNumberText =
                  _homeController.businessUser.value!.businessPhone.contains('+993') ? _homeController.businessUser.value!.businessPhone : '+993${_homeController.businessUser.value!.businessPhone}';
              _homeController.makePhoneCall(phoneNumberText);
            },
            text: 'call'.tr,
          ),
        ),
        backgroundColor: Colors.white,
        body: Obx(
          () => _homeController.isLoadingBrandsProfile.value
              ? EmptyStates().loadingData()
              : NestedScrollView(
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      _buildSliverAppBar(),
                    ];
                  },
                  body: TabBarView(
                    children: [
                      _buildInfoTab(),
                      _buildImagesTab(),
                      _buildVideosTab(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    final String phoneNumberText =
        _homeController.businessUser.value!.businessPhone.contains('+993') ? _homeController.businessUser.value!.businessPhone : '+993${_homeController.businessUser.value!.businessPhone}';
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 25),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            _homeController.businessUser.value!.instagram!.isEmpty
                ? SizedBox.shrink()
                : SocialMediaIcon(
                    name: 'instagram',
                    userName: _homeController.businessUser.value!.instagram.toString(),
                    icon: Assets.instagram,
                    maxline: 1,
                    index: 3,
                  ),
            _homeController.businessUser.value!.youtube!.isEmpty
                ? SizedBox.shrink()
                : SocialMediaIcon(
                    name: 'youtube',
                    userName: _homeController.businessUser.value!.youtube.toString(),
                    icon: Assets.youtube,
                    index: 4,
                    maxline: 1,
                  ),
            _homeController.businessUser.value!.tiktok!.isEmpty
                ? SizedBox.shrink()
                : SocialMediaIcon(
                    name: 'tiktok',
                    userName: _homeController.businessUser.value!.tiktok.toString(),
                    icon: Assets.tiktok,
                    index: 5,
                    maxline: 1,
                  ),
            phoneNumberText.isEmpty
                ? SizedBox.shrink()
                : SocialMediaIcon(
                    name: 'phone_number',
                    userName: phoneNumberText,
                    icon: Assets.phone,
                    index: 6,
                    maxline: 1,
                  ),
            _homeController.businessUser.value!.address!.isEmpty
                ? SizedBox.shrink()
                : SocialMediaIcon(
                    name: 'location',
                    userName: _homeController.businessUser.value!.address.toString(),
                    icon: Assets.address,
                    index: 6,
                    maxline: 4,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesTab() {
    return Obx(() {
      if (_homeController.isLoadingBrandsProfile.value) {
        return EmptyStates().loadingData();
      }
      return FutureBuilder<List<ProductModel>?>(
        future: _homeController.productsFuture.value,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return EmptyStates().loadingData();
          } else if (snapshot.hasError) {
            return EmptyStates().errorData(snapshot.error.toString());
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return EmptyStates().noDataAvailable();
          } else {
            final products = snapshot.data!;
            return MasonryGridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: products.length,
              mainAxisSpacing: 15.0,
              crossAxisSpacing: 15.0,
              itemBuilder: (BuildContext context, int index) {
                final product = products[index];
                return SizedBox(
                  height: index % 2 == 0 ? 250 : 220,
                  child: DiscoveryCard(
                    productModel: product,
                    homePageStyle: false,
                    businessUserID: widget.businessUserModelFromOutside.userID.toString(),
                  ),
                );
              },
            );
          }
        },
      );
    });
  }

  Widget _buildVideosTab() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'comingTitle'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppFontSizes.fontSize20 + 2,
              color: ColorConstants.kPrimaryColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              'comingSubtitle'.tr,
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: AppFontSizes.fontSize16,
                color: ColorConstants.kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      leading: BackButtonMine(miniButton: true),
      scrolledUnderElevation: 0.0,
      expandedHeight: 360.0,
      foregroundColor: ColorConstants.kSecondaryColor,
      actionsIconTheme: const IconThemeData(color: ColorConstants.kSecondaryColor),
      backgroundColor: Colors.white,
      automaticallyImplyLeading: true,
      bottom: TabBar(
        labelColor: ColorConstants.kSecondaryColor,
        indicatorColor: ColorConstants.kSecondaryColor,
        splashBorderRadius: BorderRadii.borderRadius20,
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
        dividerColor: Colors.transparent,
        indicator: const UnderlineTabIndicator(
          borderRadius: BorderRadii.borderRadius40,
          borderSide: BorderSide(color: ColorConstants.kSecondaryColor, width: 5.0),
        ),
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(text: 'tab1'.tr),
          Tab(text: 'tab2'.tr),
          Tab(text: 'tab3'.tr),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _buildFlexibleSpaceBackground(),
      ),
    );
  }

  Widget _buildFlexibleSpaceBackground() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            Assets.backgorundPattern3,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadii.borderRadius99,
                    border: Border.all(
                      color: Colors.white.withOpacity(.4),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadii.borderRadius50,
                    child: CachedNetworkImage(
                      fadeInCurve: Curves.ease,
                      imageUrl: authController.ipAddress.value + (_homeController.businessUser.value?.backPhoto ?? ''),
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadii.borderRadius99,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => EmptyStates().loadingData(),
                      errorWidget: (context, url, error) => EmptyStates().noMiniCategoryImage(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _homeController.businessUser.value!.businessName.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorConstants.kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppFontSizes.fontSize20,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 70),
                  child: Text(
                    _homeController.businessUser.value!.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorConstants.darkMainColor.withOpacity(.6),
                      fontSize: AppFontSizes.fontSize14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
