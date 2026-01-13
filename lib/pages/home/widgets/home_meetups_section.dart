import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:df_admin_mobile/features/user/presentation/controllers/user_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/create_meetup_page.dart';
import 'package:df_admin_mobile/pages/home/widgets/home_meetup_card.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
        const SizedBox(height: 24),
        // 横向卡片骨架
        SizedBox(
          height: 300,
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
              width: 180,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        Container(
          width: 80,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildMeetupCardSkeleton() {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
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
          // 封面图
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Container(
                  width: 200,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                // 时间
                Container(
                  width: 150,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // 地点
                Container(
                  width: 180,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
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
        const SizedBox(height: 24),
        // Meetup 列表
        _buildMeetupList(upcomingMeetups),
        // 移动端查看全部按钮
        if (isMobile) ...[
          const SizedBox(height: 16),
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
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.upcomingEventsCount(count),
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        Row(
          children: [
            _buildCreateButton(context, l10n),
            if (!isMobile) ...[
              const SizedBox(width: 12),
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
          icon: const Icon(FontAwesomeIcons.plus, size: 18),
          label: Text(isMobile ? l10n.create : l10n.createMeetup),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4458),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 8 : 12,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ));
  }

  Widget _buildViewAllButtonDesktop(AppLocalizations l10n) {
    return OutlinedButton.icon(
      onPressed: () => Get.toNamed(AppRoutes.meetupsList),
      icon: const Icon(FontAwesomeIcons.arrowRight, size: 20, color: Color(0xFFFF4458)),
      label: Text(
        l10n.viewAllMeetups,
        style: const TextStyle(
          color: Color(0xFFFF4458),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: const BorderSide(color: Color(0xFFFF4458), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildMeetupList(List upcomingMeetups) {
    return SizedBox(
      height: 300,
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
      width: 60,
      margin: const EdgeInsets.only(left: 12),
      child: Center(
        child: Obx(() => _meetupController.isLoadingMore.value
            ? const CircularProgressIndicator(
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
        icon: const Icon(FontAwesomeIcons.arrowRight, size: 20, color: Color(0xFFFF4458)),
        label: Text(
          l10n.viewAllMeetups,
          style: const TextStyle(
            color: Color(0xFFFF4458),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: const BorderSide(color: Color(0xFFFF4458), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          const SizedBox(height: 12),
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
            icon: const Icon(FontAwesomeIcons.circlePlus, size: 20),
            label: const Text(
              'Create Meetup',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32,
                vertical: isMobile ? 14 : 16,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
