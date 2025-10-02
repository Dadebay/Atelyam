import 'package:atelyam/app/product/custom_widgets/index.dart';

class BusinessUserCard extends StatelessWidget {
  const BusinessUserCard({
    required this.businessUserModel, required this.productModel, required this.businessUserID, Key? key,
  }) : super(key: key);

  final BusinessUserModel businessUserModel;
  final ProductModel productModel;
  final String? businessUserID;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (productModel.user.toString() == businessUserID.toString()) {
          Get.back();
        } else {
          Get.to(
            () => BusinessUserProfileView(
              categoryID: businessUserModel.userID!,
              businessUserModelFromOutside: businessUserModel,
              whichPage: 'popular',
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: ColorConstants.whiteMainColor,
          borderRadius: BorderRadii.borderRadius25,
          boxShadow: [
            BoxShadow(
              color: ColorConstants.kThirdColor.withOpacity(0.4),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
          border:
              Border.all(color: ColorConstants.kPrimaryColor.withOpacity(.2)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.only(right: 15),
              child: ClipRRect(
                borderRadius: BorderRadii.borderRadius99,
                child: WidgetsMine()
                    .customCachedImage(businessUserModel.backPhoto),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    businessUserModel.businessName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorConstants.darkMainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppFontSizes.fontSize20 - 2,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    businessUserModel.address.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorConstants.darkMainColor.withOpacity(.6),
                      fontWeight: FontWeight.w600,
                      fontSize: AppFontSizes.fontSize16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
