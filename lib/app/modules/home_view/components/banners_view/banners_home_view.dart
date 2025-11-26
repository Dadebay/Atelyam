import 'package:atelyam/app/data/models/banner_model.dart';
import 'package:atelyam/app/modules/home_view/components/banners_view/banner_card.dart';
import 'package:atelyam/app/modules/home_view/controllers/home_controller.dart';
import 'package:atelyam/app/product/empty_states/empty_states.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Banners extends StatefulWidget {
  const Banners({super.key});

  @override
  State<Banners> createState() => _BannersState();
}

class _BannersState extends State<Banners> {
  final HomeController controller = Get.find<HomeController>();
  int _carouselSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool sizeValue = size.width >= 800;
    return FutureBuilder<List<BannerModel>>(
      future: controller.bannersFuture.value,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return EmptyStates().loadingData();
        } else if (snapshot.hasError) {
          return EmptyStates().errorData(snapshot.hasError.toString());
        } else if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return _emptyBanner(size);
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCarousel(snapshot.data!, sizeValue),
              _buildDots(snapshot.data!, sizeValue),
            ],
          );
        } else {
          return EmptyStates().noBannersAvailable();
        }
      },
    );
  }

  Container _emptyBanner(Size size) {
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
          Assets.backgroundPattern2,
          height: size.width >= 800 ? 400 : 220,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCarousel(List<BannerModel> banners, bool sizeValue) {
    return CarouselSlider.builder(
      key: ValueKey(banners.hashCode),
      itemCount: banners.length,
      itemBuilder: (context, index, count) {
        return BannerCard(banner: banners[index]);
      },
      options: CarouselOptions(
        onPageChanged: (index, reason) {
          setState(() {
            _carouselSelectedIndex = index;
          });
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

  Widget _buildDots(List<BannerModel> banners, bool sizeValue) {
    return SizedBox(
      height: sizeValue ? 40 : 20,
      width: Get.size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(banners.length, (index) => _buildDot(index, sizeValue)),
      ),
    );
  }

  Widget _buildDot(int index, bool sizeValue) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sizeValue ? 8 : 4),
      height: _carouselSelectedIndex == index ? (sizeValue ? 22 : 16) : (sizeValue ? 16 : 10),
      width: _carouselSelectedIndex == index ? (sizeValue ? 21 : 15) : (sizeValue ? 16 : 10),
      decoration: BoxDecoration(
        color: _carouselSelectedIndex == index ? Colors.transparent : ColorConstants.kSecondaryColor,
        shape: BoxShape.circle,
        border: _carouselSelectedIndex == index ? Border.all(color: ColorConstants.kPrimaryColor, width: 3) : Border.all(color: Colors.white),
      ),
    );
  }
}

