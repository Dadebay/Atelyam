import '../../../product/custom_widgets/index.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackgroundPattern(),
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenHeight = constraints.maxHeight;
        final double screenWidth = constraints.maxWidth;

        return RefreshIndicator(
          onRefresh: homeController.refreshBanners,
          child: Container(
            color: Colors.white,
            child: ListView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: EdgeInsets.zero,
              children: [
                Banners(),
                BusinessCategoryView(
                  screenWidth: screenWidth,
                  categoriesFuture: homeController.categoriesFuture.value,
                ),
                BusinessUsersHomeView(),
                _buildProducts(
                  Size(screenWidth, screenHeight),
                ),
                Container(height: screenHeight * 0.20, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProducts(Size size) {
    return Obx(() {
      return FutureBuilder<List<HashtagModel>>(
        future: homeController.hashtagsFuture.value,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return EmptyStates().loadingData();
          } else if (snapshot.hasError) {
            return EmptyStates().errorData(snapshot.hasError.toString());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final hashtag = snapshot.data![index];
                return hashtag.count > 0 ? _buildProductList(size, hashtag) : const SizedBox.shrink();
              },
            );
          } else {
            return EmptyStates().noDataAvailable();
          }
        },
      );
    });
  }

  Widget _buildProductList(Size size, HashtagModel hashtagModel) {
    return Column(
      children: [
        ListviewTopNameAndIcon(
          text: hashtagModel.name,
          icon: true,
          onTap: () => Get.to(() => AllProductsView(title: hashtagModel.name, id: hashtagModel.id)),
        ),
        SizedBox(
          height: size.height * 0.35,
          child: FutureBuilder<List<ProductModel>>(
            future: homeController.fetchProductsByHashtagId(hashtagModel.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return EmptyStates().loadingData();
              } else if (snapshot.hasError) {
                return EmptyStates().errorData(snapshot.hasError.toString());
              } else if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemExtent: size.width * 0.55,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return DiscoveryCard(
                      homePageStyle: true,
                      productModel: snapshot.data![index],
                    );
                  },
                );
              } else {
                return EmptyStates().noDataAvailable();
              }
            },
          ),
        ),
      ],
    );
  }
}
