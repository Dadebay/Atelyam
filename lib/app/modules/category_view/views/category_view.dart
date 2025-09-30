import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../product/custom_widgets/index.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});
  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late Future<List<CategoryModel>> _categoriesFuture;
  final RxBool isGridView = true.obs;
  final AuthController authController = Get.find();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = CategoryService().fetchCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void toggleView() => isGridView.value = !isGridView.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.whiteMainColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'categories'.tr,
          style: TextStyle(
            color: ColorConstants.kSecondaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 22,
          ),
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed: toggleView,
              icon: HugeIcon(
                icon: isGridView.value
                    ? HugeIcons.strokeRoundedParagraphBulletsPoint01
                    : HugeIcons.strokeRoundedGridView,
                color: ColorConstants.kSecondaryColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<CategoryModel>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return EmptyStates().loadingData();
          } else if (snapshot.hasError) {
            return EmptyStates().errorData(snapshot.error.toString());
          } else if (snapshot.hasData) {
            final categories = snapshot.data!;
            return Obx(() {
              if (isGridView.value) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: categories.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == categories.length - 1 ? 16 : 8,
                      ),
                      child: CategoryCard(
                        categoryModel: categories[index],
                        onTap: () {
                          Get.to(
                            () => CategoryProductView(
                              categoryModel: categories[index],
                            ),
                          );
                        },
                        scrollableState: Scrollable.of(context),
                      ),
                    );
                  },
                );
              } else {
                return MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final bool isBig = index % 2 == 0;
                    final double height = isBig ? 250 : 150;

                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () => CategoryProductView(
                            categoryModel: categories[index],
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(3, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      '${authController.ipAddress.value}${categories[index].logo}',
                                  width: double.infinity,
                                  height: height,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey.withOpacity(0.1),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    categories[index].name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            });
          } else {
            return EmptyStates().noCategoriesAvailable();
          }
        },
      ),
    );
  }
}
