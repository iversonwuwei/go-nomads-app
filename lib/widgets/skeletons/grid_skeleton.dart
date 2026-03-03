import 'package:flutter/material.dart';

import 'base_skeleton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.w,
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
          SkeletonBox(
            width: double.infinity,
            height: 140.h,
            borderRadius: 12,
          ),
          SizedBox(height: 12.h),
          SkeletonBox(
            width: double.infinity,
            height: 16.h,
            borderRadius: 4,
          ),
          SizedBox(height: 8.h),
          SkeletonBox(
            width: 100.w,
            height: 14.h,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}
