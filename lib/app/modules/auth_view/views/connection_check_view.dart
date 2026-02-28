import 'dart:math';

import 'package:flutter/scheduler.dart';

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

class _ConnectionCheckViewState extends State<ConnectionCheckView> with SingleTickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final BusinessCategoryController businessCategoryController = Get.put(BusinessCategoryController());
  late List<int> extendedItemList;
  final int itemCount = 29;
  final int loopMultiplier = 30;
  List<String> loadingMessages = ['brandingTitle1', 'brandingTitle2', 'brandingTitle3', 'brandingTitle4', 'brandingTitle5', 'brandingTitle6', 'brandingTitle7', 'brandingTitle8'];
  final ScrollController _scrollController = ScrollController();
  Ticker? _ticker;
  bool _isPreparingGrid = false;
  bool _isGridReady = false;

  @override
  void dispose() {
    _ticker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SignInService().checkConnection();
    // authController.fetchIpAddress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPreparingGrid && !_isGridReady) {
      _prepareGrid();
    }
  }

  Future<void> _prepareGrid() async {
    _isPreparingGrid = true;
    _generateExtendedItems();
    await _precacheImages();
    if (!mounted) return;
    setState(() {
      _isGridReady = true;
    });
    startAutoScroll();
  }

  void _generateExtendedItems() {
    final random = Random();
    final startIndex = random.nextInt(itemCount);
    extendedItemList = List.generate(
      itemCount * loopMultiplier,
      (index) => (index + startIndex) % itemCount + 1,
    );
  }

  Future<void> _precacheImages() async {
    final futures = <Future<void>>[];
    for (int i = 1; i <= itemCount; i++) {
      futures.add(precacheImage(AssetImage('assets/image/fasonlar/$i.webp'), context));
    }
    await Future.wait(futures);
  }

  void startAutoScroll() {
    // 1.5 px/frame @ 60 fps ≈ 90 px/s — smooth vsync-synced scroll
    const double scrollSpeed = 1.5;
    _ticker?.dispose();
    _ticker = createTicker((_) {
      if (!_scrollController.hasClients) return;
      final maxExtent = _scrollController.position.maxScrollExtent;
      if (maxExtent <= 0) return;
      var nextOffset = _scrollController.offset + scrollSpeed;
      if (nextOffset >= maxExtent - 200) {
        nextOffset = maxExtent * 0.2;
      }
      _scrollController.jumpTo(nextOffset);
    });
    _ticker!.start();
  }

  Positioned gridView() {
    return Positioned.fill(
      child: MasonryGridView.builder(
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: extendedItemList.length,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        cacheExtent: 1000,
        itemBuilder: (context, index) {
          return ConnectionCheckImageCard(
            image: 'assets/image/fasonlar/${extendedItemList[index]}.webp',
          );
        },
      ),
    );
  }

  Positioned gridLoadingPlaceholder() {
    return const Positioned.fill(
      child: ColoredBox(
        color: Colors.white,
        child: SizedBox.expand(),
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
          _isGridReady ? gridView() : gridLoadingPlaceholder(),
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
