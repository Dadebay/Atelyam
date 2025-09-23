import 'package:atelyam/app/modules/auth_view/views/connection_check_view.dart';
import 'package:atelyam/app/product/initialize/app_start_init.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:atelyam/app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  await AppStartInit.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GetStorage storage = GetStorage();

  Locale getLocale() {
    final String? langCode = storage.read('langCode');
    if (langCode != null) {
      return Locale(langCode);
    } else {
      return const Locale('tm');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MediaQuery(
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
        child: child!,
      ),
      title: Assets.appName,
      theme: AppThemes.lightTheme,
      fallbackLocale: const Locale('tr'),
      locale: getLocale(),
      translations: MyTranslations(),
      defaultTransition: Transition.fadeIn,
      home: ConnectionCheckView(),
    );
  }
}
