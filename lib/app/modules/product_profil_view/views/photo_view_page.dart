// ignore_for_file: file_names, void_checks, always_use_package_imports

import 'package:atelyam/app/product/empty_states/empty_states.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewPage extends StatefulWidget {
  final List images;
  final int initialIndex;
  const PhotoViewPage({required this.images, this.initialIndex = 0, Key? key})
      : super(key: key);

  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            CarouselSlider.builder(
              itemCount: widget.images.length,
              itemBuilder: (context, index, count) {
                return PhotoView(
                  minScale: 0.4,
                  maxScale: 2.0,
                  imageProvider: NetworkImage(
                    widget.images[index],
                  ),
                  tightMode: false,
                  loadingBuilder: (context, url) => EmptyStates().loadingData(),
                  errorBuilder: (context, url, error) =>
                      EmptyStates().noMiniCategoryImage(),
                );
              },
              options: CarouselOptions(
                initialPage: widget.initialIndex,
                viewportFraction: 1.0,
                autoPlay: true,
                height: Get.size.height,
                aspectRatio: 4 / 2,
                scrollPhysics: const BouncingScrollPhysics(),
                autoPlayCurve: Curves.fastLinearToSlowEaseIn,
                autoPlayAnimationDuration: const Duration(milliseconds: 2000),
              ),
            ),
            Positioned(
              right: 20.0,
              top: 20.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(CupertinoIcons.xmark_circle,
                    color: Colors.white, size: 40,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
