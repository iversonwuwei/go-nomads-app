import 'package:flutter/material.dart';
import 'base_skeleton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Notification List Skeleton - 通知列表骨架屏
class NotificationListSkeleton extends StatelessWidget {
  final int itemCount;

  const NotificationListSkeleton({
    super.key,
    this.itemCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: itemCount,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          return _NotificationItemSkeleton();
        },
      ),
    );
  }
}

class _NotificationItemSkeleton extends StatelessWidget {
  const _NotificationItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像/图标
          SkeletonCircle(size: 48.r),
          SizedBox(width: 12.w),
          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                SkeletonBox(width: 200.w, height: 16.h),
                SizedBox(height: 6.h),
                // 内容
                SkeletonBox(width: double.infinity, height: 14.h),
                SizedBox(height: 4.h),
                SkeletonBox(width: 180.w, height: 14.h),
                SizedBox(height: 8.h),
                // 时间
                SkeletonBox(width: 80.w, height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// User Profile Skeleton - 用户资料骨架屏
class UserProfileSkeleton extends StatelessWidget {
  const UserProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // 头像和基本信息
            _ProfileHeaderSkeleton(),
            SizedBox(height: 24.h),
            // 统计信息
            _ProfileStatsSkeleton(),
            SizedBox(height: 24.h),
            // Bio
            SkeletonBox(width: double.infinity, height: 16.h),
            SizedBox(height: 6.h),
            SkeletonBox(width: 280.w, height: 16.h),
            SizedBox(height: 24.h),
            // 技能标签
            _ProfileTagsSkeleton(),
            SizedBox(height: 24.h),
            // 兴趣标签
            _ProfileTagsSkeleton(),
            SizedBox(height: 24.h),
            // 社交链接
            _SocialLinksSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 头像
        SkeletonCircle(size: 100.r),
        SizedBox(height: 16.h),
        // 名字
        SkeletonBox(width: 150.w, height: 24.h),
        SizedBox(height: 8.h),
        // 职业
        SkeletonBox(width: 120.w, height: 16.h),
        SizedBox(height: 6.h),
        // 位置
        SkeletonBox(width: 100.w, height: 14.h),
      ],
    );
  }
}

class _ProfileStatsSkeleton extends StatelessWidget {
  const _ProfileStatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            SkeletonBox(width: 40.w, height: 24.h),
            SizedBox(height: 4.h),
            SkeletonBox(width: 60.w, height: 14.h),
          ],
        ),
        Column(
          children: [
            SkeletonBox(width: 40.w, height: 24.h),
            SizedBox(height: 4.h),
            SkeletonBox(width: 60.w, height: 14.h),
          ],
        ),
        Column(
          children: [
            SkeletonBox(width: 40.w, height: 24.h),
            SizedBox(height: 4.h),
            SkeletonBox(width: 60.w, height: 14.h),
          ],
        ),
      ],
    );
  }
}

class _ProfileTagsSkeleton extends StatelessWidget {
  const _ProfileTagsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: 80.w, height: 18.h),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.w,
          children: [
            SkeletonBox(width: 70.w, height: 28.h, borderRadius: 14),
            SkeletonBox(width: 90.w, height: 28.h, borderRadius: 14),
            SkeletonBox(width: 60.w, height: 28.h, borderRadius: 14),
            SkeletonBox(width: 80.w, height: 28.h, borderRadius: 14),
            SkeletonBox(width: 100.w, height: 28.h, borderRadius: 14),
          ],
        ),
      ],
    );
  }
}

class _SocialLinksSkeleton extends StatelessWidget {
  const _SocialLinksSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: 100.w, height: 18.h),
        SizedBox(height: 12.h),
        Row(
          children: [
            SkeletonCircle(size: 40.r),
            SizedBox(width: 12.w),
            SkeletonCircle(size: 40.r),
            SizedBox(width: 12.w),
            SkeletonCircle(size: 40.r),
            SizedBox(width: 12.w),
            SkeletonCircle(size: 40.r),
          ],
        ),
      ],
    );
  }
}

/// Edit Form Skeleton - 编辑表单骨架屏（通用）
class EditFormSkeleton extends StatelessWidget {
  final int fieldCount;

  const EditFormSkeleton({
    super.key,
    this.fieldCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            fieldCount,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: _FormFieldSkeleton(),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormFieldSkeleton extends StatelessWidget {
  const _FormFieldSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签
        SkeletonBox(width: 80.w, height: 14.h),
        SizedBox(height: 8.h),
        // 输入框
        SkeletonBox(width: double.infinity, height: 48.h, borderRadius: 8),
      ],
    );
  }
}

/// Tags Selector Skeleton - 标签选择骨架屏
class TagsSelectorSkeleton extends StatelessWidget {
  const TagsSelectorSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Wrap(
          spacing: 8.w,
          runSpacing: 8.w,
          children: [
            SkeletonBox(width: 80.w, height: 36.h, borderRadius: 18),
            SkeletonBox(width: 100.w, height: 36.h, borderRadius: 18),
            SkeletonBox(width: 70.w, height: 36.h, borderRadius: 18),
            SkeletonBox(width: 90.w, height: 36.h, borderRadius: 18),
            SkeletonBox(width: 110.w, height: 36.h, borderRadius: 18),
            SkeletonBox(width: 60.w, height: 36.h, borderRadius: 18),
            SkeletonBox(width: 85.w, height: 36.h, borderRadius: 18),
            SkeletonBox(width: 95.w, height: 36.h, borderRadius: 18),
            SkeletonBox(width: 75.w, height: 36.h, borderRadius: 18),
            SkeletonBox(width: 105.w, height: 36.h, borderRadius: 18),
            SkeletonBox(width: 65.w, height: 36.h, borderRadius: 18),
            SkeletonBox(width: 88.w, height: 36.h, borderRadius: 18),
          ],
        ),
      ),
    );
  }
}
