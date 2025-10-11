//lib/app/modules/home_view/components/banner/banners.dart
import 'package:atelyam/app/data/models/banner_model.dart';
import 'package:atelyam/app/modules/home_view/components/banners_view/banner_card.dart';
import 'package:atelyam/app/modules/home_view/controllers/home_controller.dart';
import 'package:atelyam/app/product/empty_states/empty_states.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Banners extends StatelessWidget {
  Banners({super.key});

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool sizeValue = size.width >= 800;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => FutureBuilder<List<BannerModel>>(
            future: controller.bannersFuture.value,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return EmptyStates().loadingData();
              } else if (snapshot.hasError) {
                return EmptyStates().errorData(snapshot.hasError.toString());
              } else if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return emptyBanner(size);
                }
                return _buildCarousel(snapshot.data!, sizeValue);
              } else {
                return EmptyStates().noBannersAvailable();
              }
            },
          ),
        ),
        _buildDots(sizeValue, controller),
      ],
    );
  }

  Container emptyBanner(Size size) {
    return Container(
      margin: const EdgeInsets.all(15),
      width: size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadii.borderRadius10,
        boxShadow: [
          BoxShadow(
            color: ColorConstants.kThirdColor.withOpacity(0.2),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadii.borderRadius10,
        child: Image.asset(
          Assets.backgorundPattern2,
          height: size.width >= 800 ? 400 : 220,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCarousel(List<BannerModel> banners, bool sizeValue) {
    return CarouselSlider.builder(
      key: ValueKey(banners.hashCode), // Add a key to help Flutter manage state
      itemCount: banners.length,
      itemBuilder: (context, index, count) {
        return BannerCard(banner: banners[index]);
      },
      options: CarouselOptions(
        onPageChanged: (index, CarouselPageChangedReason a) {
          controller.carouselSelectedIndex.value = index;
        },
        height: sizeValue ? 400 : 210,
        viewportFraction: 1.0,
        autoPlay: true,
        scrollPhysics: const BouncingScrollPhysics(),
        autoPlayCurve: Curves.fastLinearToSlowEaseIn,
        autoPlayAnimationDuration: const Duration(milliseconds: 2000),
      ),
    );
  }

  Widget _buildDots(bool sizeValue, HomeController controller) {
    return SizedBox(
      height: sizeValue ? 40 : 20,
      width: Get.size.width,
      child: Center(
        child: Obx(
          () => FutureBuilder<List<BannerModel>>(
            future: controller.bannersFuture.value,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return const SizedBox();
                }
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDot(index, sizeValue, controller);
                  },
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index, bool sizeValue, HomeController controller) {
    return Obx(
      () => Container(
        margin: EdgeInsets.symmetric(horizontal: sizeValue ? 8 : 4),
        height: controller.carouselSelectedIndex.value == index ? (sizeValue ? 22 : 16) : (sizeValue ? 16 : 10),
        width: controller.carouselSelectedIndex.value == index ? (sizeValue ? 21 : 15) : (sizeValue ? 16 : 10),
        decoration: BoxDecoration(
          color: controller.carouselSelectedIndex.value == index ? Colors.transparent : ColorConstants.kSecondaryColor,
          shape: BoxShape.circle,
          border: controller.carouselSelectedIndex.value == index ? Border.all(color: ColorConstants.kPrimaryColor, width: 3) : Border.all(color: Colors.white),
        ),
      ),
    );
  }
}
