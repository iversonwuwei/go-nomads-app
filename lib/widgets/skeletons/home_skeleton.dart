import 'package:flutter/material.dart';

import 'base_skeleton.dart';

/// 首页骨架屏组件
/// 包含轮播图、快捷功能网格、热门接口等
class HomeSkeleton extends BaseSkeleton {
  const HomeSkeleton({super.key});

  @override
  State<HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends BaseSkeletonState<HomeSkeleton> {
  @override
  Widget buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 轮播图骨架
          _buildBannerSkeleton(),
          const SizedBox(height: 24),

          // 分类标题
          _buildSectionTitle(),
          const SizedBox(height: 16),

          // 快捷功能网格
          _buildQuickActionsGrid(),
          const SizedBox(height: 24),

          // 热门接口标题
          _buildSectionTitle(width: 180),
          const SizedBox(height: 16),

          // API接口网格
          _buildApiGrid(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBannerSkeleton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          SkeletonBox(
            shimmerController: shimmerController,
            width: double.infinity,
            height: 180,
            borderRadius: 12,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                child: SkeletonBox(
                  shimmerController: shimmerController,
                  width: index == 0 ? 24 : 6,
                  height: 6,
                  borderRadius: 3,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({double width = 150}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SkeletonBox(
        shimmerController: shimmerController,
        width: width,
        height: 20,
        borderRadius: 4,
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: List.generate(8, (index) {
          return Column(
            children: [
              SkeletonBox(
                shimmerController: shimmerController,
                width: 48,
                height: 48,
                borderRadius: 12,
              ),
              const SizedBox(height: 8),
              SkeletonBox(
                shimmerController: shimmerController,
                width: 60,
                height: 12,
                borderRadius: 4,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildApiGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: List.generate(4, (index) {
          return SkeletonCard(
            shimmerController: shimmerController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(
                      shimmerController: shimmerController,
                      width: 32,
                      height: 32,
                      borderRadius: 8,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SkeletonBox(
                        shimmerController: shimmerController,
                        width: double.infinity,
                        height: 16,
                        borderRadius: 4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SkeletonBox(
                  shimmerController: shimmerController,
                  width: double.infinity,
                  height: 12,
                  borderRadius: 4,
                ),
                const SizedBox(height: 6),
                SkeletonBox(
                  shimmerController: shimmerController,
                  width: 100,
                  height: 12,
                  borderRadius: 4,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
