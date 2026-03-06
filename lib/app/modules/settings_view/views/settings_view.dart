import 'package:atelyam/app/data/service/auth_service.dart';
import 'package:atelyam/app/modules/home_view/views/bottom_nav_bar_view.dart';
import 'package:atelyam/app/modules/settings_view/components/settings_button.dart';
import 'package:atelyam/app/modules/settings_view/views/business_acc_components_view/edit_business_account_view.dart';
import 'package:atelyam/app/modules/settings_view/views/business_profile_settings_view.dart';
import 'package:atelyam/app/modules/settings_view/views/product_components/create_product.view.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
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

  @override
  void initState() {
    super.initState();
    _bizFuture = BusinessUserService().getMyStatus();
  }

  // ─── Refresh ──────────────────────────────────────────────────────────────
  void _refreshBiz() => setState(() => _bizFuture = BusinessUserService().getMyStatus());

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
            Get.to(() => CreateProductView());
          },
          icon: Icon(HugeIcons.strokeRoundedAddCircle, color: ColorConstants.kPrimaryColor, size: 23),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        IconButton(
          onPressed: () async {
            final result = await Get.to(() => EditBusinessAccountView(businessUser: bu));
            if (result == true) _refreshBiz();
          },
          icon: const Icon(HugeIcons.strokeRoundedUserEdit01, color: Colors.black, size: 22),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        IconButton(
          onPressed: () => Get.to(() => _SettingsListPage(settingsController: settingsController)),
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
          'settings'.tr,
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
      future: Auth().getToken(),
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
            return _SettingsListPage(settingsController: settingsController);
          },
        );
      },
    );
  }
}

// ── Logged-in settings page (used by both non-business and business settings icon) ──
class _SettingsListPage extends StatelessWidget {
  final NewSettingsPageController settingsController;
  const _SettingsListPage({required this.settingsController});

  void _showDeleteAccountSheet() {
    Get.bottomSheet(
      Dialogs().deleteAccount(
        onYestapped: () async {
          await Auth().logout();
          Get.back();
          await Get.offAll(() => BottomNavBar());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.kSecondaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(IconlyLight.arrow_left_circle, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'settings'.tr,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: loggedInSettingsViews.length,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = loggedInSettingsViews[index];
          final bool isDeleteRow = item['name'] == 'login';

          if (isDeleteRow) {
            return SettingsButton(
              name: 'delete_account'.tr,
              lang: false,
              onTap: _showDeleteAccountSheet,
              icon: Icon(IconlyLight.delete, color: ColorConstants.kSecondaryColor),
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
