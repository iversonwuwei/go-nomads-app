import 'package:flutter/material.dart';

import 'base_skeleton.dart';

/// 社区内容骨架屏组件
class CommunitySkeleton extends BaseSkeleton {
  const CommunitySkeleton({super.key});

  @override
  State<CommunitySkeleton> createState() => _CommunitySkeletonState();
}

class _CommunitySkeletonState extends BaseSkeletonState<CommunitySkeleton> {
  @override
  Widget buildSkeleton(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildCommunityPostCard();
      },
    );
  }

  Widget _buildCommunityPostCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: SkeletonCard(
        shimmerController: shimmerController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息头部
            Row(
              children: [
                SkeletonCircle(
                  shimmerController: shimmerController,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        shimmerController: shimmerController,
                        width: 120,
                        height: 14,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 6),
                      SkeletonBox(
                        shimmerController: shimmerController,
                        width: 180,
                        height: 12,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ),
                SkeletonBox(
                  shimmerController: shimmerController,
                  width: 50,
                  height: 28,
                  borderRadius: 6,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 内容图片
            SkeletonBox(
              shimmerController: shimmerController,
              width: double.infinity,
              height: 200,
              borderRadius: 12,
            ),
            const SizedBox(height: 16),

            // 标题
            SkeletonBox(
              shimmerController: shimmerController,
              width: double.infinity,
              height: 18,
              borderRadius: 4,
            ),
            const SizedBox(height: 8),

            // 内容
            SkeletonBox(
              shimmerController: shimmerController,
              width: double.infinity,
              height: 14,
              borderRadius: 4,
            ),
            const SizedBox(height: 6),
            SkeletonBox(
              shimmerController: shimmerController,
              width: double.infinity,
              height: 14,
              borderRadius: 4,
            ),
            const SizedBox(height: 6),
            SkeletonBox(
              shimmerController: shimmerController,
              width: 250,
              height: 14,
              borderRadius: 4,
            ),
            const SizedBox(height: 16),

            // 底部统计信息
            Row(
              children: [
                SkeletonBox(
                  shimmerController: shimmerController,
                  width: 60,
                  height: 12,
                  borderRadius: 4,
                ),
                const SizedBox(width: 16),
                SkeletonBox(
                  shimmerController: shimmerController,
                  width: 60,
                  height: 12,
                  borderRadius: 4,
                ),
                const Spacer(),
                SkeletonBox(
                  shimmerController: shimmerController,
                  width: 80,
                  height: 12,
                  borderRadius: 4,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
