import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/core/navigation/navigation_result.dart';
import 'package:go_nomads_app/core/sync/refreshable_controller.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/create_meetup/create_meetup_page.dart';
import 'package:go_nomads_app/pages/home/home_page_controller.dart';
import 'package:go_nomads_app/pages/home/widgets/home_meetup_card.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// Meetups 区域组件
class HomeMeetupsSection extends StatelessWidget {
  final bool isMobile;

  const HomeMeetupsSection({super.key, required this.isMobile});

  HomePageController get _homeController => Get.find<HomePageController>();
  UserStateController get _userController => Get.find<UserStateController>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeController.onHomeVisible();
    });

    return Obx(() {
      final upcomingMeetups = _homeController.homeMeetups;
      final loadState = _homeController.homeMeetupsLoadState.value;

      // 1. 初始状态或首次加载中 → 显示骨架屏
      //    使用 loadState 而非 isLoading，避免业务操作（create/update）触发骨架屏
      if (loadState == LoadState.initial || loadState == LoadState.loading) {
        return _buildLoadingState(context);
      }

      // 2. 刷新中 → 有旧数据则继续展示旧数据，否则显示骨架屏
      if (loadState == LoadState.refreshing) {
        if (upcomingMeetups.isEmpty) {
          return _buildLoadingState(context);
        }
        // 有旧数据时继续显示，避免刷新时闪屏
      }

      // 3. 加载出错且无数据 → 显示错误状态+重试
      if (loadState == LoadState.error && upcomingMeetups.isEmpty) {
        return _buildErrorState(context);
      }

      // 4. 真正无数据 → 显示空状态
      if (upcomingMeetups.isEmpty) {
        return HomeMeetupEmptyState(
          isMobile: isMobile,
          onCreated: () => _homeController.loadHomeMeetups(forceRefresh: true),
        );
      }

      // 5. 正常数据展示
      return _buildMeetupsContent(context, upcomingMeetups);
    });
  }

  /// 错误状态 - 加载失败时显示，带重试按钮
  Widget _buildErrorState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: AppUiTokens.softFloatingShadow,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.travelAmber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Icon(
                FontAwesomeIcons.circleExclamation,
                size: 22.r,
                color: AppColors.travelAmber,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.meetupLoadFailed,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              _homeController.homeMeetupsErrorMessage.value ?? l10n.meetupLoadFailedDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            SizedBox(height: 20.h),
            OutlinedButton.icon(
              onPressed: () => _homeController.loadHomeMeetups(forceRefresh: true),
              icon: Icon(FontAwesomeIcons.arrowsRotate, size: 14.r),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
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
          height: 320.h,
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
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: 120.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ],
        ),
        Container(
          width: 80.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(16.r),
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
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: AppUiTokens.softFloatingShadow,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面图
          Container(
            height: 140.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(height: 10.h),
                // 时间
                Container(
                  width: 150.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(height: 8.h),
                // 地点
                Container(
                  width: 180.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.r),
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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.nextMeetups,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            SizedBox(height: 4.h),
            Text(
              l10n.upcomingEventsCount(count),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
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
              ? () => _openCreateMeetupAndRefresh(context)
              : () => AppToast.warning(l10n.pleaseLoginToCreateMeetup, title: l10n.loginRequired),
          icon: Icon(FontAwesomeIcons.plus, size: 14.r),
          label: Text(isMobile ? l10n.create : l10n.createMeetup),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 8 : 12,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          ),
        ));
  }

  Future<void> _openCreateMeetupAndRefresh(BuildContext context) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (context) => const CreateMeetupPage()),
    );

    final needsRefresh = result == true || (result is NavigationResult && result.needsRefresh);
    if (needsRefresh) {
      await _homeController.loadHomeMeetups(forceRefresh: true);
    }
  }

  Widget _buildViewAllButtonDesktop(AppLocalizations l10n) {
    return OutlinedButton.icon(
      onPressed: () => Get.toNamed(AppRoutes.meetupsList),
      icon: Icon(FontAwesomeIcons.arrowRight, size: 14.r),
      label: Text(
        l10n.viewAllMeetups,
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
    );
  }

  Widget _buildMeetupList(List upcomingMeetups) {
    return SizedBox(
      height: 346.h,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.8 &&
              !_homeController.isLoadingMoreHomeMeetups.value &&
              _homeController.hasMoreHomeMeetups.value) {
            log('📜 接近滚动末尾，触发加载更多活动');
            _homeController.loadMoreHomeMeetups();
          }
          return false;
        },
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: upcomingMeetups.length + (_homeController.hasMoreHomeMeetups.value ? 1 : 0),
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
        child: Obx(() => _homeController.isLoadingMoreHomeMeetups.value
            ? CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cityPrimary),
              )
            : const SizedBox.shrink()),
      ),
    );
  }

  Widget _buildViewAllButton(AppLocalizations l10n) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () => Get.toNamed(AppRoutes.meetupsList),
        icon: Icon(FontAwesomeIcons.arrowRight, size: 14.r),
        label: Text(
          l10n.viewAllMeetups,
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
      ),
    );
  }
}

/// Meetup 空状态组件
class HomeMeetupEmptyState extends StatelessWidget {
  final bool isMobile;
  final Future<void> Function()? onCreated;

  const HomeMeetupEmptyState({
    super.key,
    required this.isMobile,
    this.onCreated,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 20 : 28,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 32,
          vertical: isMobile ? 30 : 36,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppUiTokens.softFloatingShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isMobile ? 72 : 82,
              height: isMobile ? 72 : 82,
              decoration: BoxDecoration(
                color: AppColors.travelMint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                FontAwesomeIcons.userGroup,
                size: isMobile ? 28 : 32,
                color: AppColors.travelMint,
              ),
            ),
            SizedBox(height: isMobile ? 20 : 24),
            Text(
              l10n.noMeetupsAvailable,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            SizedBox(height: 10.h),
            Text(
              l10n.noMeetupsDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
            SizedBox(height: isMobile ? 24 : 28),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateMeetupPage()),
                );

                final needsRefresh = result == true || (result is NavigationResult && result.needsRefresh);
                if (needsRefresh && onCreated != null) {
                  await onCreated!();
                }
              },
              icon: Icon(FontAwesomeIcons.circlePlus, size: 16.r),
              label: Text(l10n.createMeetup),
            ),
          ],
        ),
      ),
    );
  }
}
