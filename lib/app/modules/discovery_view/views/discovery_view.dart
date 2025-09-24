// ignore_for_file: deprecated_member_use

import 'package:atelyam/app/modules/discovery_view/controllers/discovery_controller.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DiscoveryView extends StatelessWidget {
  DiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundPattern(),
          TransparentAppBar(
            title: 'mostViewedFasons',
            removeLeading: true,
            color: Colors.white,
          ),
          buildGridView(),
        ],
      ),
    );
  }

  final DiscoveryController controller = Get.put(DiscoveryController());

  Widget buildGridView() {
    return Obx(() {
      if (controller.products.isEmpty && controller.hasMore) {
        return EmptyStates().loadingData();
      } else if (controller.products.isEmpty && !controller.hasMore) {
        return EmptyStates().noDataAvailable();
      }

      return SmartRefresher(
        controller: controller.refreshController,
        enablePullUp: true,
        onRefresh: controller.onRefresh,
        onLoading: controller.onLoading,
        child: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight + 40),
          child: MasonryGridView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Get.size.width >= 800 ? 3 : 2,
            ),
            itemCount: controller.products.length,
            mainAxisSpacing: 15.0,
            crossAxisSpacing: 15.0,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: index % 2 == 0
                    ? Get.size.width >= 800
                        ? 350
                        : 230
                    : Get.size.width >= 800
                        ? 380
                        : 250,
                child: DiscoveryCard(
                  homePageStyle: false,
                  productModel: controller.products[index],
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
