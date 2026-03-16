import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/modules/business_view/views/business_nav_view.dart';
import 'package:atelyam/app/product/initialize/firebase_analytics_service.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class BusinessSplashView extends StatefulWidget {
  final GetMyStatusModel businessUser;
  const BusinessSplashView({required this.businessUser, super.key});

  @override
  State<BusinessSplashView> createState() => _BusinessSplashViewState();
}

class _BusinessSplashViewState extends State<BusinessSplashView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animController.forward();

    // Analytics: splash açıldı
    FirebaseAnalyticsService.instance().logBusinessSplashOpened(
      businessName: widget.businessUser.businessName ?? '',
    );
    FirebaseAnalyticsService.instance().logBusinessScreenView(
      screenName: 'splash',
      businessName: widget.businessUser.businessName ?? '',
    );

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        Get.off(
          () => BusinessNavView(businessUser: widget.businessUser),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.kPrimaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            SizedBox(
              width: 320,
              height: 320,
              child: Lottie.asset(
                'assets/lottie/businessUserLoading.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),

            // App name
            FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  children: [
                    Text(
                      'Atelyam',
                      style: TextStyle(
                        fontFamily: Fonts.gilroy,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: ColorConstants.kThirdColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Business',
                      style: TextStyle(
                        fontFamily: Fonts.gilroy,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Subtitle
            FadeTransition(
              opacity: _fadeAnim,
              child: Text(
                widget.businessUser.businessName ?? '',
                style: TextStyle(
                  fontFamily: Fonts.gilroy,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white38,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
