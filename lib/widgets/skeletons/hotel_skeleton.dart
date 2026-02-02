import 'package:flutter/material.dart';
import 'base_skeleton.dart';

/// Hotel List Skeleton - 酒店列表骨架屏
class HotelListSkeleton extends StatelessWidget {
  final int itemCount;

  const HotelListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _HotelCardSkeleton(),
          );
        },
      ),
    );
  }
}

/// Hotel Card Skeleton - 酒店卡片骨架
class _HotelCardSkeleton extends StatelessWidget {
  const _HotelCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 酒店图片
          SkeletonBox(
            width: double.infinity,
            height: 180,
            borderRadius: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 酒店名称
                SkeletonBox(width: 200, height: 20),
                const SizedBox(height: 8),
                // 地址
                SkeletonBox(width: 150, height: 14),
                const SizedBox(height: 12),
                // 评分和价格
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SkeletonBox(width: 20, height: 20),
                        const SizedBox(width: 4),
                        SkeletonBox(width: 30, height: 16),
                      ],
                    ),
                    SkeletonBox(width: 80, height: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hotel Detail Skeleton - 酒店详情骨架屏
class HotelDetailSkeleton extends StatelessWidget {
  const HotelDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 酒店图片
            SkeletonBox(
              width: double.infinity,
              height: 250,
              borderRadius: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 酒店名称
                  SkeletonBox(width: 250, height: 28),
                  const SizedBox(height: 8),
                  // 地址
                  SkeletonBox(width: 200, height: 16),
                  const SizedBox(height: 16),
                  // 评分
                  Row(
                    children: [
                      SkeletonBox(width: 100, height: 24),
                      const SizedBox(width: 16),
                      SkeletonBox(width: 80, height: 24),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 描述标题
                  SkeletonBox(width: 100, height: 20),
                  const SizedBox(height: 12),
                  // 描述内容
                  SkeletonBox(width: double.infinity, height: 16),
                  const SizedBox(height: 6),
                  SkeletonBox(width: double.infinity, height: 16),
                  const SizedBox(height: 6),
                  SkeletonBox(width: 280, height: 16),
                  const SizedBox(height: 24),
                  // 设施标题
                  SkeletonBox(width: 80, height: 20),
                  const SizedBox(height: 12),
                  // 设施图标
                  Row(
                    children: [
                      SkeletonBox(width: 60, height: 60, borderRadius: 8),
                      const SizedBox(width: 12),
                      SkeletonBox(width: 60, height: 60, borderRadius: 8),
                      const SizedBox(width: 12),
                      SkeletonBox(width: 60, height: 60, borderRadius: 8),
                      const SizedBox(width: 12),
                      SkeletonBox(width: 60, height: 60, borderRadius: 8),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 房型标题
                  SkeletonBox(width: 100, height: 20),
                  const SizedBox(height: 12),
                  // 房型卡片
                  _RoomTypeSkeleton(),
                  const SizedBox(height: 12),
                  _RoomTypeSkeleton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomTypeSkeleton extends StatelessWidget {
  const _RoomTypeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SkeletonBox(width: 80, height: 60, borderRadius: 6),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120, height: 16),
                const SizedBox(height: 6),
                SkeletonBox(width: 80, height: 14),
              ],
            ),
          ),
          SkeletonBox(width: 70, height: 24),
        ],
      ),
    );
  }
}
