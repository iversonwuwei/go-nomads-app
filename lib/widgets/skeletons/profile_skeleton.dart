import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'base_skeleton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 个人资料页骨架屏组件
class ProfileSkeleton extends BaseSkeleton {
  const ProfileSkeleton({super.key});

  @override
  State<ProfileSkeleton> createState() => _ProfileSkeletonState();
}

class _ProfileSkeletonState extends BaseSkeletonState<ProfileSkeleton> {
  @override
  Widget buildSkeleton(BuildContext context) {
    final isMobile = Get.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(isMobile),
          SizedBox(height: 24.h),

          // Travel Plans Section (空状态容器)
          _buildTravelPlansSection(),
          SizedBox(height: 24.h),

          // Stats Section
          _buildStatsSection(isMobile),
          SizedBox(height: 24.h),

          // Badges Section
          _buildBadgesSection(),
          SizedBox(height: 24.h),

          // Skills and Interests Section
          _buildSkillsAndInterestsSection(),
          SizedBox(height: 24.h),

          // Travel History Section
          _buildTravelHistorySection(),
          SizedBox(height: 24.h),

          // Social Links Section
          _buildSocialLinksSection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isMobile) {
    final avatarSize = isMobile ? 80.0 : 120.0;

    return Row(
      children: [
        // 头像
        SkeletonCircle(
          size: avatarSize,
        ),
        SizedBox(width: 16.w),

        // 用户信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户名
              SkeletonBox(
                width: isMobile ? 120 : 180,
                height: isMobile ? 20 : 28,
                borderRadius: 4,
              ),
              SizedBox(height: 8.h),

              // 邮箱
              SkeletonBox(
                width: isMobile ? 150 : 220,
                height: 14.h,
                borderRadius: 4,
              ),
              SizedBox(height: 8.h),

              // 按钮行
              Row(
                children: [
                  SkeletonBox(
                    width: 80.w,
                    height: 32.h,
                    borderRadius: 8,
                  ),
                  SizedBox(width: 8.w),
                  SkeletonBox(
                    width: 80.w,
                    height: 32.h,
                    borderRadius: 8,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTravelPlansSection() {
    return SkeletonCard(
      height: 120.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SkeletonCircle(
              size: 48.r,
            ),
            SizedBox(height: 12.h),
            SkeletonBox(
              height: 16.h,
              borderRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 12.w;
        final cardWidth = isMobile
            ? (constraints.maxWidth - spacing) / 2
            : null;

        return Wrap(
          spacing: spacing,
          runSpacing: 12.w,
          children: List.generate(6, (index) {
            return SkeletonCard(
              width: cardWidth,
              height: 100.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonBox(
                    width: 40.w,
                    height: 24.h,
                    borderRadius: 4,
                  ),
                  SizedBox(height: 8.h),
                  const SkeletonBox(),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 标题
        SkeletonBox(
          width: 100.w,
          height: 20.h,
          borderRadius: 4,
        ),
        SizedBox(height: 12.h),

        // Badges wrap
        Wrap(
          spacing: 12.w,
          runSpacing: 12.w,
          children: List.generate(4, (index) {
            return SkeletonCard(
              width: 80.w,
              height: 100.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonCircle(
                    size: 40.r,
                  ),
                  SizedBox(height: 8.h),
                  SkeletonBox(
                    width: 60.w,
                    height: 12.h,
                    borderRadius: 4,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSkillsAndInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skills 部分
        SkeletonBox(
          width: 80.w,
          height: 20.h,
          borderRadius: 4,
        ),
        SizedBox(height: 12.h),

        Wrap(
          spacing: 8.w,
          runSpacing: 8.w,
          children: List.generate(5, (index) {
            return SkeletonBox(
              width: 60.w + (index * 10.0),
              height: 32.h,
              borderRadius: 16,
            );
          }),
        ),

        SizedBox(height: 24.h),

        // Interests 部分
        SkeletonBox(
          width: 80.w,
          height: 20.h,
          borderRadius: 4,
        ),
        SizedBox(height: 12.h),

        Wrap(
          spacing: 8.w,
          runSpacing: 8.w,
          children: List.generate(5, (index) {
            return SkeletonBox(
              width: 70.w + (index * 8.0),
              height: 32.h,
              borderRadius: 16,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTravelHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 标题
        SkeletonBox(
          width: 120.w,
          height: 20.h,
          borderRadius: 4,
        ),
        SizedBox(height: 12.h),

        // 旅行历史列表项
        ...List.generate(3, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: SkeletonCard(
              height: 80.h,
              child: Row(
                children: [
                  SkeletonBox(
                    width: 60.w,
                    height: 60.h,
                    borderRadius: 8,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SkeletonBox(
                          width: 150.w,
                          height: 16.h,
                          borderRadius: 4,
                        ),
                        SizedBox(height: 8.h),
                        SkeletonBox(
                          width: 100.w,
                          height: 14.h,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSocialLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 标题
        SkeletonBox(
          width: 100.w,
          height: 20.h,
          borderRadius: 4,
        ),
        SizedBox(height: 12.h),

        // 社交链接按钮
        Wrap(
          spacing: 12.w,
          runSpacing: 12.w,
          children: List.generate(4, (index) {
            return SkeletonBox(
              width: 48.w,
              height: 48.h,
              borderRadius: 24,
            );
          }),
        ),
      ],
    );
  }
}
