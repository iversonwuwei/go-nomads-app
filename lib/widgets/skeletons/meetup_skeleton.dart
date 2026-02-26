import 'package:flutter/material.dart';
import 'base_skeleton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        padding: EdgeInsets.all(16.w),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
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
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面图片
          SkeletonBox(
            width: double.infinity,
            height: 160.h,
            borderRadius: 16,
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                SkeletonBox(width: 220.w, height: 22.h),
                SizedBox(height: 12.h),
                // 时间
                Row(
                  children: [
                    SkeletonBox(width: 20.w, height: 20.h),
                    SizedBox(width: 8.w),
                    SkeletonBox(width: 150.w, height: 16.h),
                  ],
                ),
                SizedBox(height: 8.h),
                // 地点
                Row(
                  children: [
                    SkeletonBox(width: 20.w, height: 20.h),
                    SizedBox(width: 8.w),
                    SkeletonBox(width: 180.w, height: 16.h),
                  ],
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
          // 参与者头像 (使用 Stack 实现重叠效果，需要在 外部)
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
            child: SizedBox(
              height: 32.h,
              child: Row(
                children: [
                  SizedBox(
                    width: 72.w, // 3个头像重叠: 32 + 20 + 20
                    child: Stack(
                      children: [
                        Positioned(left: 0, child: SkeletonCircle(size: 32.r)),
                        Positioned(left: 20.w, child: SkeletonCircle(size: 32.r)),
                        Positioned(left: 40.w, child: SkeletonCircle(size: 32.r)),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SkeletonBox(width: 60.w, height: 14.h),
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
              height: 220.h,
              borderRadius: 0,
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  SkeletonBox(width: 280.w, height: 28.h),
                  SizedBox(height: 16.h),
                  // 组织者
                  Row(
                    children: [
                      SkeletonCircle(size: 48.r),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 100.w, height: 16.h),
                          SizedBox(height: 4.h),
                          SkeletonBox(width: 80.w, height: 14.h),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // 时间地点信息
                  _MeetupInfoRowSkeleton(),
                  SizedBox(height: 12.h),
                  _MeetupInfoRowSkeleton(),
                  SizedBox(height: 12.h),
                  _MeetupInfoRowSkeleton(),
                  SizedBox(height: 24.h),
                  // 描述标题
                  SkeletonBox(width: 80.w, height: 20.h),
                  SizedBox(height: 12.h),
                  // 描述内容
                  SkeletonBox(width: double.infinity, height: 16.h),
                  SizedBox(height: 6.h),
                  SkeletonBox(width: double.infinity, height: 16.h),
                  SizedBox(height: 6.h),
                  SkeletonBox(width: 250.w, height: 16.h),
                  SizedBox(height: 24.h),
                  // 参与者标题
                  SkeletonBox(width: 100.w, height: 20.h),
                  SizedBox(height: 12.h),
                  // 参与者列表
                  Row(
                    children: [
                      SkeletonCircle(size: 44.r),
                      SizedBox(width: 8.w),
                      SkeletonCircle(size: 44.r),
                      SizedBox(width: 8.w),
                      SkeletonCircle(size: 44.r),
                      SizedBox(width: 8.w),
                      SkeletonCircle(size: 44.r),
                      SizedBox(width: 8.w),
                      SkeletonCircle(size: 44.r),
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
    return Row(
      children: [
        SkeletonBox(width: 24.w, height: 24.h),
        SizedBox(width: 12.w),
        SkeletonBox(width: 180.w, height: 16.h),
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
        padding: EdgeInsets.all(16.w),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          SkeletonBox(width: 70.w, height: 70.h, borderRadius: 8),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160.w, height: 18.h),
                SizedBox(height: 6.h),
                SkeletonBox(width: 120.w, height: 14.h),
                SizedBox(height: 6.h),
                SkeletonBox(width: 80.w, height: 14.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
