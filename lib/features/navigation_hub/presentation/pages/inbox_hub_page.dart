import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/navigation_hub/presentation/controllers/inbox_hub_controller.dart';
import 'package:go_nomads_app/features/navigation_hub/presentation/widgets/hub_action_card.dart';
import 'package:go_nomads_app/features/notification/domain/entities/app_notification.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/layouts/bottom_nav/bottom_nav_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_glass_icon_button.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_hero_banner.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_metric_card.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_section_header.dart';

class InboxHubPage extends GetView<InboxHubController> {
  const InboxHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navController = Get.find<BottomNavController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final unreadMessages = navController.imUnreadCount.value;
          final unreadNotifications = controller.unreadNotifications > 0
              ? controller.unreadNotifications
              : navController.unreadCount.value;
            final totalUnread = unreadMessages + unreadNotifications + controller.systemActionItems.length;

          return RefreshIndicator(
            color: AppColors.cityPrimary,
            onRefresh: controller.refreshSummary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 120.h),
              children: [
                CockpitHeroBanner(
                  icon: FontAwesomeIcons.inbox,
                  title: l10n.inboxHubTitle,
                  subtitle: '',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF1F2), Color(0xFFF7FAFC), Color(0xFFEAF4FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppColors.cityPrimary,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          '$totalUnread',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      CockpitGlassIconButton(
                        icon: Icons.refresh_rounded,
                        onTap: controller.refreshSummary,
                      ),
                    ],
                  ),
                  metrics: [
                    CockpitHeroMetric(
                      icon: Icons.mark_chat_unread_outlined,
                      label: '$unreadMessages ${l10n.messages}',
                    ),
                    CockpitHeroMetric(
                      icon: Icons.notifications_active_outlined,
                      label: '$unreadNotifications ${l10n.notifications}',
                    ),
                    CockpitHeroMetric(
                      icon: Icons.playlist_add_check_circle_outlined,
                      label: '${controller.unifiedActionCount} ${l10n.inboxActionRequired}',
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _InboxMetricCard(
                        icon: FontAwesomeIcons.solidCommentDots,
                        label: l10n.messages,
                        value: unreadMessages.toString(),
                        accentColor: const Color(0xFF457B9D),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _InboxMetricCard(
                        icon: FontAwesomeIcons.solidBell,
                        label: l10n.notifications,
                        value: unreadNotifications.toString(),
                        accentColor: const Color(0xFFFF6B6B),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _InboxMetricCard(
                        icon: FontAwesomeIcons.listCheck,
                        label: l10n.inboxActionRequired,
                        value: controller.unifiedActionCount.toString(),
                        accentColor: const Color(0xFF2A9D8F),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                CockpitSectionHeader(
                  title: l10n.inboxSystemActionCenter,
                ),
                SizedBox(height: 12.h),
                if (controller.isLoading.value && controller.systemActionItems.isEmpty)
                  const _InboxLoadingState()
                else if (controller.systemActionItems.isEmpty)
                  _InboxEmptyState(message: l10n.inboxSystemActionEmpty)
                else
                  ...controller.systemActionItems.map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: HubActionCard(
                        icon: item.routeName == AppRoutes.migrationWorkspace
                            ? FontAwesomeIcons.route
                            : item.routeName == AppRoutes.budgetCenter
                                ? FontAwesomeIcons.wallet
                                : item.routeName == AppRoutes.membershipPlan
                                    ? FontAwesomeIcons.gem
                                    : FontAwesomeIcons.passport,
                        title: item.title,
                        subtitle: '',
                        badgeCount: item.badgeCount,
                        onTap: () => Get.toNamed(item.routeName),
                      ),
                    ),
                  ),
                SizedBox(height: 18.h),
                HubActionCard(
                  icon: FontAwesomeIcons.solidCommentDots,
                  title: l10n.messages,
                  subtitle: '',
                  badgeCount: unreadMessages,
                  onTap: () => Get.toNamed(AppRoutes.conversations),
                ),
                SizedBox(height: 12.h),
                HubActionCard(
                  icon: FontAwesomeIcons.solidBell,
                  title: l10n.notifications,
                  subtitle: '',
                  badgeCount: unreadNotifications,
                  onTap: () => Get.toNamed(AppRoutes.notifications),
                ),
                CockpitSectionHeader(
                  title: l10n.inboxRecentNotifications,
                ),
                SizedBox(height: 12.h),
                if (controller.isLoading.value && controller.recentNotifications.isEmpty)
                  const _InboxLoadingState()
                else if (controller.errorMessage.value != null && controller.recentNotifications.isEmpty)
                  _InboxErrorState(
                    message: controller.errorMessage.value!,
                    retryLabel: l10n.migrationWorkspaceRetry,
                    onRetry: controller.refreshSummary,
                  )
                else if (controller.recentNotifications.isEmpty)
                  _InboxEmptyState(message: l10n.inboxNoRecentNotifications)
                else
                  ...controller.recentNotifications.take(3).map(
                    (notification) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _NotificationPreviewCard(notification: notification),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _InboxMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  const _InboxMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return CockpitMetricCard(
      icon: icon,
      label: label,
      value: value,
      accentColor: accentColor,
    );
  }
}

class _InboxLoadingState extends StatelessWidget {
  const _InboxLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Center(child: AppLoadingWidget(fullScreen: false)),
    );
  }
}

class _InboxErrorState extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const _InboxErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(
            message,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 14.h),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.cityPrimary,
              side: const BorderSide(color: AppColors.cityPrimary),
            ),
            child: Text(retryLabel),
          ),
        ],
      ),
    );
  }
}

class _InboxEmptyState extends StatelessWidget {
  final String message;

  const _InboxEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _NotificationPreviewCard extends StatelessWidget {
  final AppNotification notification;

  const _NotificationPreviewCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cityPrimaryLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              notification.type.icon,
              style: TextStyle(fontSize: 18.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  notification.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
