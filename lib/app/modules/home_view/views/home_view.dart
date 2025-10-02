import 'package:atelyam/app/modules/home_view/views/widgets/products_view.dart';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.whiteMainColor,
        toolbarHeight: 0,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(
            color: ColorConstants.whiteMainColor,
            width: 0,
          ),
        ),
      ),
      body: _buildContent(),
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
            color: ColorConstants.whiteMainColor,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.zero,
              children: [
                Banners(),
                BusinessCategoryView(
                  screenWidth: screenWidth,
                  categoriesFuture: homeController.categoriesFuture.value,
                ),
                BusinessUsersHomeView(),
                ProductsView(
                  size: Size(screenWidth, screenHeight),
                ),
                Container(
                  height: screenHeight * 0.10,
                  color: ColorConstants.whiteMainColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
