import 'dart:io';
import '../custom_widgets/index.dart';
import 'firebase_analytics_service.dart';

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

    final firebaseAnalyticsService = FirebaseAnalyticsService.instance();
    await firebaseAnalyticsService.init();

    // Test event - Analytics çalışıyor mu kontrol et
    await firebaseAnalyticsService.logEvent(
      name: 'app_started',
      parameters: {
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
