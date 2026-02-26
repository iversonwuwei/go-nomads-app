import 'package:flutter/material.dart';
import 'base_skeleton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        padding: EdgeInsets.all(16.w),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
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
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8.r,
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
            height: 180.h,
            borderRadius: 12,
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 酒店名称
                SkeletonBox(width: 200.w, height: 20.h),
                SizedBox(height: 8.h),
                // 地址
                SkeletonBox(width: 150.w, height: 14.h),
                SizedBox(height: 12.h),
                // 评分和价格
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SkeletonBox(width: 20.w, height: 20.h),
                        SizedBox(width: 4.w),
                        SkeletonBox(width: 30.w, height: 16.h),
                      ],
                    ),
                    SkeletonBox(width: 80.w, height: 20.h),
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
              height: 250.h,
              borderRadius: 0,
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 酒店名称
                  SkeletonBox(width: 250.w, height: 28.h),
                  SizedBox(height: 8.h),
                  // 地址
                  SkeletonBox(width: 200.w, height: 16.h),
                  SizedBox(height: 16.h),
                  // 评分
                  Row(
                    children: [
                      SkeletonBox(width: 100.w, height: 24.h),
                      SizedBox(width: 16.w),
                      SkeletonBox(width: 80.w, height: 24.h),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  // 描述标题
                  SkeletonBox(width: 100.w, height: 20.h),
                  SizedBox(height: 12.h),
                  // 描述内容
                  SkeletonBox(width: double.infinity, height: 16.h),
                  SizedBox(height: 6.h),
                  SkeletonBox(width: double.infinity, height: 16.h),
                  SizedBox(height: 6.h),
                  SkeletonBox(width: 280.w, height: 16.h),
                  SizedBox(height: 24.h),
                  // 设施标题
                  SkeletonBox(width: 80.w, height: 20.h),
                  SizedBox(height: 12.h),
                  // 设施图标
                  Row(
                    children: [
                      SkeletonBox(width: 60.w, height: 60.h, borderRadius: 8),
                      SizedBox(width: 12.w),
                      SkeletonBox(width: 60.w, height: 60.h, borderRadius: 8),
                      SizedBox(width: 12.w),
                      SkeletonBox(width: 60.w, height: 60.h, borderRadius: 8),
                      SizedBox(width: 12.w),
                      SkeletonBox(width: 60.w, height: 60.h, borderRadius: 8),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  // 房型标题
                  SkeletonBox(width: 100.w, height: 20.h),
                  SizedBox(height: 12.h),
                  // 房型卡片
                  _RoomTypeSkeleton(),
                  SizedBox(height: 12.h),
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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          SkeletonBox(width: 80.w, height: 60.h, borderRadius: 6),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120.w, height: 16.h),
                SizedBox(height: 6.h),
                SkeletonBox(width: 80.w, height: 14.h),
              ],
            ),
          ),
          SkeletonBox(width: 70.w, height: 24.h),
        ],
      ),
    );
  }
}
