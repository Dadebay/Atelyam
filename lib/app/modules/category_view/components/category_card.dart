import 'package:atelyam/app/data/models/category_model.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/product/empty_states/empty_states.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryCard extends StatelessWidget {
  final Function() onTap;
  final ScrollableState scrollableState;
  final keyImage = GlobalKey();
  final CategoryModel categoryModel;
  CategoryCard({
    required this.onTap,
    required this.scrollableState,
    required this.categoryModel,
    super.key,
  });
  final AuthController authController = Get.find();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: categoryModel.name,
        child: Container(
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          height: Get.size.width >= 800 ? 350 : 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadii.borderRadius15,
            color: Colors.transparent,
          ),
          child: Material(
            borderRadius: BorderRadii.borderRadius15,
            child: ClipRRect(
              borderRadius: BorderRadii.borderRadius15,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: categoryModel.logo == null
                        ? const SizedBox.shrink()
                        : Flow(
                            delegate: ParallaxFlowDelegate(
                              scrollable: scrollableState,
                              itemContext: context,
                              keyImage: keyImage,
                            ),
                            children: [
                              categoryModel.logo != null && categoryModel.logo!.isNotEmpty && categoryModel.logo! != "null"
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          '${authController.ipAddress.value}${categoryModel.logo}',
                                      fit: BoxFit.cover,
                                      key: keyImage,
                                      placeholder: (context, url) =>
                                          EmptyStates().loadingData(),
                                      errorWidget: (context, url, error) =>
                                          EmptyStates().noMiniCategoryImage(),
                                    )
                                  : EmptyStates().noMiniCategoryImage(),
                            ],
                          ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryModel.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppFontSizes.fontSize24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${categoryModel.count} ${"count".tr}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ParallaxFlowDelegate extends FlowDelegate {
  final ScrollableState scrollable;
  final BuildContext itemContext;
  final GlobalKey keyImage;
  ParallaxFlowDelegate({
    required this.scrollable,
    required this.itemContext,
    required this.keyImage,
  }) : super(repaint: scrollable.position);
  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) =>
      BoxConstraints.tightFor(width: constraints.maxWidth);

  @override
  void paintChildren(FlowPaintingContext context) {
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final itemBox = itemContext.findRenderObject() as RenderBox;
    final itemOffset = itemBox.localToGlobal(
      itemBox.size.centerLeft(Offset.zero),
      ancestor: scrollableBox,
    );
    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction = (itemOffset.dy / viewportDimension).clamp(0, 1);
    final verticalAlignment = Alignment(0, scrollFraction * 2 - 1);
    final imageBox = keyImage.currentContext!.findRenderObject() as RenderBox;
    final childRect =
        verticalAlignment.inscribe(imageBox.size, Offset.zero & context.size);
    context.paintChild(
      0,
      transform: Transform.translate(
        offset: Offset(0, childRect.top),
      ).transform,
    );
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) =>
      scrollable != oldDelegate.scrollable ||
      itemContext != oldDelegate.itemContext ||
      keyImage != oldDelegate.keyImage;
}
