import 'dart:io';
import '../custom_widgets/index.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

@immutable
class AppStartInit {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = MyHttpOverrides();
    await GetStorage.init();
    Get.put(AuthController());
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final localNotificationsService = LocalNotificationsService.instance();
    await localNotificationsService.init();

    final firebaseMessagingService = FirebaseMessagingService.instance();
    await firebaseMessagingService.init(localNotificationsService: localNotificationsService);

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemStatusBarContrastEnforced: true,
        systemNavigationBarContrastEnforced: true,
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    );
  }
}
