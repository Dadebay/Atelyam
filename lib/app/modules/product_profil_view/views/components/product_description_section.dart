import 'package:atelyam/app/product/custom_widgets/index.dart';

class ProductDescriptionSection extends StatelessWidget {
  const ProductDescriptionSection({
    required this.productModel,
    Key? key,
  }) : super(key: key);

  final ProductModel productModel;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(12).copyWith(bottom: 80),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          productModel.description.isEmpty
              ? const SizedBox.shrink()
              : Text(
                  'info_product'.tr,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: AppFontSizes.fontSize20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 14),
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "product_name".tr + ": ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: AppFontSizes.fontSize20,
                    ),
                  ),
                  TextSpan(
                    text: productModel.name,
                    style: TextStyle(
                      color: ColorConstants.darkMainColor,
                      fontWeight: FontWeight.w600,
                      fontSize: AppFontSizes.fontSize20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            productModel.description,
            style: TextStyle(
              color: Colors.grey,
              fontSize: AppFontSizes.fontSize16,
              fontWeight: FontWeight.w400,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 15),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: ColorConstants.kSecondaryColor,
              borderRadius: BorderRadii.borderRadius15,
            ),
            child: Text(
              '${'sold'.tr} - ${productModel.price.substring(0, productModel.price.length - 3)} TMT',
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ColorConstants.whiteMainColor,
                fontWeight: FontWeight.bold,
                fontSize: AppFontSizes.fontSize20,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
