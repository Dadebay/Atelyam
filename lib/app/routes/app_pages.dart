import 'package:get/get.dart';

import '../modules/auth_view/bindings/auth_binding.dart';
import '../modules/auth_view/views/auth_view.dart';
import '../modules/auth_view/views/connection_check_view.dart';
import '../modules/category_view/views/category_view.dart';
import '../modules/discovery_view/bindings/discovery_binding.dart';
import '../modules/discovery_view/views/discovery_view.dart';
import '../modules/home_view/bindings/home_binding.dart';
import '../modules/home_view/views/home_view.dart';
import '../modules/settings_view/bindings/settings_binding.dart';
import '../modules/settings_view/views/favorites_view.dart';
import '../modules/settings_view/views/settings_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: _Paths.CONNECTIONCHECKVIEW,
      page: () => ConnectionCheckView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.HOMEVIEW,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.DISCOVERY,
      page: () => DiscoveryView(),
      binding: DiscoveryBinding(),
    ),
    GetPage(
      name: _Paths.FAVORITES,
      page: () => FavoritesView(),
    ),
    GetPage(
      name: _Paths.CATEGORY,
      page: () => CategoryView(),
    ),
  ];
}
