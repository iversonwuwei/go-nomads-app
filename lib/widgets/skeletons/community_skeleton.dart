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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息头部
            Row(
              children: [
                const SkeletonCircle(
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonBox(
                        width: 120,
                        height: 14,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 6),
                      const SkeletonBox(
                        width: 180,
                        height: 12,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SkeletonBox(
                  width: 50,
                  height: 28,
                  borderRadius: 6,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 内容图片
            const SkeletonBox(
              width: double.infinity,
              height: 200,
              borderRadius: 12,
            ),
            const SizedBox(height: 16),

            // 标题
            const SkeletonBox(
              width: double.infinity,
              height: 18,
              borderRadius: 4,
            ),
            const SizedBox(height: 8),

            // 内容
            const SkeletonBox(
              width: double.infinity,
              height: 14,
              borderRadius: 4,
            ),
            const SizedBox(height: 6),
            const SkeletonBox(
              width: double.infinity,
              height: 14,
              borderRadius: 4,
            ),
            const SizedBox(height: 6),
            const SkeletonBox(
              width: 250,
              height: 14,
              borderRadius: 4,
            ),
            const SizedBox(height: 16),

            // 底部统计信息
            Row(
              children: [
                const SkeletonBox(
                  width: 60,
                  height: 12,
                  borderRadius: 4,
                ),
                const SizedBox(width: 16),
                const SkeletonBox(
                  width: 60,
                  height: 12,
                  borderRadius: 4,
                ),
                const Spacer(),
                const SkeletonBox(
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
