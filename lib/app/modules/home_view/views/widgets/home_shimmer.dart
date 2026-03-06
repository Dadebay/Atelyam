import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Full-page shimmer shown while all home futures are loading.
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  static const Color _base = Color(0xFFE0E0E0);
  static const Color _highlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BannerShimmer(),
            _CategoryRowShimmer(),
            _BusinessUsersShimmer(),
            _ProductsShimmer(),
          ],
        ),
      ),
    );
  }
}

// ── Banner ────────────────────────────────────────────────────────────────────
class BannerShimmer extends StatelessWidget {
  const BannerShimmer({super.key});

  static const Color _base = Color(0xFFE0E0E0);
  static const Color _highlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      child: Container(
        margin: const EdgeInsets.all(15),
        height: 210,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

// ── Category row ─────────────────────────────────────────────────────────────
class _CategoryRowShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
          child: Container(width: 160, height: 20, decoration: _pill()),
        ),
        Container(
          height: 110,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const CategoryShimmer(),
        ),
      ],
    );
  }
}

/// Standalone shimmer for the category pills row – used inside BusinessCategoryView.
class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  static const Color _base = Color(0xFFE0E0E0);
  static const Color _highlight = Color(0xFFF5F5F5);

  // varying text-bar widths to mimic real labels
  static const List<double> _textWidths = [60, 80, 55, 90, 70, 65];

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _textWidths.length,
        itemBuilder: (_, i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 14),
          padding: const EdgeInsets.only(left: 6, right: 12, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(right: 10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              Container(
                width: _textWidths[i],
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Business users carousel ───────────────────────────────────────────────────
class BusinessUsersShimmer extends StatelessWidget {
  const BusinessUsersShimmer({super.key});

  static const Color _base = Color(0xFFE0E0E0);
  static const Color _highlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      child: _BusinessUsersShimmer(),
    );
  }
}

class _BusinessUsersShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.43;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // section title placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(width: 180, height: 18, decoration: _pill()),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, __) => Container(
                width: MediaQuery.of(context).size.width * 0.65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Products grid ─────────────────────────────────────────────────────────────
class _ProductsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(2, (_) => _productSection()),
      ),
    );
  }

  Widget _productSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // section title
          Container(width: 120, height: 18, decoration: _pill()),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              2,
              (i) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
                  height: i == 0 ? 230 : 200,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

BoxDecoration _pill() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    );
