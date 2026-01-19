import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/create_meetup/create_meetup_page.dart';
import 'package:go_nomads_app/pages/meetup_list/meetup_list_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/edit_button.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Meetup 列表卡片组件
class MeetupListCard extends StatelessWidget {
  final Meetup meetup;
  final int currentTabIndex;
  final VoidCallback? onTap;
  final VoidCallback? onToggleJoin;

  const MeetupListCard({
    super.key,
    required this.meetup,
    required this.currentTabIndex,
    this.onTap,
    this.onToggleJoin,
  });

  // Tab 索引常量
  static const int _tabCancelled = 3;
  static const int _tabPast = 2;

  // 是否在"已取消"Tab 或活动本身已取消
  bool get _isInCancelledContext => currentTabIndex == _tabCancelled || meetup.isCancelled;

  // 是否在"过往"Tab 或活动已结束
  bool get _isInPastContext => currentTabIndex == _tabPast || meetup.isEnded;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域
            _MeetupCardImage(meetup: meetup),
            // 内容区域
            _MeetupCardContent(
              meetup: meetup,
              currentTabIndex: currentTabIndex,
              isInCancelledContext: _isInCancelledContext,
              isInPastContext: _isInPastContext,
              onToggleJoin: onToggleJoin,
            ),
          ],
        ),
      ),
    );
  }
}

/// Meetup 卡片图片组件
class _MeetupCardImage extends StatelessWidget {
  final Meetup meetup;

  const _MeetupCardImage({required this.meetup});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          child: (meetup.images.isNotEmpty && meetup.images.first.isNotEmpty)
              ? Image.network(
                  meetup.images.first,
                  width: double.infinity,
                  height: 180.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
        // 已取消标识
        if (meetup.status == MeetupStatus.cancelled) _buildCancelledOverlay(),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Center(
        child: Icon(
          FontAwesomeIcons.calendarDays,
          size: 64.sp,
          color: const Color(0xFFBDBDBD),
        ),
      ),
    );
  }

  Widget _buildCancelledOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '已取消',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Meetup 卡片内容组件
class _MeetupCardContent extends StatelessWidget {
  final Meetup meetup;
  final int currentTabIndex;
  final bool isInCancelledContext;
  final bool isInPastContext;
  final VoidCallback? onToggleJoin;

  const _MeetupCardContent({
    required this.meetup,
    required this.currentTabIndex,
    required this.isInCancelledContext,
    required this.isInPastContext,
    this.onToggleJoin,
  });

  int get _remainingSlots => meetup.capacity.maxAttendees - meetup.capacity.currentAttendees;
  bool get _isFull => _remainingSlots <= 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和类型
          _MeetupCardHeader(meetup: meetup),
          SizedBox(height: 12.h),
          // 时间
          _MeetupCardInfoRow(
            icon: FontAwesomeIcons.clock,
            text: _formatDateTime(context, meetup.schedule.startTime),
            color: meetup.isStartingSoon ? const Color(0xFFFF4458) : null,
          ),
          SizedBox(height: 8.h),
          // 地点
          _MeetupCardInfoRow(
            icon: FontAwesomeIcons.locationDot,
            text: [
              if (meetup.venue.name.isNotEmpty) meetup.venue.name,
              meetup.location.fullDescription,
            ].where((s) => s.isNotEmpty).join(', '),
          ),
          SizedBox(height: 8.h),
          // 参与人数
          _MeetupCardInfoRow(
            icon: FontAwesomeIcons.users,
            text:
                '${meetup.capacity.currentAttendees}/${meetup.capacity.maxAttendees} attendees · $_remainingSlots spots left',
            color: _isFull ? Colors.orange : (_remainingSlots <= 3 ? Colors.red : null),
          ),
          SizedBox(height: 16.h),
          // 组织者和操作按钮
          _MeetupCardFooter(
            meetup: meetup,
            currentTabIndex: currentTabIndex,
            isInCancelledContext: isInCancelledContext,
            isInPastContext: isInPastContext,
            isFull: _isFull,
            onToggleJoin: onToggleJoin,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return '${l10n.today} ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays == 1) {
      return '${l10n.tomorrow} ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('MMM dd, HH:mm').format(dateTime);
    }
  }
}

/// Meetup 卡片头部（标题和类型）
class _MeetupCardHeader extends StatelessWidget {
  final Meetup meetup;

  const _MeetupCardHeader({required this.meetup});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            meetup.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        _MeetupTypeChip(
          type: meetup.eventType?.getDisplayName(
                Localizations.localeOf(context).languageCode,
              ) ??
              meetup.type.value,
        ),
      ],
    );
  }
}

/// Meetup 类型标签
class _MeetupTypeChip extends StatelessWidget {
  final String type;

