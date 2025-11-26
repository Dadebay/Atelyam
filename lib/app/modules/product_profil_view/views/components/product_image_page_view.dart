import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:photo_view/photo_view.dart';
import '../photo_view_page.dart';

class ProductImagePageView extends StatefulWidget {
  const ProductImagePageView({
    required this.controller,
    required this.pageController,
  });

  final ProductProfilController controller;
  final PageController pageController;

  @override
  State<ProductImagePageView> createState() => _ProductImagePageViewState();
}

class _ProductImagePageViewState extends State<ProductImagePageView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showHint = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 3 saniye sonra ipucunu gizle
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showHint = false;
        });
        _animationController.stop();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => widget.controller.isLoading.value
          ? EmptyStates().loadingData()
          : Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: PageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: widget.pageController,
                    itemCount: widget.controller.productImages.length,
                    onPageChanged: (index) {
                      widget.controller.updateSelectedImageIndex(index);
                      if (_showHint) {
                        setState(() {
                          _showHint = false;
                        });
                        _animationController.stop();
                      }
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Scroll ipucunu gizle
                          if (_showHint) {
                            setState(() {
                              _showHint = false;
                            });
                            _animationController.stop();
                          }
                          // PhotoViewPage'e geç
                          Get.to(
                            () => PhotoViewPage(
                              images: widget.controller.productImages,
                              initialIndex: index,
                            ),
                          );
                        },
                        child: PhotoView(
                          imageProvider: CachedNetworkImageProvider(widget.controller.productImages.isNotEmpty ? (widget.controller.productImages[index]) : ''),
                          loadingBuilder: (context, event) => EmptyStates().loadingData(),
                          errorBuilder: (context, url, error) => EmptyStates().noMiniCategoryImage(),
                          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                          initialScale: PhotoViewComputedScale.covered,
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 3,
                        ),
                      );
                    },
                  ),
                ),
                // Scroll ipucu
                if (_showHint && widget.controller.productImages.length > 1)
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      opacity: _showHint ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _animation.value),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.keyboard_arrow_up_rounded,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 40,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'swipe_up_hint'.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 40,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
