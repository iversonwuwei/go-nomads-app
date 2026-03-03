import 'package:flutter/material.dart';

import 'package:go_nomads_app/config/app_colors.dart';
import 'base_skeleton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
              vertical: 20.h,
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

        SliverToBoxAdapter(child: SizedBox(height: 8.h)),

        // 城市卡片网格骨架
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 32,
          ),
          sliver: _buildCityGridSkeleton(isMobile),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 40.h)),

        // Meetups 部分骨架
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
            ),
            child: _buildMeetupsSkeleton(isMobile),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 60.h)),

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

        SliverToBoxAdapter(child: SizedBox(height: 80.h)),
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
                  SkeletonBox(
                    width: 56.w,
                    height: 56.h,
                    borderRadius: 12,
                  ),
                  SizedBox(width: 16.w),
                  SkeletonBox(
                    width: 150.w,
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
              SizedBox(height: 8.h),
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
        constraints: BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _CompactCardSkeleton()),
                SizedBox(width: 12.w),
                Expanded(child: _CompactCardSkeleton()),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(child: _CompactCardSkeleton()),
                SizedBox(width: 12.w),
                Expanded(child: _CompactCardSkeleton()),
              ],
            ),
          ],
        ),
      );
    } else {
      // 1x4 横向布局
      return Container(
        constraints: BoxConstraints(maxWidth: 900),
        child: Row(
          children: [
            Expanded(child: _CompactCardSkeleton()),
            SizedBox(width: 12.w),
            Expanded(child: _CompactCardSkeleton()),
            SizedBox(width: 12.w),
            Expanded(child: _CompactCardSkeleton()),
            SizedBox(width: 12.w),
            Expanded(child: _CompactCardSkeleton()),
          ],
        ),
      );
    }
  }

  // 搜索栏骨架
  Widget _buildSearchBarSkeleton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          SkeletonBox(
            width: 20.w,
            height: 20.h,
            borderRadius: 4,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: SkeletonBox(
              height: 14.h,
              borderRadius: 4,
            ),
          ),
          SizedBox(width: 12.w),
          SkeletonBox(
            width: 34.w,
            height: 34.h,
            borderRadius: 17,
          ),
        ],
      ),
    );
  }

  // 工具栏骨架
  Widget _buildToolbarSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SkeletonBox(
          width: 80.w,
          height: 14.h,
          borderRadius: 4,
        ),
        Row(
          children: [
            SkeletonBox(
              width: 40.w,
              height: 40.h,
              borderRadius: 8,
            ),
            SizedBox(width: 8.w),
            SkeletonBox(
              width: 40.w,
              height: 40.h,
              borderRadius: 8,
            ),
            SizedBox(width: 8.w),
            SkeletonBox(
              width: 40.w,
              height: 40.h,
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
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.w,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: 180.w,
                  height: 28.h,
                  borderRadius: 4,
                ),
                SizedBox(height: 4.h),
                SkeletonBox(
                  width: 120.w,
                  height: 16.h,
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
                if (!isMobile) SizedBox(width: 12.w),
                if (!isMobile)
                  SkeletonBox(
                    width: 140.w,
                    height: 44.h,
                    borderRadius: 8,
                  ),
              ],
            ),
          ],
        ),

        SizedBox(height: 24.h),

        // Meetup 卡片列表（横向滚动）
        SizedBox(
          height: 310.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
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
          SizedBox(height: 16.h),
          Center(
            child: SkeletonBox(
              width: 160.w,
              height: 44.h,
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
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: 24.w,
                  height: 24.h,
                  borderRadius: 12,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SkeletonBox(
                    height: 16.h,
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
    return SkeletonBox(
      height: 140.h,
      borderRadius: 16,
    );
  }
}
