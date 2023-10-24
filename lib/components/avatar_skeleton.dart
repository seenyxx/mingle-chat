import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AvatarSkeleton extends StatelessWidget {
  final double radius;

  const AvatarSkeleton({super.key, required this.radius});

  static const Color _skeletonColor = Color(0xFF21212F);
  static const Color _shimmerColor = Color(0xFF343449);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _skeletonColor,
      highlightColor: _shimmerColor,
      period: const Duration(milliseconds: 800),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: _skeletonColor,
      ),
    );
  }
}
