import 'package:atelyam/app/modules/home_view/components/business_category_view/business_user_card_view.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';

class AllBusinessUsersView extends StatelessWidget {
  final int categoryId;

  AllBusinessUsersView({required this.categoryId, super.key});

  @override
  Widget build(BuildContext context) {
    print(categoryId);

    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      appBar: AppBar(
          title: Text(
            'commecial_users'.tr,
            style: TextStyle(
              color: Colors.black,
              fontSize: AppFontSizes.fontSize20,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(IconlyLight.arrow_left_circle),
          ),
          backgroundColor: ColorConstants.whiteMainColor,),
      body: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: FutureBuilder<List<BusinessUserModel>?>(
          future: BusinessUserService()
              .getBusinessAccountsByCategory(categoryID: categoryId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return EmptyStates().loadingData();
            } else if (snapshot.hasError) {
              return EmptyStates().errorData(snapshot.hasError.toString());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return EmptyStates().noDataAvailablePage(
                textColor: ColorConstants.whiteMainColor,
              );
            } else {
              final List<BusinessUserModel> categories = snapshot.data!;
              return GridView.builder(
                itemCount: categories.length,
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (BuildContext context, index) {
                  return BusinessUsersCardView(
                    category: categories[index],
                    categoryID: categoryId,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
