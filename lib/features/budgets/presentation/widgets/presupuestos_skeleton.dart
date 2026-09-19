import 'package:flutter/material.dart';

import '../../../../core/widgets/skeleton_box.dart';

class PresupuestosSkeleton extends StatelessWidget {
  const PresupuestosSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonBox(width: 120, height: 16),
              SizedBox(height: 12),
              SkeletonBox(height: 8, borderRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
}
