import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DirectMessagesSkeleton extends StatelessWidget {
  const DirectMessagesSkeleton({super.key});

  static const Color _skeletonColor = Color(0xFF21212F);
  static const Color _shimmerColor = Color(0xFF343449);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _skeletonColor,
      highlightColor: _shimmerColor,
      period: const Duration(milliseconds: 800),
      child: const ListTile(
        contentPadding: EdgeInsets.all(15),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: _skeletonColor,
        ),
        title: Expanded(
          child: SizedBox(
            height: 20,
            width: 100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _skeletonColor,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
