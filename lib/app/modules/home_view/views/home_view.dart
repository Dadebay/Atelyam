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
        elevation: 0,
        title: const Text(
          'Atelýam',
          style: TextStyle(
            color: ColorConstants.kSecondaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: Banners()),
                SliverToBoxAdapter(
                  child: BusinessCategoryView(
                    screenWidth: screenWidth,
                    categoriesFuture: homeController.categoriesFuture.value,
                  ),
                ),
                SliverToBoxAdapter(child: BusinessUsersHomeView()),
                SliverToBoxAdapter(
                  child: ProductsView(
                    size: Size(screenWidth, screenHeight),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
