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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return _buildCityCard();
      },
    );
  }

  Widget _buildCityCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SkeletonCard(
        height: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 城市图标/图片
                const SkeletonBox(
                  width: 60,
                  height: 60,
                  borderRadius: 12,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      // 城市名称
                      SkeletonBox(
                        width: double.infinity,
                        height: 18,
                        borderRadius: 4,
                      ),
                      SizedBox(height: 8),
                      // 城市描述
                      SkeletonBox(
                        width: 180,
                        height: 14,
                        borderRadius: 4,
                      ),
                      SizedBox(height: 8),
                      // 标签或其他信息
                      Row(
                        children: [
                          SkeletonBox(
                            width: 60,
                            height: 12,
                            borderRadius: 4,
                          ),
                          SizedBox(width: 8),
                          SkeletonBox(
                            width: 60,
                            height: 12,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
