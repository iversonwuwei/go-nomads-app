import 'package:flutter/material.dart';

import 'base_skeleton.dart';

/// 网格列表骨架屏组件（适用于图片网格等）
class GridSkeleton extends BaseSkeleton {
  final int crossAxisCount;
  final double childAspectRatio;

  const GridSkeleton({
    super.key,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75,
  });

  @override
  State<GridSkeleton> createState() => _GridSkeletonState();
}

class _GridSkeletonState extends BaseSkeletonState<GridSkeleton> {
  @override
  Widget buildSkeleton(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildGridItem();
      },
    );
  }

  Widget _buildGridItem() {
    return SkeletonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(
            width: double.infinity,
            height: 140,
            borderRadius: 12,
          ),
          const SizedBox(height: 12),
          const SkeletonBox(
            width: double.infinity,
            height: 16,
            borderRadius: 4,
          ),
          const SizedBox(height: 8),
          const SkeletonBox(
            width: 100,
            height: 14,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}
