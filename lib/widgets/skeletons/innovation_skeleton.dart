import 'package:flutter/material.dart';
import 'base_skeleton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Innovation List Skeleton - 创意项目列表骨架屏
/// 使用 shimmer 动画效果
class InnovationListSkeleton extends StatelessWidget {
  final int itemCount;

  const InnovationListSkeleton({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: itemCount + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            return _InnovationHeaderSkeleton();
          }
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _InnovationCardSkeleton(),
          );
        },
      ),
    );
  }
}

/// Innovation Header Skeleton - 创意项目头部骨架
class _InnovationHeaderSkeleton extends StatelessWidget {
  const _InnovationHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          SkeletonBox(width: 200.w, height: 28.h),
          SizedBox(height: 8.h),
          // Subtitle
          SkeletonBox(width: 280.w, height: 16.h),
          SizedBox(height: 16.h),
          // Filter chips
          Row(
            children: [
              SkeletonBox(width: 80.w, height: 32.h, borderRadius: 16),
              SizedBox(width: 8.w),
              SkeletonBox(width: 100.w, height: 32.h, borderRadius: 16),
              SizedBox(width: 8.w),
              SkeletonBox(width: 90.w, height: 32.h, borderRadius: 16),
            ],
          ),
        ],
      ),
    );
  }
}

/// Innovation Card Skeleton - 创意项目卡片骨架
class _InnovationCardSkeleton extends StatelessWidget {
  const _InnovationCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image (16:9)
          SkeletonBox(
            width: double.infinity,
            height: 200.h,
            borderRadius: 0,
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project name
                SkeletonBox(width: 180.w, height: 24.h),
                SizedBox(height: 12.h),
                // Elevator pitch (2 lines)
                SkeletonBox(width: double.infinity, height: 16.h),
                SizedBox(height: 6.h),
                SkeletonBox(width: 240.w, height: 16.h),
                SizedBox(height: 16.h),
                // Tags
                Row(
                  children: [
                    SkeletonBox(width: 70.w, height: 24.h, borderRadius: 4),
                    SizedBox(width: 8.w),
                    SkeletonBox(width: 90.w, height: 24.h, borderRadius: 4),
                    SizedBox(width: 8.w),
                    SkeletonBox(width: 80.w, height: 24.h, borderRadius: 4),
                  ],
                ),
                SizedBox(height: 16.h),
                // Creator info
                Row(
                  children: [
                    SkeletonCircle(size: 32.r),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 100.w, height: 14.h),
                        SizedBox(height: 4.h),
                        SkeletonBox(width: 80.w, height: 12.h),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: SkeletonBox(
                        width: double.infinity,
                        height: 40.h,
                        borderRadius: 8,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SkeletonBox(
                        width: double.infinity,
                        height: 40.h,
                        borderRadius: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Innovation Detail Skeleton - 创意项目详情页骨架屏
class InnovationDetailSkeleton extends StatelessWidget {
  const InnovationDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            SkeletonBox(
              width: double.infinity,
              height: 220.h,
              borderRadius: 16,
            ),
            SizedBox(height: 20.h),
            // Project name
            SkeletonBox(width: 250.w, height: 28.h),
            SizedBox(height: 12.h),
            // Elevator pitch
            SkeletonBox(width: double.infinity, height: 18.h),
            SizedBox(height: 6.h),
            SkeletonBox(width: 300.w, height: 18.h),
            SizedBox(height: 20.h),
            // Tags
            Row(
              children: [
                SkeletonBox(width: 80.w, height: 28.h, borderRadius: 14),
                SizedBox(width: 8.w),
                SkeletonBox(width: 100.w, height: 28.h, borderRadius: 14),
                SizedBox(width: 8.w),
                SkeletonBox(width: 90.w, height: 28.h, borderRadius: 14),
              ],
            ),
            SizedBox(height: 24.h),
            // Section title
            SkeletonBox(width: 120.w, height: 20.h),
            SizedBox(height: 12.h),
            // Description
            SkeletonBox(width: double.infinity, height: 16.h),
            SizedBox(height: 6.h),
            SkeletonBox(width: double.infinity, height: 16.h),
            SizedBox(height: 6.h),
            SkeletonBox(width: 280.w, height: 16.h),
            SizedBox(height: 24.h),
            // Creator section
            SkeletonBox(width: 100.w, height: 20.h),
            SizedBox(height: 12.h),
            Row(
              children: [
                SkeletonCircle(size: 48.r),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 120.w, height: 18.h),
                    SizedBox(height: 6.h),
                    SkeletonBox(width: 180.w, height: 14.h),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.h),
            // Key features section
            SkeletonBox(width: 140.w, height: 20.h),
            SizedBox(height: 12.h),
            _FeatureItemSkeleton(),
            _FeatureItemSkeleton(),
            _FeatureItemSkeleton(),
            SizedBox(height: 24.h),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SkeletonBox(
                    width: double.infinity,
                    height: 48.h,
                    borderRadius: 12,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SkeletonBox(
                    width: double.infinity,
                    height: 48.h,
                    borderRadius: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Feature item skeleton helper
class _FeatureItemSkeleton extends StatelessWidget {
  const _FeatureItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          SkeletonBox(width: 24.w, height: 24.h),
          SizedBox(width: 12.w),
          Expanded(child: SkeletonBox(width: double.infinity, height: 16.h)),
        ],
      ),
    );
  }
}
