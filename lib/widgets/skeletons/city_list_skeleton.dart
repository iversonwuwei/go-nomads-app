import 'package:flutter/material.dart';

import 'base_skeleton.dart';

/// 城市列表页骨架屏组件（使用 shimmer 包）
class CityListSkeleton extends BaseSkeleton {
  const CityListSkeleton({super.key});

  @override
  State<CityListSkeleton> createState() => _CityListSkeletonState();
}

class _CityListSkeletonState extends BaseSkeletonState<CityListSkeleton> {
  @override
  Widget buildSkeleton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 20,
        isMobile ? 12 : 20,
        isMobile ? 12 : 20,
        20,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 3,
        crossAxisSpacing: isMobile ? 10 : 16,
        mainAxisSpacing: isMobile ? 10 : 16,
        childAspectRatio: 0.68,
      ),
      itemCount: isMobile ? 6 : 9,
      itemBuilder: (context, index) {
        return _buildCityCardSkeleton();
      },
    );
  }

  /// 城市卡片骨架 - 匹配实际 CityCard 布局
  /// 顶部图片区 + 底部信息区（城市名、国家、评分等）
  Widget _buildCityCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域（占比约 60%）
          const Expanded(
            flex: 6,
            child: SkeletonBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 0,
            ),
          ),
          // 信息区域（占比约 40%）
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 城市名称
                  const SkeletonBox(
                    width: 80,
                    height: 14,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 4),
                  // 国家名称
                  const SkeletonBox(
                    width: 50,
                    height: 11,
                    borderRadius: 4,
                  ),
                  const Spacer(),
                  // 底部指标行
                  Row(
                    children: const [
                      SkeletonBox(width: 32, height: 16, borderRadius: 4),
                      SizedBox(width: 6),
                      SkeletonBox(width: 32, height: 16, borderRadius: 4),
                      Spacer(),
                      SkeletonBox(width: 20, height: 16, borderRadius: 4),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
