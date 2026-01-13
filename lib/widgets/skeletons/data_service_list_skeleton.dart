import 'package:flutter/material.dart';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'base_skeleton.dart';

/// 数据服务页面骨架屏组件 - 匹配实际页面结构
class DataServiceListSkeleton extends BaseSkeleton {
  const DataServiceListSkeleton({super.key});

  @override
  State<DataServiceListSkeleton> createState() =>
      _DataServiceListSkeletonState();
}

class _DataServiceListSkeletonState
    extends BaseSkeletonState<DataServiceListSkeleton> {
  @override
  Widget buildSkeleton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return CustomScrollView(
      slivers: [
        // Hero 区域骨架
        SliverToBoxAdapter(
          child: _buildHeroSkeleton(isMobile),
        ),

        // 搜索栏骨架
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
              vertical: 20,
            ),
            child: _buildSearchBarSkeleton(),
          ),
        ),

        // 工具栏骨架
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
            ),
            child: _buildToolbarSkeleton(),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // 城市卡片网格骨架
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 32,
          ),
          sliver: _buildCityGridSkeleton(isMobile),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),

        // Meetups 部分骨架
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
            ),
            child: _buildMeetupsSkeleton(isMobile),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 60)),

        // 特性列表骨架
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
              vertical: isMobile ? 10 : 20,
            ),
            child: _buildFeaturesSkeleton(isMobile),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  // Hero 区域骨架
  Widget _buildHeroSkeleton(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 48,
            vertical: isMobile ? 40 : 60,
          ),
          child: Column(
            children: [
              // Logo 和标题骨架
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SkeletonBox(
                    width: 56,
                    height: 56,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 16),
                  SkeletonBox(
                    width: 150,
                    height: isMobile ? 32 : 42,
                    borderRadius: 8,
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 24 : 32),

              // 副标题骨架
              SkeletonBox(
                width: isMobile ? 280 : 400,
                height: isMobile ? 18 : 22,
                borderRadius: 4,
              ),
              const SizedBox(height: 8),
              SkeletonBox(
                width: isMobile ? 240 : 350,
                height: isMobile ? 18 : 22,
                borderRadius: 4,
              ),

              SizedBox(height: isMobile ? 32 : 40),

              // 服务卡片骨架
              _buildServiceCardsSkeleton(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  // 服务卡片骨架（2x2 或 1x4 网格）
  Widget _buildServiceCardsSkeleton(bool isMobile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final useGridLayout = screenWidth < 768;

    if (useGridLayout) {
      // 2x2 网格
      return Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: const Column(
          children: [
            Row(
              children: [
                Expanded(child: _CompactCardSkeleton()),
                SizedBox(width: 12),
                Expanded(child: _CompactCardSkeleton()),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _CompactCardSkeleton()),
                SizedBox(width: 12),
                Expanded(child: _CompactCardSkeleton()),
              ],
            ),
          ],
        ),
      );
    } else {
      // 1x4 横向布局
      return Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: const Row(
          children: [
            Expanded(child: _CompactCardSkeleton()),
            SizedBox(width: 12),
            Expanded(child: _CompactCardSkeleton()),
            SizedBox(width: 12),
            Expanded(child: _CompactCardSkeleton()),
            SizedBox(width: 12),
            Expanded(child: _CompactCardSkeleton()),
          ],
        ),
      );
    }
  }

  // 搜索栏骨架
  Widget _buildSearchBarSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: const Row(
        children: [
          SkeletonBox(
            width: 20,
            height: 20,
            borderRadius: 4,
          ),
          SizedBox(width: 12),
          Expanded(
            child: SkeletonBox(
              height: 14,
              borderRadius: 4,
            ),
          ),
          SizedBox(width: 12),
          SkeletonBox(
            width: 34,
            height: 34,
            borderRadius: 17,
          ),
        ],
      ),
    );
  }

  // 工具栏骨架
  Widget _buildToolbarSkeleton() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SkeletonBox(
          width: 80,
          height: 14,
          borderRadius: 4,
        ),
        Row(
          children: [
            SkeletonBox(
              width: 40,
              height: 40,
              borderRadius: 8,
            ),
            SizedBox(width: 8),
            SkeletonBox(
              width: 40,
              height: 40,
              borderRadius: 8,
            ),
            SizedBox(width: 8),
            SkeletonBox(
              width: 40,
              height: 40,
              borderRadius: 8,
            ),
          ],
        ),
      ],
    );
  }

  // 城市卡片网格骨架
  Widget _buildCityGridSkeleton(bool isMobile) {
    final crossAxisCount = isMobile ? 2 : 4;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isMobile ? 0.68 : 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return const SkeletonBox(
            borderRadius: 8,
          );
        },
        childCount: isMobile ? 4 : 8,
      ),
    );
  }

  // Meetups 部分骨架
  Widget _buildMeetupsSkeleton(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: 180,
                  height: 28,
                  borderRadius: 4,
                ),
                SizedBox(height: 4),
                SkeletonBox(
                  width: 120,
                  height: 16,
                  borderRadius: 4,
                ),
              ],
            ),
            Row(
              children: [
                SkeletonBox(
                  width: isMobile ? 80 : 140,
                  height: isMobile ? 36 : 44,
                  borderRadius: 8,
                ),
                if (!isMobile) const SizedBox(width: 12),
                if (!isMobile)
                  const SkeletonBox(
                    width: 140,
                    height: 44,
                    borderRadius: 8,
                  ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Meetup 卡片列表（横向滚动）
        SizedBox(
          height: 310,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SkeletonBox(
                  width: isMobile ? 280 : 340,
                  borderRadius: 12,
                ),
              );
            },
          ),
        ),

        // 移动端的 View all 按钮骨架
        if (isMobile) ...[
          const SizedBox(height: 16),
          const Center(
            child: SkeletonBox(
              width: 160,
              height: 44,
              borderRadius: 8,
            ),
          ),
        ],
      ],
    );
  }

  // 特性列表骨架
  Widget _buildFeaturesSkeleton(bool isMobile) {
    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(5, (index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: 24,
                  height: 24,
                  borderRadius: 12,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SkeletonBox(
                    height: 16,
                    borderRadius: 4,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// 紧凑型服务卡片骨架
class _CompactCardSkeleton extends StatelessWidget {
  const _CompactCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonBox(
      height: 140,
      borderRadius: 16,
    );
  }
}
