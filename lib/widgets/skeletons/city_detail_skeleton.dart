import 'package:flutter/material.dart';

import 'base_skeleton.dart';

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
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 评分项列表
              ..._buildScoreItems(),
              const SizedBox(height: 24),

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
        const SkeletonBox(
          width: double.infinity,
          height: 320,
          borderRadius: 0,
        ),

        // 底部渐变蒙层
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120,
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
        const Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: SkeletonBox(
              width: 180,
              height: 32,
              borderRadius: 20,
            ),
          ),
        ),

        // 轮播指示器占位
        Positioned(
          top: 24,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: SkeletonBox(
                  width: index == 0 ? 24 : 8,
                  height: 8,
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          // 评分徽章
          SkeletonBox(
            width: 80,
            height: 44,
            borderRadius: 16,
          ),
          SizedBox(width: 16),

          // 评论信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: 120,
                  height: 18,
                  borderRadius: 4,
                ),
                SizedBox(height: 6),
                SkeletonBox(
                  width: 150,
                  height: 14,
                  borderRadius: 4,
                ),
              ],
            ),
          ),

          // 收藏和分享按钮
          Row(
            children: [
              SkeletonBox(
                width: 48,
                height: 48,
                borderRadius: 12,
              ),
              SizedBox(width: 8),
              SkeletonBox(
                width: 48,
                height: 48,
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
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: SkeletonBox(
                width: index == 0 ? 60 : 50,
                height: 20,
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
      (index) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            // 图标
            SkeletonBox(
              width: 24,
              height: 24,
              borderRadius: 6,
            ),
            SizedBox(width: 12),

            // 进度条区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: 80,
                    height: 16,
                    borderRadius: 4,
                  ),
                  SizedBox(height: 6),
                  SkeletonBox(
                    width: double.infinity,
                    height: 4,
                    borderRadius: 2,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),

            // 分数
            SkeletonBox(
              width: 30,
              height: 20,
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
        padding: const EdgeInsets.only(bottom: 16),
        child: SkeletonCard(
          height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 卡片标题
              const Row(
                children: [
                  SkeletonBox(
                    width: 32,
                    height: 32,
                    borderRadius: 8,
                  ),
                  SizedBox(width: 12),
                  SkeletonBox(
                    width: 150,
                    height: 20,
                    borderRadius: 4,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 内容行
              ...List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SkeletonBox(
                    width: i == 2 ? 200 : double.infinity,
                    height: 14,
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
