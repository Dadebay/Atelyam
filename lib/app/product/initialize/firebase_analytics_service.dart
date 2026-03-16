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

  // ─── Custom events ──────────────────────────────────────────────────────────

  /// Kullanıcı bir ürün kartına tıkladığında (product_click)
  Future<void> logProductClick({
    required String productId,
    required String productName,
    required String price,
    String? categoryId,
    String? businessUserId,
  }) async {
    await _analytics.logEvent(
      name: 'product_click',
      parameters: {
        'product_id': productId,
        'product_name': productName,
        'price': price,
        if (categoryId != null) 'category_id': categoryId,
        if (businessUserId != null) 'business_user_id': businessUserId,
      },
    );
    print('[FirebaseAnalytics] product_click: $productName');
  }

  /// Kullanıcı bir mağaza profiline girdiğinde (view_store)
  Future<void> logViewStore({
    required String storeId,
    required String storeName,
  }) async {
    await _analytics.logEvent(
      name: 'view_store',
      parameters: {
        'store_id': storeId,
        'store_name': storeName,
      },
    );
    print('[FirebaseAnalytics] view_store: $storeName');
  }

  /// Kullanıcı bir kategoriye tıkladığında (view_category)
  Future<void> logViewCategory({
    required String categoryId,
    required String categoryName,
  }) async {
    await _analytics.logEvent(
      name: 'view_category',
      parameters: {
        'category_id': categoryId,
        'category_name': categoryName,
      },
    );
    print('[FirebaseAnalytics] view_category: $categoryName');
  }

  /// Kullanıcı favorilere eklediğinde (add_to_favorites)
  Future<void> logAddToFavorites({
    required String productId,
    required String productName,
    required String price,
  }) async {
    await _analytics.logEvent(
      name: 'add_to_favorites',
      parameters: {
        'product_id': productId,
        'product_name': productName,
        'price': price,
      },
    );
    print('[FirebaseAnalytics] add_to_favorites: $productName');
  }

  /// Kullanıcı favorilerden çıkardığında (remove_from_favorites)
  Future<void> logRemoveFromFavorites({
    required String productId,
    required String productName,
  }) async {
    await _analytics.logEvent(
      name: 'remove_from_favorites',
      parameters: {
        'product_id': productId,
        'product_name': productName,
      },
    );
    print('[FirebaseAnalytics] remove_from_favorites: $productName');
  }

  /// Alt nav bar'da sekme değiştirildiğinde (tab_switched)
  Future<void> logTabSwitch({
    required int tabIndex,
    required String tabName,
  }) async {
    await _analytics.logEvent(
      name: 'tab_switched',
      parameters: {
        'tab_index': tabIndex,
        'tab_name': tabName,
      },
    );
    print('[FirebaseAnalytics] tab_switched: $tabName');
  }

  /// Atelyam Business bölümü açıldığında (open_business_section)
  Future<void> logOpenBusinessSection({required String businessName}) async {
    await _analytics.logEvent(
      name: 'open_business_section',
      parameters: {'business_name': businessName},
    );
    print('[FirebaseAnalytics] open_business_section: $businessName');
  }

  /// Atelyam Business b\u00f6l\u00fcm\u00fc i\u00e7indeki ekran ge\u00e7i\u015fleri (business_screen_view)
  Future<void> logBusinessScreenView({
    required String screenName,
    String? businessName,
  }) async {
    await _analytics.logEvent(
      name: 'business_screen_view',
      parameters: {
        'screen': screenName,
        if (businessName != null) 'business_name': businessName,
      },
    );
    // Ayn\u0131 zamanda standart screen_view olay\u0131n\u0131 da g\u00f6nder
    await _analytics.logScreenView(
      screenName: 'business_$screenName',
      screenClass: 'BusinessNavView',
    );
    print('[FirebaseAnalytics] business_screen_view: $screenName');
  }

  /// Business sekme de\u011fi\u015ftirme (business_tab_switched)
  Future<void> logBusinessTabSwitch({
    required int tabIndex,
    required String tabName,
    String? businessName,
  }) async {
    await _analytics.logEvent(
      name: 'business_tab_switched',
      parameters: {
        'tab_index': tabIndex,
        'tab_name': tabName,
        if (businessName != null) 'business_name': businessName,
      },
    );
    print('[FirebaseAnalytics] business_tab_switched: $tabName');
  }

  /// M\u00fc\u015fteri arama (business_customer_search)
  Future<void> logBusinessCustomerSearch({required String query}) async {
    await _analytics.logEvent(
      name: 'business_customer_search',
      parameters: {'query': query},
    );
    print('[FirebaseAnalytics] business_customer_search: $query');
  }

  /// M\u00fc\u015fteri profiline t\u0131klama (business_customer_tapped)
  Future<void> logBusinessCustomerTapped({
    required String customerName,
    required int orderCount,
    required double totalSpent,
  }) async {
    await _analytics.logEvent(
      name: 'business_customer_tapped',
      parameters: {
        'customer_name': customerName,
        'order_count': orderCount,
        'total_spent': totalSpent,
      },
    );
    print('[FirebaseAnalytics] business_customer_tapped: $customerName');
  }

  /// Sipari\u015f sat\u0131r\u0131na t\u0131klama (business_order_tapped)
  Future<void> logBusinessOrderTapped({
    required String customerName,
    required String status,
    required String amount,
  }) async {
    await _analytics.logEvent(
      name: 'business_order_tapped',
      parameters: {
        'customer_name': customerName,
        'status': status,
        'amount': amount,
      },
    );
    print('[FirebaseAnalytics] business_order_tapped: $customerName - $status');
  }

  /// Business splash a\u00e7\u0131ld\u0131 (business_splash_opened)
  Future<void> logBusinessSplashOpened({required String businessName}) async {
    await _analytics.logEvent(
      name: 'business_splash_opened',
      parameters: {'business_name': businessName},
    );
    print('[FirebaseAnalytics] business_splash_opened: $businessName');
  }
}
