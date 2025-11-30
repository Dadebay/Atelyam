import 'package:atelyam/app/modules/settings_view/components/business_acc_card.dart';
import 'package:atelyam/app/modules/settings_view/views/business_acc_components_view/create_business_account_view.dart';
import 'package:atelyam/app/modules/settings_view/views/business_acc_components_view/edit_business_account_view.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';

class AllBusinessAccountsView extends StatefulWidget {
  AllBusinessAccountsView({super.key});

  @override
  State<AllBusinessAccountsView> createState() => _AllBusinessAccountsViewState();
}

class _AllBusinessAccountsViewState extends State<AllBusinessAccountsView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: ColorConstants.whiteMainColor,
        appBar: _appBar(),
        body: getBusinessAccounts(),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: ColorConstants.kSecondaryColor,
      title: Text(
        'all_business_accounts'.tr,
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
      // bottom TabBar kaldırıldı
    );
  }

  Widget getBusinessAccounts() {
    return FutureBuilder<List<GetMyStatusModel>?>(
      future: BusinessUserService().getMyStatus(),
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
                      final result = await Get.to(
                        () => CreateBusinessAccountView(),
                      );
                      if (result == true) {
                        setState(() {});
                      }
                    },
                    text: 'add_account',
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemExtent: 120,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return BusinessAccCard(
                businessUser: snapshot.data![index],
                onTap: () async {
                  final result = await Get.to(
                    () => EditBusinessAccountView(
                      businessUser: snapshot.data![index],
                    ),
                  );
                  if (result == true) {
                    setState(() {});
                  }
                },
              );
            },
          );
        }
        return EmptyStates().noDataAvailable();
      },
    );
  }
}
