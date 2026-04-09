import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/notifications_page_controller.dart';
import 'package:go_nomads_app/features/notification/domain/entities/app_notification.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

/// 通知列表页面
/// 注意: 由于 TabController 需要 TickerProvider，保持 StatefulWidget 结构
/// 但业务逻辑已移至 NotificationsPageController
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  static const String _tag = 'NotificationsPage';
  late TabController _tabController;
  late NotificationsPageController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller = _useController();
  }

  NotificationsPageController _useController() {
    if (Get.isRegistered<NotificationsPageController>(tag: _tag)) {
      return Get.find<NotificationsPageController>(tag: _tag);
    }
    return Get.put(NotificationsPageController(), tag: _tag);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('📱 NotificationsPage.build() 开始');

    final isMobile = MediaQuery.of(context).size.width < 768;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            final items = _buildNavItems(l10n);
            final currentIndex = _tabController.index;
            final currentItem = items[currentIndex];

            return _buildNotificationScrollView(
              isMobile: isMobile,
              l10n: l10n,
              items: items,
              currentIndex: currentIndex,
              currentItem: currentItem,
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationScrollView({
    required bool isMobile,
    required AppLocalizations l10n,
    required List<_NotificationNavItem> items,
    required int currentIndex,
    required _NotificationNavItem currentItem,
  }) {
    return Obx(() {
      final notificationController = _controller.notificationController;
      final isLoading = notificationController.isLoading.value &&
          notificationController.notifications.isEmpty &&
          !_controller.isRefreshing.value;
      final notifications = notificationController.notifications
          .where((n) => currentItem.isReadFilter == null || n.isRead == currentItem.isReadFilter)
          .toList();

      final content = RefreshIndicator(
        onRefresh: _controller.handleRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(l10n)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
                child: _NotificationCompactToolbar(
                  items: items,
                  currentIndex: currentIndex,
                  currentItem: currentItem,
                  onTabSelected: _switchTab,
                ),
              ),
            ),
            if (notificationController.errorMessage.value.isNotEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildErrorState(
                  notificationController.errorMessage.value,
                  () => notificationController.loadNotifications(isRead: currentItem.isReadFilter),
                ),
              )
            else if (notifications.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyStateForFilter(context, currentItem.isReadFilter),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(isMobile ? 8.w : 16.w, 0, isMobile ? 8.w : 16.w, 16.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final notification = notifications[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: index == notifications.length - 1 ? 0 : 8.h),
                        child: _buildNotificationCard(notification, isMobile),
                      );
                    },
                    childCount: notifications.length,
                  ),
                ),
              ),
          ],
        ),
      );

      return AppLoadingSwitcher(
        isLoading: isLoading,
        loading: const NotificationListSkeleton(),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(currentIndex),
            child: content,
          ),
        ),
      );
    });
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.notifications,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Keep system, community, and action-required updates in one mission stream.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final hasUnread = _controller.notificationController.unreadCount.value > 0;
            return hasUnread
                ? FilledButton.tonalIcon(
                    onPressed: _controller.markAllAsRead,
                    icon: const Icon(FontAwesomeIcons.checkDouble),
                    label: Text(l10n.markAllAsRead),
                  )
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  List<_NotificationNavItem> _buildNavItems(AppLocalizations l10n) {
    return [
      _NotificationNavItem(
        index: 0,
        label: l10n.allNotifications,
        subtitle: 'A full audit trail of system, city, meetup, and workflow activity.',
        icon: FontAwesomeIcons.inbox,
        accent: const Color(0xFF1E5C7A),
        isReadFilter: null,
      ),
      _NotificationNavItem(
        index: 1,
        label: l10n.unread,
        subtitle: 'Prioritize action-needed items before they get buried in the stream.',
        icon: FontAwesomeIcons.bell,
        accent: const Color(0xFF7B3559),
        isReadFilter: false,
      ),
      _NotificationNavItem(
        index: 2,
        label: l10n.read,
        subtitle: 'Review handled updates without mixing them into the active queue.',
        icon: FontAwesomeIcons.envelopeOpen,
        accent: const Color(0xFF2F6A48),
        isReadFilter: true,
      ),
    ];
  }

  void _switchTab(int index) {
    _tabController.animateTo(index);
    _controller.loadNotificationsByTab(index);
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.circleExclamation, size: 64.r, color: AppColors.iconSecondary),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(Get.context!)!.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateForFilter(BuildContext context, bool? isRead) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.bell, size: 64.r, color: AppColors.iconSecondary),
          SizedBox(height: 16.h),
          Text(
            isRead == null
                ? AppLocalizations.of(context)!.noNotifications
                : isRead
                    ? AppLocalizations.of(context)!.noReadNotifications
                    : AppLocalizations.of(context)!.noUnreadNotifications,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification, bool isMobile) {
    final color = Color(
      int.parse(notification.type.colorHex.substring(1), radix: 16) + 0xFF000000,
    );

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: const Icon(FontAwesomeIcons.trash, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _controller.deleteNotification(notification.id),
      child: InkWell(
        onTap: () async {
          if (!notification.isRead) {
            await _controller.markAsRead(notification.id);
          }
          _controller.handleNotificationTap(notification);
        },
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : AppColors.accent.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: notification.isRead ? AppColors.border : AppColors.accent.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图标
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    notification.type.icon,
                    style: TextStyle(fontSize: 24.sp),
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: isMobile ? 15 : 16,
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),

                        // 未读指示器
                        if (!notification.isRead)
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    // 消息内容
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8.h),

                    // 时间
                    Text(
                      _controller.formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationNavItem {
  const _NotificationNavItem({
    required this.index,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.isReadFilter,
  });

  final int index;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final bool? isReadFilter;
}

class _NotificationPill extends StatelessWidget {
  const _NotificationPill({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NotificationNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [item.accent, Color.lerp(item.accent, Colors.black, 0.18) ?? item.accent],
                  )
                : null,
            color: isActive ? null : Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: isActive ? Colors.transparent : const Color(0xFFE9E2D8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 12.r, color: isActive ? Colors.white : AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCompactToolbar extends StatelessWidget {
  const _NotificationCompactToolbar({
    required this.items,
    required this.currentIndex,
    required this.currentItem,
    required this.onTabSelected,
  });

  final List<_NotificationNavItem> items;
  final int currentIndex;
  final _NotificationNavItem currentItem;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE7DED0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: currentItem.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(currentItem.icon, size: 14.r, color: currentItem.accent),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentItem.label,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      currentItem.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${currentIndex + 1}/${items.length}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                return Padding(
                  padding: EdgeInsets.only(right: index == items.length - 1 ? 0 : 8.w),
                  child: _NotificationPill(
                    item: item,
                    isActive: currentIndex == index,
                    onTap: () => onTabSelected(index),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
