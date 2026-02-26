import 'dart:developer';

import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/create_meetup/create_meetup_page.dart';
import 'package:go_nomads_app/pages/home/widgets/home_meetup_card.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Meetups 区域组件
class HomeMeetupsSection extends StatelessWidget {
  final bool isMobile;

  const HomeMeetupsSection({super.key, required this.isMobile});

  MeetupStateController get _meetupController => Get.find<MeetupStateController>();
  UserStateController get _userController => Get.find<UserStateController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final upcomingMeetups = _meetupController.upcomingMeetups;
      // 检查加载或刷新状态
      final isLoading = _meetupController.isLoading.value || _meetupController.isRefreshing.value;

      if (isLoading) {
        return _buildLoadingState(context);
      }

      if (upcomingMeetups.isEmpty) {
        return HomeMeetupEmptyState(isMobile: isMobile);
      }

      return _buildMeetupsContent(context, upcomingMeetups);
    });
  }

  Widget _buildLoadingState(BuildContext context) {
    // 首页是横向滚动的卡片，骨架屏也要匹配
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题骨架
        _buildHeaderSkeleton(),
        SizedBox(height: 24.h),
        // 横向卡片骨架
        SizedBox(
          height: 300.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) => _buildMeetupCardSkeleton(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 180.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: 120.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
        Container(
          width: 80.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ],
    );
  }

  Widget _buildMeetupCardSkeleton() {
    return Container(
      width: 280.w,
      margin: EdgeInsets.only(right: 16.w),
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
          // 封面图
          Container(
            height: 140.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Container(
                  width: 200.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 10.h),
                // 时间
                Container(
                  width: 150.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                // 地点
                Container(
                  width: 180.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetupsContent(BuildContext context, List upcomingMeetups) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏
        _buildHeader(context, l10n, upcomingMeetups.length),
        SizedBox(height: 24.h),
        // Meetup 列表
        _buildMeetupList(upcomingMeetups),
        // 移动端查看全部按钮
        if (isMobile) ...[
          SizedBox(height: 16.h),
          _buildViewAllButton(l10n),
        ],
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.nextMeetups,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              l10n.upcomingEventsCount(count),
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
        Row(
          children: [
            _buildCreateButton(context, l10n),
            if (!isMobile) ...[
              SizedBox(width: 12.w),
              _buildViewAllButtonDesktop(l10n),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context, AppLocalizations l10n) {
    return Obx(() => ElevatedButton.icon(
          onPressed: _userController.isLoggedIn
              ? () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateMeetupPage()),
                  )
              : () => AppToast.warning(l10n.pleaseLoginToCreateMeetup, title: l10n.loginRequired),
          icon: Icon(FontAwesomeIcons.plus, size: 18.r),
          label: Text(isMobile ? l10n.create : l10n.createMeetup),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4458),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 8 : 12,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        ));
  }

  Widget _buildViewAllButtonDesktop(AppLocalizations l10n) {
    return OutlinedButton.icon(
      onPressed: () => Get.toNamed(AppRoutes.meetupsList),
      icon: Icon(FontAwesomeIcons.arrowRight, size: 20.r, color: Color(0xFFFF4458)),
      label: Text(
        l10n.viewAllMeetups,
        style: TextStyle(
          color: Color(0xFFFF4458),
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        side: BorderSide(color: Color(0xFFFF4458), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  Widget _buildMeetupList(List upcomingMeetups) {
    return SizedBox(
      height: 300.h,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.8 &&
              !_meetupController.isLoadingMore.value &&
              _meetupController.hasMoreData) {
            log('📜 接近滚动末尾，触发加载更多活动');
            _meetupController.loadMoreMeetups();
          }
          return false;
        },
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: upcomingMeetups.length + (_meetupController.hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == upcomingMeetups.length) {
              return _buildLoadMoreIndicator();
            }
            return HomeMeetupCard(meetup: upcomingMeetups[index], isMobile: isMobile);
          },
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      width: 60.w,
      margin: EdgeInsets.only(left: 12.w),
      child: Center(
        child: Obx(() => _meetupController.isLoadingMore.value
            ? CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
              )
            : const SizedBox.shrink()),
      ),
    );
  }

  Widget _buildViewAllButton(AppLocalizations l10n) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () => Get.toNamed(AppRoutes.meetupsList),
        icon: Icon(FontAwesomeIcons.arrowRight, size: 20.r, color: Color(0xFFFF4458)),
        label: Text(
          l10n.viewAllMeetups,
          style: TextStyle(
            color: Color(0xFFFF4458),
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          side: BorderSide(color: Color(0xFFFF4458), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
      ),
    );
  }
}

/// Meetup 空状态组件
class HomeMeetupEmptyState extends StatelessWidget {
  final bool isMobile;

  const HomeMeetupEmptyState({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 40 : 60,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? 100 : 120,
            height: isMobile ? 100 : 120,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.userGroup,
              size: isMobile ? 50 : 60,
              color: const Color(0xFF10B981),
            ),
          ),
          SizedBox(height: isMobile ? 24 : 32),
          Text(
            'No Meetups Available',
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Be the first to create a meetup and connect\nwith fellow nomads in your city',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: isMobile ? 32 : 40),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateMeetupPage()),
            ),
            icon: Icon(FontAwesomeIcons.circlePlus, size: 20.r),
            label: Text(
              'Create Meetup',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32,
                vertical: isMobile ? 14 : 16,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
          ),
        ],
      ),
    );
  }
}
