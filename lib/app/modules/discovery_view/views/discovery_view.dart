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
  final DiscoveryController controller = Get.put(DiscoveryController());

  @override
  void initState() {
    super.initState();
    controller.textEditingController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.whiteMainColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _buildSearchBar(),
      ),
      body: _buildGridView(),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
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
        fillColor: ColorConstants.searchColor.withOpacity(0.6),
        border: OutlineInputBorder(borderRadius: BorderRadii.borderRadius20, borderSide: BorderSide(color: Colors.transparent)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadii.borderRadius20, borderSide: BorderSide(color: Colors.transparent)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadii.borderRadius20, borderSide: BorderSide(color: ColorConstants.kPrimaryColor)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
      ),
      onSubmitted: (value) {
        controller.searchProducts(value);
      },
    );
  }

  Widget _buildGridView() {
    return Obx(() {
      if (controller.products.isEmpty && controller.hasMore) {
        return EmptyStates().loadingData();
      } else if (controller.products.isEmpty && !controller.hasMore) {
        return EmptyStates().noDataAvailable();
      }

      final List<Map<String, int>> tileSizes = [
        {'cross': 2, 'main': 2},
        {'cross': 2, 'main': 1},
        {'cross': 1, 'main': 2},
        {'cross': 2, 'main': 1},
        {'cross': 1, 'main': 2},
        {'cross': 1, 'main': 2},
      ];

      return SmartRefresher(
        controller: controller.refreshController,
        enablePullUp: true,
        onRefresh: controller.onRefresh,
        onLoading: controller.onLoading,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StaggeredGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 3,
            crossAxisSpacing: 3,
            children: List.generate(controller.products.length, (index) {
              final tile = tileSizes[index % tileSizes.length];
              return StaggeredGridTile.count(
                crossAxisCellCount: tile['cross']!,
                mainAxisCellCount: tile['main']!,
                child: DiscoveryCard(
                  productModel: controller.products[index],
                  homePageStyle: false,
                  showFavButton: false,
                  showViewCount: true,
                ),
              );
            }),
          ),
        ),
      );
    });
  }
}
