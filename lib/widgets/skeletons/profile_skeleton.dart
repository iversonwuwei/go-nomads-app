import 'package:flutter/material.dart';

import 'base_skeleton.dart';

/// 个人资料页骨架屏组件
class ProfileSkeleton extends BaseSkeleton {
  const ProfileSkeleton({super.key});

  @override
  State<ProfileSkeleton> createState() => _ProfileSkeletonState();
}

class _ProfileSkeletonState extends BaseSkeletonState<ProfileSkeleton> {
  @override
  Widget buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 头像
          _buildAvatar(),
          const SizedBox(height: 16),

          // 用户名
          _buildName(),
          const SizedBox(height: 8),

          // 邮箱或其他信息
          _buildEmail(),
          const SizedBox(height: 24),

          // 统计卡片
          _buildStatsCards(),
          const SizedBox(height: 24),

          // 列表项
          ..._buildListItems(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return SkeletonCircle(
      shimmerController: shimmerController,
      size: 100,
    );
  }

  Widget _buildName() {
    return SkeletonBox(
      shimmerController: shimmerController,
      width: 150,
      height: 20,
      borderRadius: 4,
    );
  }

  Widget _buildEmail() {
    return SkeletonBox(
      shimmerController: shimmerController,
      width: 200,
      height: 16,
      borderRadius: 4,
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: SkeletonCard(
            shimmerController: shimmerController,
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonBox(
                  shimmerController: shimmerController,
                  width: 60,
                  height: 20,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                SkeletonBox(
                  shimmerController: shimmerController,
                  width: 80,
                  height: 14,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SkeletonCard(
            shimmerController: shimmerController,
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonBox(
                  shimmerController: shimmerController,
                  width: 60,
                  height: 20,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                SkeletonBox(
                  shimmerController: shimmerController,
                  width: 80,
                  height: 14,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildListItems() {
    return List.generate(4, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SkeletonCard(
          shimmerController: shimmerController,
          height: 60,
          child: Row(
            children: [
              SkeletonBox(
                shimmerController: shimmerController,
                width: 24,
                height: 24,
                borderRadius: 6,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonBox(
                  shimmerController: shimmerController,
                  width: double.infinity,
                  height: 16,
                  borderRadius: 4,
                ),
              ),
              SkeletonBox(
                shimmerController: shimmerController,
                width: 16,
                height: 16,
                borderRadius: 4,
              ),
            ],
          ),
        ),
      );
    });
  }
}