  const _MeetupTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(type);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    final typeLower = type.toLowerCase();
    if (typeLower.contains('coffee') || typeLower.contains('咖啡')) {
      return Colors.brown;
    } else if (typeLower.contains('coworking') ||
        typeLower.contains('business') ||
        typeLower.contains('共享办公') ||
        typeLower.contains('商务')) {
      return Colors.blue;
    } else if (typeLower.contains('activity') ||
        typeLower.contains('outdoor') ||
        typeLower.contains('户外') ||
        typeLower.contains('徒步')) {
      return Colors.green;
    } else if (typeLower.contains('language') || typeLower.contains('语言')) {
      return Colors.purple;
    } else if (typeLower.contains('social') ||
        typeLower.contains('社交') ||
        typeLower.contains('networking') ||
        typeLower.contains('网络')) {
      return Colors.orange;
    } else if (typeLower.contains('tech') ||
        typeLower.contains('workshop') ||
        typeLower.contains('技术') ||
        typeLower.contains('工作坊')) {
      return Colors.indigo;
    } else if (typeLower.contains('food') ||
        typeLower.contains('dinner') ||
        typeLower.contains('美食') ||
        typeLower.contains('饮品')) {
      return Colors.red;
    } else if (typeLower.contains('sports') ||
        typeLower.contains('fitness') ||
        typeLower.contains('运动') ||
        typeLower.contains('健身')) {
      return Colors.teal;
    } else if (typeLower.contains('culture') ||
        typeLower.contains('art') ||
        typeLower.contains('文化') ||
        typeLower.contains('艺术')) {
      return Colors.pink;
    } else if (typeLower.contains('yoga') ||
        typeLower.contains('meditation') ||
        typeLower.contains('瑜伽') ||
        typeLower.contains('冥想')) {
      return const Color(0xFF4CAF50);
    } else {
      return const Color(0xFF9C27B0);
    }
  }
}

/// Meetup 卡片信息行
class _MeetupCardInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _MeetupCardInfoRow({
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color ?? AppColors.textSecondary),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: color ?? AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Meetup 卡片底部（组织者和操作按钮）
class _MeetupCardFooter extends StatelessWidget {
  final Meetup meetup;
  final int currentTabIndex;
  final bool isInCancelledContext;
  final bool isInPastContext;
  final bool isFull;
  final VoidCallback? onToggleJoin;

  const _MeetupCardFooter({
    required this.meetup,
    required this.currentTabIndex,
    required this.isInCancelledContext,
    required this.isInPastContext,
    required this.isFull,
    this.onToggleJoin,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<MeetupListController>();

    return Row(
      children: [
        SafeCircleAvatar(
          imageUrl: meetup.organizer.avatarUrl,
          radius: 16.r,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            meetup.organizer.name,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        // === 过往/已取消 Tab: 只显示一个置灰状态按钮 ===
        if (isInCancelledContext)
          _buildStatusBadge(l10n.statusCancelled)
        else if (isInPastContext)
          _buildStatusBadge(l10n.ended)
        // === 正常 Tab: 显示完整操作按钮 ===
        else ...[
          // 编辑按钮 - 只有组织者可见
          if (meetup.isOrganizer)
            AppEditButton(
              onPressed: () async {
                final result = await Get.to(() => CreateMeetupPage(editingMeetup: meetup));
                if (result == true) {
                  controller.refreshCurrentTab();
                }
              },
              size: 14.r,
              mini: true,
            ),
          if (meetup.isOrganizer) SizedBox(width: 8.w),
          // 聊天按钮 - 只有已加入或组织者可见
          if (meetup.isJoined || meetup.isOrganizer) _buildChatButton(context, l10n),
          if (meetup.isJoined || meetup.isOrganizer) SizedBox(width: 8.w),
          // 加入按钮 - 只有非组织者可见
          if (!meetup.isOrganizer) _buildJoinButton(l10n),
          // 取消活动按钮 - 只有组织者可见
          if (meetup.isOrganizer) _buildCancelButton(context, l10n, controller),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildJoinButton(AppLocalizations l10n) {
    // 如果活动已满且用户未加入
    if (isFull && !meetup.isJoined) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          l10n.full,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // 普通用户：显示加入/已加入按钮
    return GestureDetector(
      onTap: onToggleJoin,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4458).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: FaIcon(
          meetup.isJoined ? FontAwesomeIcons.userCheck : FontAwesomeIcons.userPlus,
          size: 14.sp,
          color: const Color(0xFFFF4458),
        ),
      ),
    );
  }

  Widget _buildChatButton(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        if (!meetup.isJoined && !meetup.isOrganizer) {
          AppToast.warning(
            l10n.joinToAccessChat,
            title: l10n.joinRequired,
          );
          return;
        }

        Get.toNamed(
          AppRoutes.cityChat,
          arguments: {
            'city': meetup.title,
            'country': '${meetup.type} Meetup',
            'meetupId': meetup.id,
            'isMeetupChat': true,
          },
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: FaIcon(
          FontAwesomeIcons.message,
          size: 14.sp,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, AppLocalizations l10n, MeetupListController controller) {
    return GestureDetector(
      onTap: () async {
        // 显示确认对话框
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('取消活动'),
            content: const Text('确定要取消这个活动吗？此操作无法撤销。'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('确定'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          final success = await controller.handleCancelMeetup(meetup);
          if (success) {
            AppToast.success('活动已取消', title: '成功');
          } else {
            AppToast.error('取消活动失败');
          }
        }
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: FaIcon(
          FontAwesomeIcons.ban,
          size: 14.sp,
          color: Colors.red,
        ),
      ),
    );
  }
}
