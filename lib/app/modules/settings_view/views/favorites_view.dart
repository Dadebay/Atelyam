import 'package:atelyam/app/modules/discovery_view/components/discovery_card.dart';
import 'package:atelyam/app/modules/settings_view/controllers/settings_controller.dart';
import 'package:atelyam/app/product/empty_states/empty_states.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class FavoritesView extends StatelessWidget {
  FavoritesView({super.key});
  final NewSettingsPageController settingsController = Get.put(NewSettingsPageController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (settingsController.favoriteProducts.isEmpty) {
        return Center(child: EmptyStates().noFavoritesFound());
      }

      return MasonryGridView.builder(
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        itemCount: settingsController.favoriteProducts.length,
        mainAxisSpacing: 15.0,
        crossAxisSpacing: 15.0,
        itemBuilder: (BuildContext context, int index) {
          final product = settingsController.favoriteProducts[index];
          return Container(
            height: index % 2 == 0 ? 250 : 300,
            child: DiscoveryCard(productModel: product, homePageStyle: false),
          );
        },
      );
    });
  }
}
