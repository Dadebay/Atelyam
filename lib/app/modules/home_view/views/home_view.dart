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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenHeight = constraints.maxHeight;
        final double screenWidth = constraints.maxWidth;

        return Obx(() {
          return FutureBuilder(
            future: Future.wait([
              homeController.bannersFuture.value,
              homeController.categoriesFuture.value,
              homeController.hashtagsFuture.value,
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: EmptyStates().loadingData());
              }

              if (snapshot.hasError) {
                return Center(child: EmptyStates().errorData(snapshot.error.toString()));
              }

              return RefreshIndicator(
                onRefresh: homeController.refreshBanners,
                child: ListView(
                  children: [
                    Banners(),
                    BusinessCategoryView(screenWidth: screenWidth, categoriesFuture: homeController.categoriesFuture.value),
                    BusinessUsersHomeView(),
                    ProductsView(
                      size: Size(screenWidth, screenHeight),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }
}
