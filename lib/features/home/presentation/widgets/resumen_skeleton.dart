import 'package:flutter/material.dart';

import '../../../../core/widgets/skeleton_box.dart';

class ResumenSkeleton extends StatelessWidget {
  const ResumenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 140, height: 14),
                const SizedBox(height: 12),
                const SkeletonBox(width: 180, height: 32),
                const SizedBox(height: 12),
                const SkeletonBox(width: 100, height: 14),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                SkeletonBox(height: 24),
                SizedBox(height: 24),
                SkeletonBox(height: 24),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SkeletonBox(width: 160, height: 18),
        const SizedBox(height: 12),
        const SkeletonBox(height: 160, borderRadius: 16),
      ],
    );
  }
}
