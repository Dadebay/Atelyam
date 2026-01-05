import 'package:lottie/lottie.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:atelyam/app/modules/discovery_view/controllers/discovery_controller.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';

class DiscoveryView extends StatefulWidget {
  DiscoveryView({super.key});

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  late final DiscoveryController controller;

  @override
  void initState() {
    super.initState();
    // Controller zaten varsa kullan, yoksa oluştur ve permanent yap
    if (Get.isRegistered<DiscoveryController>()) {
      controller = Get.find<DiscoveryController>();
    } else {
      controller = Get.put(DiscoveryController(), permanent: true);
    }
    controller.textEditingController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // IndexedStack kullanıldığı için controller'ı burada silmemeliyiz
    // Controller, BottomNavBar dispose edildiğinde otomatik temizlenecek
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Positioned.fill(top: 0, child: _buildGridView()),
            Positioned(top: 10, left: 6, right: 6, child: _buildSearchBar()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller.textEditingController,
        decoration: InputDecoration(
          hintText: 'discovery'.tr + "...",
          prefixIcon: Icon(IconlyLight.search, color: Colors.grey),
          suffixIcon: controller.textEditingController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => controller.clearSearch(),
                )
              : null,
          filled: true,
          fillColor: ColorConstants.searchColor,
          border: OutlineInputBorder(borderRadius: BorderRadii.borderRadius20, borderSide: BorderSide(color: Colors.transparent)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadii.borderRadius20, borderSide: BorderSide(color: Colors.transparent)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadii.borderRadius20, borderSide: BorderSide(color: ColorConstants.kPrimaryColor)),
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
        ),
        onSubmitted: (value) {
          controller.searchProducts(value);
        },
      ),
    );
  }

  Widget _buildGridView() {
    // Kıyafet reklamları için optimize edilmiş tile düzeni
    // Daha dengeli ve çekici görünüm
    final List<Map<String, int>> tileSizes = [
      {'cross': 2, 'main': 3}, // Büyük dikey - öne çıkan ürün
      {'cross': 2, 'main': 2}, // Orta kare
      {'cross': 2, 'main': 2}, // Orta kare
      {'cross': 2, 'main': 3}, // Büyük dikey
      {'cross': 2, 'main': 2}, // Orta kare
      {'cross': 2, 'main': 2}, // Orta kare
    ];

    return SmartRefresher(
      controller: controller.refreshController,
      enablePullUp: true,
      onRefresh: controller.onRefresh,
      onLoading: controller.onLoading,
      child: Obx(() {
        if (controller.products.isEmpty && controller.hasMore) {
          return EmptyStates().loadingData();
        } else if (controller.products.isEmpty && !controller.hasMore) {
          return EmptyStates().noDataAvailable();
        }

        return StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 8, // Daha geniş boşluk
          crossAxisSpacing: 8, // Daha geniş boşluk
          children: List.generate(controller.products.length, (index) {
            final tile = tileSizes[index % tileSizes.length];
            return StaggeredGridTile.count(
              crossAxisCellCount: tile['cross']!,
              mainAxisCellCount: tile['main']!,
              child: ClipRRect(
                borderRadius: BorderRadii.borderRadius10,
                child: DiscoveryCard(
                  productModel: controller.products[index],
                  homePageStyle: false,
                  showFavButton: true,
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
