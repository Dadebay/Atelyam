import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/modules/business_view/views/business_currency_controller.dart';
import 'package:atelyam/app/modules/business_view/views/customers/business_customers_page.dart';
import 'package:atelyam/app/modules/business_view/views/business_placeholder_pages.dart';
import 'package:atelyam/app/product/initialize/firebase_analytics_service.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class BusinessNavView extends StatefulWidget {
  final GetMyStatusModel businessUser;
  const BusinessNavView({required this.businessUser, super.key});

  @override
  State<BusinessNavView> createState() => _BusinessNavViewState();
}

class _BusinessNavViewState extends State<BusinessNavView> {
  int _currentIndex = 0; // Start at Customers (index 2 = middle)

  late final List<Widget> _pages;

  static const _tabNames = ['dashboard', 'orders', 'customers', 'finance', 'analytics'];

  @override
  void initState() {
    super.initState();
    Get.put(BusinessCurrencyController());
    // Analytics: business ana ekranı açıldı (customers sekmesinde)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseAnalyticsService.instance().logBusinessScreenView(
        screenName: 'customers',
        businessName: widget.businessUser.businessName ?? '',
      );
    });
    _pages = const [
      BusinessDashboardPage(),
      BusinessOrdersPage(),
      BusinessCustomersPage(), // ← center / main page
      BusinessFinancePage(),
      BusinessAnalyticsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        // Show selected page
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: _BusinessBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            // Analytics: hangi business sekmesine geçildi
            FirebaseAnalyticsService.instance().logBusinessTabSwitch(
              tabIndex: index,
              tabName: _tabNames[index],
              businessName: widget.businessUser.businessName ?? '',
            );
            FirebaseAnalyticsService.instance().logBusinessScreenView(
              screenName: _tabNames[index],
              businessName: widget.businessUser.businessName ?? '',
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<BusinessCurrencyController>();
    super.dispose();
  }
}

// ─── Custom Bottom Navigation Bar ─────────────────────────────────────────────
class _BusinessBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BusinessBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(
      icon: HugeIcons.strokeRoundedDashboardSquare02,
      activeIcon: HugeIcons.strokeRoundedDashboardSquare02,
      label: 'dashboard',
    ),
    _NavItem(
      icon: HugeIcons.strokeRoundedDocumentAttachment,
      activeIcon: HugeIcons.strokeRoundedDocumentAttachment,
      label: 'orders',
    ),
    _NavItem(
      icon: HugeIcons.strokeRoundedUserMultiple,
      activeIcon: HugeIcons.strokeRoundedUserMultiple,
      label: 'customers',
      // isCenterItem: true,
    ),
    _NavItem(
      icon: HugeIcons.strokeRoundedMoneyBag01,
      activeIcon: HugeIcons.strokeRoundedMoneyBag01,
      label: 'finance',
    ),
    _NavItem(
      icon: HugeIcons.strokeRoundedChart01,
      activeIcon: HugeIcons.strokeRoundedChart01,
      label: 'analytics',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = currentIndex == index;

              if (item.isCenterItem) {
                return _CenterNavButton(
                  item: item,
                  isActive: isActive,
                  onTap: () => onTap(index),
                );
              }

              return _RegularNavButton(
                item: item,
                isActive: isActive,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Regular nav button ────────────────────────────────────────────────────────
class _RegularNavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _RegularNavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              size: 22,
              color: isActive ? ColorConstants.kSecondaryColor : Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              item.label.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: Fonts.gilroy,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? ColorConstants.kSecondaryColor : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Center elevated nav button (Customers) ────────────────────────────────────
class _CenterNavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _CenterNavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Elevated circle button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? ColorConstants.kSecondaryColor : Colors.grey.shade200,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: ColorConstants.kSecondaryColor.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                item.icon,
                size: 24,
                color: isActive ? Colors.white : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label.tr,
              style: TextStyle(
                fontFamily: Fonts.gilroy,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? ColorConstants.kSecondaryColor : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Nav item data ─────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isCenterItem;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isCenterItem = false,
  });
}
