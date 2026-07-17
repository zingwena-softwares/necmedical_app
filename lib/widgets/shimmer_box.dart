import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Wraps [child] in a shimmer sweep. Colors adapt to light/dark theme.
class AppShimmer extends StatelessWidget {
  final Widget child;
  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF2C2C30) : const Color(0xFFE4E4E8);
    final highlight = isDark ? const Color(0xFF3C3C40) : const Color(0xFFF6F6F8);
    return Shimmer.fromColors(baseColor: base, highlightColor: highlight, child: child);
  }
}

/// A single solid placeholder block — the building unit for skeleton layouts.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  const ShimmerBox.circle({super.key, required double size})
      : width = size,
        height = size,
        borderRadius = const BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: borderRadius),
    );
  }
}
