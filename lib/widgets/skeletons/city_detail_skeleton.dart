import 'package:flutter/material.dart';

import 'base_skeleton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 城市详情页骨架屏组件 - 完整版
/// 模拟城市详情页的实际布局：大图轮播、评分卡片、标签页、内容列表
class CityDetailSkeleton extends BaseSkeleton {
  const CityDetailSkeleton({super.key});

  @override
  State<CityDetailSkeleton> createState() => _CityDetailSkeletonState();
}

class _CityDetailSkeletonState extends BaseSkeletonState<CityDetailSkeleton> {
  @override
  Widget buildSkeleton(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 顶部大图 Banner
        SliverToBoxAdapter(
          child: _buildHeaderBanner(),
        ),

        // 评分信息卡片
        SliverToBoxAdapter(
          child: _buildScoreCard(),
        ),

        // 标签页导航
        SliverToBoxAdapter(
          child: _buildTabBar(),
        ),

        // 内容区域
        SliverPadding(
          padding: EdgeInsets.all(16.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 评分项列表
              ..._buildScoreItems(),
              SizedBox(height: 24.h),

              // 详情卡片
              ..._buildContentCards(),
            ]),
          ),
        ),
      ],
    );
  }

  /// 顶部大图轮播骨架
  Widget _buildHeaderBanner() {
    return Stack(
      children: [
        // 主图片区域
        SkeletonBox(
          width: double.infinity,
          height: 320.h,
          borderRadius: 0,
        ),

        // 底部渐变蒙层
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),

        // 城市名称占位
        Positioned(
          bottom: 20.h,
          left: 0,
          right: 0,
          child: Center(
            child: SkeletonBox(
              width: 180.w,
              height: 32.h,
              borderRadius: 20,
            ),
          ),
        ),

        // 轮播指示器占位
        Positioned(
          top: 24.h,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                child: SkeletonBox(
                  width: index == 0 ? 24 : 8,
                  height: 8.h,
                  borderRadius: 4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 评分信息卡片骨架
  Widget _buildScoreCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 评分徽章
          SkeletonBox(
            width: 80.w,
            height: 44.h,
            borderRadius: 16,
          ),
          SizedBox(width: 16.w),

          // 评论信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: 120.w,
                  height: 18.h,
                  borderRadius: 4,
                ),
                SizedBox(height: 6.h),
                SkeletonBox(
                  width: 150.w,
                  height: 14.h,
                  borderRadius: 4,
                ),
              ],
            ),
          ),

          // 收藏和分享按钮
          Row(
            children: [
              SkeletonBox(
                width: 48.w,
                height: 48.h,
                borderRadius: 12,
              ),
              SizedBox(width: 8.w),
              SkeletonBox(
                width: 48.w,
                height: 48.h,
                borderRadius: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 标签页导航骨架
  Widget _buildTabBar() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: SkeletonBox(
                width: index == 0 ? 60 : 50,
                height: 20.h,
                borderRadius: 4,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 评分项列表骨架
  List<Widget> _buildScoreItems() {
    return List.generate(
      5,
      (index) => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Row(
          children: [
            // 图标
            SkeletonBox(
              width: 24.w,
              height: 24.h,
              borderRadius: 6,
            ),
            SizedBox(width: 12.w),

            // 进度条区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: 80.w,
                    height: 16.h,
                    borderRadius: 4,
                  ),
                  SizedBox(height: 6.h),
                  SkeletonBox(
                    width: double.infinity,
                    height: 4.h,
                    borderRadius: 2,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),

            // 分数
            SkeletonBox(
              width: 30.w,
              height: 20.h,
              borderRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  /// 内容卡片列表骨架
  List<Widget> _buildContentCards() {
    return List.generate(
      3,
      (index) => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: SkeletonCard(
          height: 180.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 卡片标题
              Row(
                children: [
                  SkeletonBox(
                    width: 32.w,
                    height: 32.h,
                    borderRadius: 8,
                  ),
                  SizedBox(width: 12.w),
                  SkeletonBox(
                    width: 150.w,
                    height: 20.h,
                    borderRadius: 4,
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // 内容行
              ...List.generate(
                3,
                (i) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: SkeletonBox(
                    width: i == 2 ? 200 : double.infinity,
                    height: 14.h,
                    borderRadius: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
