import 'package:flutter/material.dart';
import 'package:pulse/core/widgets/shimmer.dart';

class ExpensesSkeleton extends StatelessWidget {
  const ExpensesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 150, height: 14),
            const SizedBox(height: 12),
            const SkeletonBox(width: 190, height: 26),
            const SizedBox(height: 22),
            const SkeletonBox(height: 176, radius: 20),
            const SizedBox(height: 30),
            const SkeletonBox(width: 110, height: 18),
            const SizedBox(height: 14),
            for (var i = 0; i < 5; i++) const _TileSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _TileSkeleton extends StatelessWidget {
  const _TileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SkeletonBox(width: 44, height: 44, radius: 22),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 130, height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: 90, height: 12),
              ],
            ),
          ),
          SkeletonBox(width: 80, height: 14),
        ],
      ),
    );
  }
}
