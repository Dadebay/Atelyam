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
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: snapshot.data!.length + 1,
              itemBuilder: (context, index) {
                if (index == snapshot.data!.length) {
                  return Container(
                    height: size.height * 0.10,
                    color: ColorConstants.whiteMainColor,
                  );
                }
                final hashtag = snapshot.data![index];
                return hashtag.count > 0
                    ? ProductListView(
                        size: size,
                        hashtagModel: hashtag,
                        rowIndex: index,
                      )
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
