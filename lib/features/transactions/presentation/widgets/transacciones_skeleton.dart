import 'package:flutter/material.dart';

import '../../../../core/widgets/skeleton_box.dart';

class TransaccionesSkeleton extends StatelessWidget {
  const TransaccionesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const SkeletonBox(width: 40, height: 40, borderRadius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(width: 140, height: 14),
                    SizedBox(height: 8),
                    SkeletonBox(width: 90, height: 12),
                  ],
                ),
              ),
              const SkeletonBox(width: 60, height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
