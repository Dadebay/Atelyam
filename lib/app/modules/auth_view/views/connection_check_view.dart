import 'dart:async';
import 'dart:math';

import 'package:atelyam/app/data/service/auth_service.dart';
import 'package:atelyam/app/modules/auth_view/components/connection_check_card.dart';
import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/modules/home_view/controllers/business_category_controller.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class ConnectionCheckView extends StatefulWidget {
  @override
  State<ConnectionCheckView> createState() => _ConnectionCheckViewState();
}

class _ConnectionCheckViewState extends State<ConnectionCheckView> {
  final AuthController authController = Get.find<AuthController>();
  final BusinessCategoryController businessCategoryController = Get.put(BusinessCategoryController());
  late List<int> extendedItemList;
  final int itemCount = 29;
  List<String> loadingMessages = ['brandingTitle1', 'brandingTitle2', 'brandingTitle3', 'brandingTitle4', 'brandingTitle5', 'brandingTitle6', 'brandingTitle7', 'brandingTitle8'];
  final ScrollController _scrollController = ScrollController();
  late Timer _scrollTimer;

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollTimer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startAutoScroll();
    SignInService().checkConnection();
    // authController.fetchIpAddress();
  }

  void startAutoScroll() {
    final random = Random();
    final startIndex = random.nextInt(itemCount);
    extendedItemList = List.generate(
      itemCount * 2,
      (index) => (index + startIndex) % itemCount + 1,
    );
    const scrollSpeed = 6.0;
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_scrollController.hasClients) {
        if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 100) {
          _scrollController.jumpTo(
            _scrollController.offset - (_scrollController.position.maxScrollExtent / 2),
          );
        } else {
          _scrollController.animateTo(
            _scrollController.offset + scrollSpeed,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  Positioned gridView() {
    return Positioned.fill(
      child: MasonryGridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: extendedItemList.length,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        itemBuilder: (context, index) {
          return ConnectionCheckImageCard(
            image: 'assets/image/fasonlar/${extendedItemList[index]}.webp',
          );
        },
      ),
    );
  }

  Positioned bottomTextShow(Random random) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 70, bottom: 25, left: 10, right: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.005),
            ],
          ),
        ),
        child: Text(
          loadingMessages[random.nextInt(loadingMessages.length)].tr.toString(),
          style: TextStyle(
            color: Colors.black,
            fontSize: AppFontSizes.getFontSize(5),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          gridView(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 60, bottom: 60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.005),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    Assets.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomTextShow(random),
        ],
      ),
    );
  }
}
