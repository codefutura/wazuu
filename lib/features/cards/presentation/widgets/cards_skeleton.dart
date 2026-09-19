import 'package:flutter/material.dart';

import '../../../../core/widgets/skeleton_box.dart';

class CardsSkeleton extends StatelessWidget {
  const CardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonBox(width: 130, height: 18),
                SkeletonBox(width: 90, height: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SkeletonBox(height: 220, borderRadius: 16),
      ],
    );
  }
}
