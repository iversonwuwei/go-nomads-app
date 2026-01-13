import 'package:flutter/material.dart';
import 'base_skeleton.dart';

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
        padding: const EdgeInsets.all(16),
        itemCount: itemCount + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            return _InnovationHeaderSkeleton();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
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
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // Title
          SkeletonBox(width: 200, height: 28),
          SizedBox(height: 8),
          // Subtitle
          SkeletonBox(width: 280, height: 16),
          SizedBox(height: 16),
          // Filter chips
          Row(
            children: [
              SkeletonBox(width: 80, height: 32, borderRadius: 16),
              SizedBox(width: 8),
              SkeletonBox(width: 100, height: 32, borderRadius: 16),
              SizedBox(width: 8),
              SkeletonBox(width: 90, height: 32, borderRadius: 16),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // Cover image (16:9)
          SkeletonBox(
            width: double.infinity,
            height: 200,
            borderRadius: 0,
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project name
                SkeletonBox(width: 180, height: 24),
                SizedBox(height: 12),
                // Elevator pitch (2 lines)
                SkeletonBox(width: double.infinity, height: 16),
                SizedBox(height: 6),
                SkeletonBox(width: 240, height: 16),
                SizedBox(height: 16),
                // Tags
                Row(
                  children: [
                    SkeletonBox(width: 70, height: 24, borderRadius: 4),
                    SizedBox(width: 8),
                    SkeletonBox(width: 90, height: 24, borderRadius: 4),
                    SizedBox(width: 8),
                    SkeletonBox(width: 80, height: 24, borderRadius: 4),
                  ],
                ),
                SizedBox(height: 16),
                // Creator info
                Row(
                  children: [
                    SkeletonCircle(size: 32),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 100, height: 14),
                        SizedBox(height: 4),
                        SkeletonBox(width: 80, height: 12),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: SkeletonBox(
                        width: double.infinity,
                        height: 40,
                        borderRadius: 8,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: SkeletonBox(
                        width: double.infinity,
                        height: 40,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            SkeletonBox(
              width: double.infinity,
              height: 220,
              borderRadius: 16,
            ),
            SizedBox(height: 20),
            // Project name
            SkeletonBox(width: 250, height: 28),
            SizedBox(height: 12),
            // Elevator pitch
            SkeletonBox(width: double.infinity, height: 18),
            SizedBox(height: 6),
            SkeletonBox(width: 300, height: 18),
            SizedBox(height: 20),
            // Tags
            Row(
              children: [
                SkeletonBox(width: 80, height: 28, borderRadius: 14),
                SizedBox(width: 8),
                SkeletonBox(width: 100, height: 28, borderRadius: 14),
                SizedBox(width: 8),
                SkeletonBox(width: 90, height: 28, borderRadius: 14),
              ],
            ),
            SizedBox(height: 24),
            // Section title
            SkeletonBox(width: 120, height: 20),
            SizedBox(height: 12),
            // Description
            SkeletonBox(width: double.infinity, height: 16),
            SizedBox(height: 6),
            SkeletonBox(width: double.infinity, height: 16),
            SizedBox(height: 6),
            SkeletonBox(width: 280, height: 16),
            SizedBox(height: 24),
            // Creator section
            SkeletonBox(width: 100, height: 20),
            SizedBox(height: 12),
            Row(
              children: [
                SkeletonCircle(size: 48),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 120, height: 18),
                    SizedBox(height: 6),
                    SkeletonBox(width: 180, height: 14),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),
            // Key features section
            SkeletonBox(width: 140, height: 20),
            SizedBox(height: 12),
            _FeatureItemSkeleton(),
            _FeatureItemSkeleton(),
            _FeatureItemSkeleton(),
            SizedBox(height: 24),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SkeletonBox(
                    width: double.infinity,
                    height: 48,
                    borderRadius: 12,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SkeletonBox(
                    width: double.infinity,
                    height: 48,
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
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SkeletonBox(width: 24, height: 24),
          SizedBox(width: 12),
          Expanded(child: SkeletonBox(width: double.infinity, height: 16)),
        ],
      ),
    );
  }
}
