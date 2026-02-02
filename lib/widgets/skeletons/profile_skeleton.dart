import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    final isMobile = Get.width < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(isMobile),
          const SizedBox(height: 24),

          // Travel Plans Section (空状态容器)
          _buildTravelPlansSection(),
          const SizedBox(height: 24),

          // Stats Section
          _buildStatsSection(isMobile),
          const SizedBox(height: 24),

          // Badges Section
          _buildBadgesSection(),
          const SizedBox(height: 24),

          // Skills and Interests Section
          _buildSkillsAndInterestsSection(),
          const SizedBox(height: 24),

          // Travel History Section
          _buildTravelHistorySection(),
          const SizedBox(height: 24),

          // Social Links Section
          _buildSocialLinksSection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isMobile) {
    final avatarSize = isMobile ? 80.0 : 120.0;

    return Row(
      children: [
        // 头像
        SkeletonCircle(
          size: avatarSize,
        ),
        const SizedBox(width: 16),

        // 用户信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户名
              SkeletonBox(
                width: isMobile ? 120 : 180,
                height: isMobile ? 20 : 28,
                borderRadius: 4,
              ),
              const SizedBox(height: 8),

              // 邮箱
              SkeletonBox(
                width: isMobile ? 150 : 220,
                height: 14,
                borderRadius: 4,
              ),
              const SizedBox(height: 8),

              // 按钮行
              Row(
                children: [
                  const SkeletonBox(
                    width: 80,
                    height: 32,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 8),
                  const SkeletonBox(
                    width: 80,
                    height: 32,
                    borderRadius: 8,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTravelPlansSection() {
    return SkeletonCard(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SkeletonCircle(
              size: 48,
            ),
            const SizedBox(height: 12),
            const SkeletonBox(
              height: 16,
              borderRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(bool isMobile) {
    final cardWidth = isMobile ? (Get.width - 44) / 2 : null;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(6, (index) {
        return SkeletonCard(
          width: cardWidth,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SkeletonBox(
                width: 40,
                height: 24,
                borderRadius: 4,
              ),
              const SizedBox(height: 8),
              const SkeletonBox(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 标题
        const SkeletonBox(
          width: 100,
          height: 20,
          borderRadius: 4,
        ),
        const SizedBox(height: 12),

        // Badges wrap
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(4, (index) {
            return SkeletonCard(
              width: 80,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SkeletonCircle(
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  const SkeletonBox(
                    width: 60,
                    height: 12,
                    borderRadius: 4,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSkillsAndInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skills 部分
        const SkeletonBox(
          width: 80,
          height: 20,
          borderRadius: 4,
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(5, (index) {
            return SkeletonBox(
              width: 60 + (index * 10.0),
              height: 32,
              borderRadius: 16,
            );
          }),
        ),

        const SizedBox(height: 24),

        // Interests 部分
        const SkeletonBox(
          width: 80,
          height: 20,
          borderRadius: 4,
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(5, (index) {
            return SkeletonBox(
              width: 70 + (index * 8.0),
              height: 32,
              borderRadius: 16,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTravelHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 标题
        const SkeletonBox(
          width: 120,
          height: 20,
          borderRadius: 4,
        ),
        const SizedBox(height: 12),

        // 旅行历史列表项
        ...List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SkeletonCard(
              height: 80,
              child: Row(
                children: [
                  const SkeletonBox(
                    width: 60,
                    height: 60,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SkeletonBox(
                          width: 150,
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
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSocialLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 标题
        const SkeletonBox(
          width: 100,
          height: 20,
          borderRadius: 4,
        ),
        const SizedBox(height: 12),

        // 社交链接按钮
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(4, (index) {
            return const SkeletonBox(
              width: 48,
              height: 48,
              borderRadius: 24,
            );
          }),
        ),
      ],
    );
  }
}
