import '../../../product/custom_widgets/index.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});
  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  final ScrollController _scrollController = ScrollController();
  late Future<List<CategoryModel>> _categoriesFuture;
  final RxBool isGridView = true.obs;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = CategoryService().fetchCategories();
  }

  void toggleView() => isGridView.value = !isGridView.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Atelýam',
          style: TextStyle(
            color: ColorConstants.kSecondaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  isGridView.value ? Icons.view_list_rounded : Icons.grid_view,
                  color: ColorConstants.kSecondaryColor,
                  size: 26,
                ),
                onPressed: toggleView,
              )),
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
                          Get.to(() => CategoryProductView(
                                categoryModel: categories[index],
                              ));
                        },
                        scrollableState: Scrollable.of(context),
                      ),
                    );
                  },
                );
              } else {
                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    return CategoryCard(
                      categoryModel: categories[index],
                      onTap: () {
                        Get.to(
                          () => CategoryProductView(
                            categoryModel: categories[index],
                          ),
                        );
                      },
                      scrollableState: Scrollable.of(context),
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
