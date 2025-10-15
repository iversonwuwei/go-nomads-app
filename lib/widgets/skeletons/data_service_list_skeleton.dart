import 'package:flutter/material.dart';

import 'base_skeleton.dart';

/// 数据服务列表骨架屏组件
class DataServiceListSkeleton extends BaseSkeleton {
  const DataServiceListSkeleton({super.key});

  @override
  State<DataServiceListSkeleton> createState() => _DataServiceListSkeletonState();
}

class _DataServiceListSkeletonState extends BaseSkeletonState<DataServiceListSkeleton> {
  @override
  Widget buildSkeleton(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildServiceCard();
      },
    );
  }

  Widget _buildServiceCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SkeletonCard(
        shimmerController: shimmerController,
        height: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 服务图标
                SkeletonBox(
                  shimmerController: shimmerController,
                  width: 60,
                  height: 60,
                  borderRadius: 12,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 服务名称
                      SkeletonBox(
                        shimmerController: shimmerController,
                        width: double.infinity,
                        height: 16,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 8),
                      // 服务描述
                      SkeletonBox(
                        shimmerController: shimmerController,
                        width: 150,
                        height: 14,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 8),
                      // 状态标签
                      SkeletonBox(
                        shimmerController: shimmerController,
                        width: 100,
                        height: 12,
                        borderRadius: 4,
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
