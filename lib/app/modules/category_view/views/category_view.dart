import '../../../product/custom_widgets/index.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});
  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  late Future<List<CategoryModel>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = CategoryService().fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryModel>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return EmptyStates().loadingData();
        } else if (snapshot.hasError) {
          return EmptyStates().errorData(snapshot.error.toString());
        } else if (snapshot.hasData) {
          final categories = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: categories.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: index == categories.length - 1 ? 16 : 8),
                child: CategoryCard(
                  categoryModel: categories[index],
                  onTap: () {
                    Get.to(() => CategoryProductView(categoryModel: categories[index]));
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
    );
  }
}
