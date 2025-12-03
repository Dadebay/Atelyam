import 'package:atelyam/app/data/service/notification_service.dart';
import 'package:atelyam/app/product/initialize/local_notifications_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._internal();
  factory FirebaseMessagingService.instance() => _instance;
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  LocalNotificationsService? _localNotificationsService;

  Future<void> init({
    required LocalNotificationsService localNotificationsService,
  }) async {
    _localNotificationsService = localNotificationsService;
    await _handlePushNotificationsToken();
    await _requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _handlePushNotificationsToken() async {
    // Get and print current FCM token for testing
    final token = await FirebaseMessaging.instance.getToken();
    print('═══════════════════════════════════════════════════════════');
    print('📱 CURRENT FCM TOKEN:');
    print('$token');
    print('═══════════════════════════════════════════════════════════');

    await NotificationService().sendDeviceToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      NotificationService().sendDeviceToken();
      print('═══════════════════════════════════════════════════════════');
      print('🔄 FCM TOKEN REFRESHED:');
      print('$fcmToken');
      print('═══════════════════════════════════════════════════════════');
    }).onError((error) {
      print('❌ Error refreshing FCM token: $error');
    });
  }

  Future<void> _requestPermission() async {
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${result.authorizationStatus}');
  }

  void _onForegroundMessage(RemoteMessage message) {
    print('Foreground message received: ${message.data.toString()}');
    final notificationData = message.notification;
    if (notificationData != null) {
      _localNotificationsService?.showNotification(
        notificationData.title,
        notificationData.body,
        message.data.toString(),
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    print('Notification caused the app to open: ${message.data.toString()}');
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.data.toString()}');
}
