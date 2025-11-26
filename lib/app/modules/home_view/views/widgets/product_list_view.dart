import '../../../../product/custom_widgets/index.dart';

class ProductListView extends StatelessWidget {
  final Size size;
  final HashtagModel hashtagModel;
  final int rowIndex;
  final HomeController homeController = Get.find<HomeController>();

  ProductListView({
    required this.size,
    required this.hashtagModel,
    required this.rowIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListviewTopNameAndIcon(
          text: hashtagModel.name,
          icon: true,
          onTap: () => Get.to(() => AllProductsView(title: hashtagModel.name, id: hashtagModel.id)),
        ),
        SizedBox(
          height: size.height * 0.45,
          child: FutureBuilder<List<ProductModel>>(
            future: homeController.fetchProductsByHashtagId(hashtagModel.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return EmptyStates().loadingData();
              } else if (snapshot.hasError) {
                return EmptyStates().errorData(snapshot.hasError.toString());
              } else if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemExtent: size.width * 0.55,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return DiscoveryCard(
                      homePageStyle: true,
                      productModel: snapshot.data![index],
                      index: rowIndex,
                    );
                  },
                );
              } else {
                return EmptyStates().noDataAvailable();
              }
            },
          ),
        ),
      ],
    );
  }
}
