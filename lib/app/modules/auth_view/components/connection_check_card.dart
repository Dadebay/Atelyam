import 'package:flutter/material.dart';

class ConnectionCheckImageCard extends StatelessWidget {
  final String image;

  const ConnectionCheckImageCard({required this.image, super.key});
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.9),
              spreadRadius: 2,
              blurRadius: 12,
            ),
          ],
          borderRadius: BorderRadius.circular(25),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Image(
            image: AssetImage(image),
            fit: BoxFit.cover,
            gaplessPlayback: true, // Smooth image transitions
            filterQuality: FilterQuality.low, // Faster rendering
          ),
        ),
      ),
    );
  }
}
