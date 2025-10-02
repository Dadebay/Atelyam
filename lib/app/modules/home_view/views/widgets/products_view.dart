import '../../../../product/custom_widgets/index.dart';
import 'product_list_view.dart';

class ProductsView extends StatelessWidget {
  final Size size;
  final HomeController homeController = Get.find<HomeController>();

  ProductsView({
    required this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return FutureBuilder<List<HashtagModel>>(
        future: homeController.hashtagsFuture.value,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return EmptyStates().loadingData();
          } else if (snapshot.hasError) {
            return EmptyStates().errorData(snapshot.hasError.toString());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final hashtag = snapshot.data![index];
                return hashtag.count > 0
                    ? ProductListView(size: size, hashtagModel: hashtag)
                    : const SizedBox.shrink();
              },
            );
          } else {
            return EmptyStates().noDataAvailable();
          }
        },
      );
    });
  }
}
