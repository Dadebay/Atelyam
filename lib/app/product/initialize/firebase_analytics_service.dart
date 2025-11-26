import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService {
  FirebaseAnalyticsService._internal();
  factory FirebaseAnalyticsService.instance() => _instance;
  static final FirebaseAnalyticsService _instance = FirebaseAnalyticsService._internal();

  late FirebaseAnalytics _analytics;
  late FirebaseAnalyticsObserver _observer;

  FirebaseAnalytics get analytics => _analytics;
  FirebaseAnalyticsObserver get observer => _observer;

  Future<void> init() async {
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
    print('[FirebaseAnalytics] Analytics initialized successfully');
  }

  // Log custom events
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
    print('[FirebaseAnalytics] Event logged: $name');
  }

  // Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
    print('[FirebaseAnalytics] Screen view logged: $screenName');
  }

  // Set user properties
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await _analytics.setUserProperty(
      name: name,
      value: value,
    );
    print('[FirebaseAnalytics] User property set: $name = $value');
  }

  // Set user ID
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
    print('[FirebaseAnalytics] User ID set: $userId');
  }

  // Common e-commerce events
  Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required double price,
    String? category,
    int quantity = 1,
  }) async {
    await _analytics.logAddToCart(
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          price: price,
          itemCategory: category,
          quantity: quantity,
        ),
      ],
    );
    print('[FirebaseAnalytics] Add to cart logged: $itemName');
  }

  Future<void> logPurchase({
    required String transactionId,
    required double value,
    required String currency,
    List<AnalyticsEventItem>? items,
  }) async {
    await _analytics.logPurchase(
      transactionId: transactionId,
      value: value,
      currency: currency,
      items: items,
    );
    print('[FirebaseAnalytics] Purchase logged: $transactionId');
  }

  Future<void> logViewItem({
    required String itemId,
    required String itemName,
    required double price,
    String? category,
  }) async {
    await _analytics.logViewItem(
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          price: price,
          itemCategory: category,
        ),
      ],
    );
    print('[FirebaseAnalytics] View item logged: $itemName');
  }

  Future<void> logBeginCheckout({
    required double value,
    required String currency,
    List<AnalyticsEventItem>? items,
  }) async {
    await _analytics.logBeginCheckout(
      value: value,
      currency: currency,
      items: items,
    );
    print('[FirebaseAnalytics] Begin checkout logged');
  }

  // Login event
  Future<void> logLogin({String? method}) async {
    await _analytics.logLogin(loginMethod: method);
    print('[FirebaseAnalytics] Login logged: $method');
  }

  // Sign up event
  Future<void> logSignUp({String? method}) async {
    await _analytics.logSignUp(signUpMethod: method!);
    print('[FirebaseAnalytics] Sign up logged: $method');
  }

  // Search event
  Future<void> logSearch({required String searchTerm}) async {
    await _analytics.logSearch(searchTerm: searchTerm);
    print('[FirebaseAnalytics] Search logged: $searchTerm');
  }
}
