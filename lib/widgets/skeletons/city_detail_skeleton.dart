import 'package:flutter/material.dart';

import 'base_skeleton.dart';

/// 城市详情页骨架屏组件
class CityDetailSkeleton extends BaseSkeleton {
  const CityDetailSkeleton({super.key});

  @override
  State<CityDetailSkeleton> createState() => _CityDetailSkeletonState();
}

class _CityDetailSkeletonState extends BaseSkeletonState<CityDetailSkeleton> {
  @override
  Widget buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部大图
          _buildHeaderImage(),
          const SizedBox(height: 16),

          // 城市标题
          _buildTitle(),
          const SizedBox(height: 12),

          // 城市副标题/简介
          _buildSubtitle(),
          const SizedBox(height: 24),

          // 详情卡片列表
          ..._buildDetailCards(),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return SkeletonBox(
      shimmerController: shimmerController,
      width: double.infinity,
      height: 200,
      borderRadius: 16,
    );
  }

  Widget _buildTitle() {
    return SkeletonBox(
      shimmerController: shimmerController,
      width: double.infinity,
      height: 24,
      borderRadius: 4,
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(
          shimmerController: shimmerController,
          width: 250,
          height: 16,
          borderRadius: 4,
        ),
        const SizedBox(height: 8),
        SkeletonBox(
          shimmerController: shimmerController,
          width: 200,
          height: 16,
          borderRadius: 4,
        ),
      ],
    );
  }

  List<Widget> _buildDetailCards() {
    return List.generate(3, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SkeletonCard(
          shimmerController: shimmerController,
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBox(
                    shimmerController: shimmerController,
                    width: 24,
                    height: 24,
                    borderRadius: 6,
                  ),
                  const SizedBox(width: 12),
                  SkeletonBox(
                    shimmerController: shimmerController,
                    width: 120,
                    height: 20,
                    borderRadius: 4,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SkeletonBox(
                shimmerController: shimmerController,
                width: double.infinity,
                height: 14,
                borderRadius: 4,
              ),
              const SizedBox(height: 10),
              SkeletonBox(
                shimmerController: shimmerController,
                width: double.infinity,
                height: 14,
                borderRadius: 4,
              ),
              const SizedBox(height: 10),
              SkeletonBox(
                shimmerController: shimmerController,
                width: 200,
                height: 14,
                borderRadius: 4,
              ),
            ],
          ),
        ),
      );
    });
  }
}
