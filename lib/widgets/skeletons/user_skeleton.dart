import 'package:flutter/material.dart';
import 'base_skeleton.dart';

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
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const Divider(height: 1),
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
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像/图标
          SkeletonCircle(size: 48),
          SizedBox(width: 12),
          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                SkeletonBox(width: 200, height: 16),
                SizedBox(height: 6),
                // 内容
                SkeletonBox(width: double.infinity, height: 14),
                SizedBox(height: 4),
                SkeletonBox(width: 180, height: 14),
                SizedBox(height: 8),
                // 时间
                SkeletonBox(width: 80, height: 12),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 头像和基本信息
            _ProfileHeaderSkeleton(),
            SizedBox(height: 24),
            // 统计信息
            _ProfileStatsSkeleton(),
            SizedBox(height: 24),
            // Bio
            SkeletonBox(width: double.infinity, height: 16),
            SizedBox(height: 6),
            SkeletonBox(width: 280, height: 16),
            SizedBox(height: 24),
            // 技能标签
            _ProfileTagsSkeleton(),
            SizedBox(height: 24),
            // 兴趣标签
            _ProfileTagsSkeleton(),
            SizedBox(height: 24),
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
    return const Column(
      children: [
        // 头像
        SkeletonCircle(size: 100),
        SizedBox(height: 16),
        // 名字
        SkeletonBox(width: 150, height: 24),
        SizedBox(height: 8),
        // 职业
        SkeletonBox(width: 120, height: 16),
        SizedBox(height: 6),
        // 位置
        SkeletonBox(width: 100, height: 14),
      ],
    );
  }
}

class _ProfileStatsSkeleton extends StatelessWidget {
  const _ProfileStatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            SkeletonBox(width: 40, height: 24),
            SizedBox(height: 4),
            SkeletonBox(width: 60, height: 14),
          ],
        ),
        Column(
          children: [
            SkeletonBox(width: 40, height: 24),
            SizedBox(height: 4),
            SkeletonBox(width: 60, height: 14),
          ],
        ),
        Column(
          children: [
            SkeletonBox(width: 40, height: 24),
            SizedBox(height: 4),
            SkeletonBox(width: 60, height: 14),
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: 80, height: 18),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SkeletonBox(width: 70, height: 28, borderRadius: 14),
            SkeletonBox(width: 90, height: 28, borderRadius: 14),
            SkeletonBox(width: 60, height: 28, borderRadius: 14),
            SkeletonBox(width: 80, height: 28, borderRadius: 14),
            SkeletonBox(width: 100, height: 28, borderRadius: 14),
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: 100, height: 18),
        SizedBox(height: 12),
        Row(
          children: [
            SkeletonCircle(size: 40),
            SizedBox(width: 12),
            SkeletonCircle(size: 40),
            SizedBox(width: 12),
            SkeletonCircle(size: 40),
            SizedBox(width: 12),
            SkeletonCircle(size: 40),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            fieldCount,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签
        SkeletonBox(width: 80, height: 14),
        SizedBox(height: 8),
        // 输入框
        SkeletonBox(width: double.infinity, height: 48, borderRadius: 8),
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
        padding: EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SkeletonBox(width: 80, height: 36, borderRadius: 18),
            SkeletonBox(width: 100, height: 36, borderRadius: 18),
            SkeletonBox(width: 70, height: 36, borderRadius: 18),
            SkeletonBox(width: 90, height: 36, borderRadius: 18),
            SkeletonBox(width: 110, height: 36, borderRadius: 18),
            SkeletonBox(width: 60, height: 36, borderRadius: 18),
            SkeletonBox(width: 85, height: 36, borderRadius: 18),
            SkeletonBox(width: 95, height: 36, borderRadius: 18),
            SkeletonBox(width: 75, height: 36, borderRadius: 18),
            SkeletonBox(width: 105, height: 36, borderRadius: 18),
            SkeletonBox(width: 65, height: 36, borderRadius: 18),
            SkeletonBox(width: 88, height: 36, borderRadius: 18),
          ],
        ),
      ),
    );
  }
}
