import 'package:flutter/material.dart';
import 'base_skeleton.dart';

/// Meetup List Skeleton - Meetup 列表骨架屏
class MeetupListSkeleton extends StatelessWidget {
  final int itemCount;

  const MeetupListSkeleton({
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
            child: _MeetupCardSkeleton(),
          );
        },
      ),
    );
  }
}

/// Meetup Card Skeleton - Meetup 卡片骨架
class _MeetupCardSkeleton extends StatelessWidget {
  const _MeetupCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面图片
          const SkeletonBox(
            width: double.infinity,
            height: 160,
            borderRadius: 16,
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                SkeletonBox(width: 220, height: 22),
                SizedBox(height: 12),
                // 时间
                Row(
                  children: [
                    SkeletonBox(width: 20, height: 20),
                    SizedBox(width: 8),
                    SkeletonBox(width: 150, height: 16),
                  ],
                ),
                SizedBox(height: 8),
                // 地点
                Row(
                  children: [
                    SkeletonBox(width: 20, height: 20),
                    SizedBox(width: 8),
                    SkeletonBox(width: 180, height: 16),
                  ],
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
          // 参与者头像 (使用 Stack 实现重叠效果，需要在 const 外部)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: SizedBox(
              height: 32,
              child: Row(
                children: [
                  SizedBox(
                    width: 72, // 3个头像重叠: 32 + 20 + 20
                    child: Stack(
                      children: [
                        Positioned(left: 0, child: SkeletonCircle(size: 32)),
                        Positioned(left: 20, child: SkeletonCircle(size: 32)),
                        Positioned(left: 40, child: SkeletonCircle(size: 32)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const SkeletonBox(width: 60, height: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Meetup Detail Skeleton - Meetup 详情骨架屏
class MeetupDetailSkeleton extends StatelessWidget {
  const MeetupDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片
            SkeletonBox(
              width: double.infinity,
              height: 220,
              borderRadius: 0,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  SkeletonBox(width: 280, height: 28),
                  SizedBox(height: 16),
                  // 组织者
                  Row(
                    children: [
                      SkeletonCircle(size: 48),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 100, height: 16),
                          SizedBox(height: 4),
                          SkeletonBox(width: 80, height: 14),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // 时间地点信息
                  _MeetupInfoRowSkeleton(),
                  SizedBox(height: 12),
                  _MeetupInfoRowSkeleton(),
                  SizedBox(height: 12),
                  _MeetupInfoRowSkeleton(),
                  SizedBox(height: 24),
                  // 描述标题
                  SkeletonBox(width: 80, height: 20),
                  SizedBox(height: 12),
                  // 描述内容
                  SkeletonBox(width: double.infinity, height: 16),
                  SizedBox(height: 6),
                  SkeletonBox(width: double.infinity, height: 16),
                  SizedBox(height: 6),
                  SkeletonBox(width: 250, height: 16),
                  SizedBox(height: 24),
                  // 参与者标题
                  SkeletonBox(width: 100, height: 20),
                  SizedBox(height: 12),
                  // 参与者列表
                  Row(
                    children: [
                      SkeletonCircle(size: 44),
                      SizedBox(width: 8),
                      SkeletonCircle(size: 44),
                      SizedBox(width: 8),
                      SkeletonCircle(size: 44),
                      SizedBox(width: 8),
                      SkeletonCircle(size: 44),
                      SizedBox(width: 8),
                      SkeletonCircle(size: 44),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetupInfoRowSkeleton extends StatelessWidget {
  const _MeetupInfoRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBox(width: 24, height: 24),
        SizedBox(width: 12),
        SkeletonBox(width: 180, height: 16),
      ],
    );
  }
}

/// My Meetups Skeleton - 我的 Meetup 骨架屏
class MyMeetupsSkeleton extends StatelessWidget {
  final int itemCount;

  const MyMeetupsSkeleton({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CompactMeetupCardSkeleton(),
          );
        },
      ),
    );
  }
}

class _CompactMeetupCardSkeleton extends StatelessWidget {
  const _CompactMeetupCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 70, height: 70, borderRadius: 8),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 18),
                SizedBox(height: 6),
                SkeletonBox(width: 120, height: 14),
                SizedBox(height: 6),
                SkeletonBox(width: 80, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
