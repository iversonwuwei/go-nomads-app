import 'package:flutter/material.dart';

import 'base_skeleton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 社区内容骨架屏组件
class CommunitySkeleton extends BaseSkeleton {
  const CommunitySkeleton({super.key});

  @override
  State<CommunitySkeleton> createState() => _CommunitySkeletonState();
}

class _CommunitySkeletonState extends BaseSkeletonState<CommunitySkeleton> {
  @override
  Widget buildSkeleton(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildCommunityPostCard();
      },
    );
  }

  Widget _buildCommunityPostCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: SkeletonCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息头部
            Row(
              children: [
                SkeletonCircle(
                  size: 40.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: 120.w,
                        height: 14.h,
                        borderRadius: 4,
                      ),
                      SizedBox(height: 6.h),
                      SkeletonBox(
                        width: 180.w,
                        height: 12.h,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ),
                SkeletonBox(
                  width: 50.w,
                  height: 28.h,
                  borderRadius: 6,
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // 内容图片
            SkeletonBox(
              width: double.infinity,
              height: 200.h,
              borderRadius: 12,
            ),
            SizedBox(height: 16.h),

            // 标题
            SkeletonBox(
              width: double.infinity,
              height: 18.h,
              borderRadius: 4,
            ),
            SizedBox(height: 8.h),

            // 内容
            SkeletonBox(
              width: double.infinity,
              height: 14.h,
              borderRadius: 4,
            ),
            SizedBox(height: 6.h),
            SkeletonBox(
              width: double.infinity,
              height: 14.h,
              borderRadius: 4,
            ),
            SizedBox(height: 6.h),
            SkeletonBox(
              width: 250.w,
              height: 14.h,
              borderRadius: 4,
            ),
            SizedBox(height: 16.h),

            // 底部统计信息
            Row(
              children: [
                SkeletonBox(
                  width: 60.w,
                  height: 12.h,
                  borderRadius: 4,
                ),
                SizedBox(width: 16.w),
                SkeletonBox(
                  width: 60.w,
                  height: 12.h,
                  borderRadius: 4,
                ),
                const Spacer(),
                SkeletonBox(
                  width: 80.w,
                  height: 12.h,
                  borderRadius: 4,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
