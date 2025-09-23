import '../../../product/custom_widgets/index.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});
  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  final ScrollController _scrollController = ScrollController();
  late Future<List<CategoryModel>> _categoriesFuture;
  @override
  void initState() {
    super.initState();
    _categoriesFuture = CategoryService().fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackgroundPattern(),
        Positioned.fill(
          child: FutureBuilder<List<CategoryModel>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return EmptyStates().loadingData();
              } else if (snapshot.hasError) {
                return EmptyStates().errorData(snapshot.hasError.toString());
              } else if (snapshot.hasData) {
                final categories = snapshot.data!;
                final int length = categories.length;
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: length,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == length - 1 ? 100 : 1,
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
                return EmptyStates().noCategoriesAvailable();
              }
            },
          ),
        ),
      ],
    );
  }
}
