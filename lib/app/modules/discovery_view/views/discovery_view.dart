// ignore_for_file: deprecated_member_use

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:atelyam/app/modules/discovery_view/controllers/discovery_controller.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';

class DiscoveryView extends StatelessWidget {
  DiscoveryView({super.key});

  final DiscoveryController controller = Get.put(DiscoveryController());

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
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadii.borderRadius10,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: Icon(IconlyLight.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
        ),
        onSubmitted: (value) {
          controller.searchProducts(value);
        },
      ),
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
