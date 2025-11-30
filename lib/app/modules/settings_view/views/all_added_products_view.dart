import 'package:atelyam/app/data/service/product_service.dart';
import 'package:atelyam/app/modules/settings_view/components/product_card_mine.dart';
import 'package:atelyam/app/modules/settings_view/views/product_components/create_product.view.dart';
import 'package:atelyam/app/modules/settings_view/views/product_components/edit_product_view.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';

class AllProductView extends StatefulWidget {
  AllProductView({super.key});

  @override
  State<AllProductView> createState() => _AllProductViewState();
}

class _AllProductViewState extends State<AllProductView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: ColorConstants.whiteMainColor,
        appBar: _appBar(),
        body: getMyProducts(), // TabBarView kaldırıldı, direkt liste
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: ColorConstants.kSecondaryColor,
      title: Text(
        'add_product'.tr,
        style: TextStyle(
          color: ColorConstants.whiteMainColor,
          fontSize: AppFontSizes.getFontSize(5),
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BackButtonMine(
          miniButton: true,
        ),
      ),
      // TabBar kaldırıldı
    );
  }

  FutureBuilder<List<ProductModel>?> getMyProducts() {
    return FutureBuilder<List<ProductModel>?>(
      future: ProductService().getMyProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return EmptyStates().loadingData();
        } else if (snapshot.hasError) {
          return EmptyStates().errorData(snapshot.error.toString());
        } else if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Column(
              children: [
                Expanded(
                  child: EmptyStates().noDataAvailablePage(
                    textColor: ColorConstants.kPrimaryColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AgreeButton(
                    onTap: () async {
                      final result = await Get.to(() => CreateProductView());
                      if (result == true) {
                        setState(() {});
                      }
                    },
                    text: 'add_product',
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemExtent: 120,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    return MyProductCard(
                      productModel: snapshot.data![index],
                      onTap: () async {
                        final result = await Get.to(
                          () => UpdateProductView(product: snapshot.data![index]),
                        );
                        if (result == true) {
                          setState(() {});
                        }
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AgreeButton(
                  onTap: () async {
                    final result = await Get.to(() => CreateProductView());
                    if (result == true) {
                      setState(() {});
                    }
                  },
                  text: 'add_product',
                ),
              ),
            ],
          );
        }
        return EmptyStates().noDataAvailable();
      },
    );
  }
}
