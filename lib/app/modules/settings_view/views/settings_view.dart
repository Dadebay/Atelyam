import 'package:atelyam/app/data/service/auth_service.dart';
import 'package:atelyam/app/modules/home_view/views/bottom_nav_bar_view.dart';
import 'package:atelyam/app/modules/settings_view/components/settings_button.dart';
import 'package:atelyam/app/modules/settings_view/views/all_added_products_view.dart';
import 'package:atelyam/app/modules/settings_view/views/all_business_accounts_view.dart';
import 'package:atelyam/app/modules/settings_view/views/business_acc_components_view/edit_business_account_view.dart';
import 'package:atelyam/app/modules/settings_view/views/business_profile_settings_view.dart';
import 'package:atelyam/app/modules/settings_view/views/product_components/create_product.view.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/initialize/local_notifications_service.dart';
import 'package:hugeicons/hugeicons.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final NewSettingsPageController settingsController = Get.put<NewSettingsPageController>(NewSettingsPageController());

  late Future<List<GetMyStatusModel>?> _bizFuture;
  late Future<String?> _tokenFuture;

  @override
  void initState() {
    super.initState();
    _bizFuture = BusinessUserService().getMyStatus();
    _tokenFuture = Auth().getToken();

    // After a fresh login the new BottomNavBar is built and then justLoggedIn
    // is set to true via postFrameCallback – refresh business status at that point.
    ever(Get.find<AuthController>().justLoggedIn, (bool value) {
      if (value && mounted) {
        _refreshBiz();
        Get.find<AuthController>().justLoggedIn.value = false;
      }
    });
  }

  // ─── Refresh ──────────────────────────────────────────────────────────────
  void _refreshBiz() {
    setState(() {
      _bizFuture = BusinessUserService().getMyStatus();
    });
  }

  // ─── App Bars ─────────────────────────────────────────────────────────────
  AppBar _businessAppBar(GetMyStatusModel bu) {
    return AppBar(
      backgroundColor: ColorConstants.whiteMainColor,
      elevation: 0,
      title: Text(
        'business_accounts_profil'.tr,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () async {
            Get.to(() => AllProductView());
          },
          icon: Icon(HugeIcons.strokeRoundedAddCircle, color: ColorConstants.kPrimaryColor, size: 23),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        IconButton(
          onPressed: () async {
            await Get.to(() => AllBusinessAccountsView());
            _refreshBiz();
          },
          icon: const Icon(HugeIcons.strokeRoundedUserEdit01, color: Colors.black, size: 22),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        IconButton(
          onPressed: () => Get.to(() => _SettingsListPage(settingsController: settingsController, showBackButton: true)),
          icon: const Icon(IconlyLight.setting, color: Colors.black, size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  // ─── Scaffolds ────────────────────────────────────────────────────────────
  Widget _loadingScaffold() {
    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      body: EmptyStates().loadingData(),
    );
  }

  Widget _guestScaffold() {
    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.whiteMainColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'profil'.tr,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: _GuestSettingsPage(settingsController: settingsController),
    );
  }

  Widget _businessScaffold(GetMyStatusModel bu) {
    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      appBar: _businessAppBar(bu),
      body: BusinessProfileSettingsView(businessUser: bu),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _tokenFuture,
      builder: (context, tokenSnap) {
        if (tokenSnap.connectionState == ConnectionState.waiting) return _loadingScaffold();

        final bool isLoggedIn = tokenSnap.data != null && tokenSnap.data!.isNotEmpty;
        if (!isLoggedIn) return _guestScaffold();

        return FutureBuilder<List<GetMyStatusModel>?>(
          future: _bizFuture,
          builder: (context, bizSnap) {
            if (bizSnap.connectionState == ConnectionState.waiting) return _loadingScaffold();

            final GetMyStatusModel? bu = bizSnap.data?.isNotEmpty == true ? bizSnap.data!.first : null;
            if (bu != null) return _businessScaffold(bu);

            // Logged in, no business account → settings list
            return _SettingsListPage(settingsController: settingsController, showBackButton: false);
          },
        );
      },
    );
  }
}

// ── Logged-in settings page (used by both non-business and business settings icon) ──
class _SettingsListPage extends StatelessWidget {
  final NewSettingsPageController settingsController;
  final bool showBackButton;
  const _SettingsListPage({required this.settingsController, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.kSecondaryColor,
        elevation: 0,
        centerTitle: true,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(IconlyLight.arrow_left_circle, color: Colors.white),
                onPressed: () => Get.back(),
              )
            : null,
        title: Text(
          'settings'.tr,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: showBackButton ? loggedInSettingsViewsBusinessaccountHave.length : loggedInSettingsViews.length,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = showBackButton ? loggedInSettingsViewsBusinessaccountHave[index] : loggedInSettingsViews[index];
          final bool isLogoutRow = item['name'] == 'logout';

          if (isLogoutRow) {
            return SettingsButton(
              name: 'logout'.tr,
              lang: false,
              onTap: () {
                Get.dialog(
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadii.borderRadius20,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadii.borderRadius20,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: ColorConstants.kSecondaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(IconlyLight.logout, color: ColorConstants.kSecondaryColor, size: 28),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'logout'.tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.darkMainColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'logout_confirm'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Get.back(),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.grey.shade300),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadii.borderRadius10),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: Text(
                                      'no'.tr,
                                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Get.back();
                                      await Auth().logout();
                                      await Get.offAll(() => BottomNavBar());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorConstants.kSecondaryColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadii.borderRadius10),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: Text(
                                      'yes'.tr,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              icon: Icon(IconlyLight.logout, color: ColorConstants.darkMainColor),
            );
          }


          return SettingsButton(
            name: '${item['name']}'.tr,
            lang: item['name'] == 'lang',
            onTap: () {
              if (item['name'] == 'lang') {
                settingsController.showLanguageDialog(context);
              } else {
                Get.to(item['page']);
              }
            },
            icon: Icon(item['icon'], color: ColorConstants.kSecondaryColor),
          );
        },
      ),
    );
  }
}

// ── Guest (not logged-in) Settings — original design ─────────────────────────
class _GuestSettingsPage extends StatelessWidget {
  final NewSettingsPageController settingsController;
  const _GuestSettingsPage({required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: settingsViews.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 0),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        final item = settingsViews[index];
        return SettingsButton(
          name: "${item['name']}".tr,
          lang: item['name'] == 'lang',
          onTap: () {
            if (item['name'] == 'lang') {
              settingsController.showLanguageDialog(context);
            } else {
              Get.to(item['page']);
            }
          },
          icon: Icon(
            item['icon'],
            color: ColorConstants.kSecondaryColor,
          ),
        );
      },
    );
  }
}
