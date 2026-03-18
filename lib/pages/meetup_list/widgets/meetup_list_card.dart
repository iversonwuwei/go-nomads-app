import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/create_meetup/create_meetup_page.dart';
import 'package:go_nomads_app/pages/meetup_list/meetup_list_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/edit_button.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
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
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域（带日期悬浮标签）
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          child: (meetup.images.isNotEmpty && meetup.images.first.isNotEmpty)
              ? Image.network(
                  meetup.images.first,
                  width: double.infinity,
                  height: 190.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
        
        // 分类标签 (左上角悬浮)
        Positioned(
          top: 12.h,
          left: 12.w,
          child: _MeetupFloatTypeChip(
            type: meetup.eventType?.getDisplayName(
                  Localizations.localeOf(context).languageCode,
                ) ??
                meetup.type.value,
          ),
        ),

        // 底部渐变叠加 (为了悬浮文字更清晰，可选)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80.h,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // 日期悬浮标签 (右下角落基于图片之上)
        Positioned(
          bottom: 12.h,
          right: 12.w,
          child: _buildDateBadge(context),
        ),

        // 已取消标识
        if (meetup.status == MeetupStatus.cancelled) _buildCancelledOverlay(),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 190.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Center(
        child: Icon(
          FontAwesomeIcons.calendarDays,
          size: 50.sp,
          color: const Color(0xFFD0D0D0),
        ),
      ),
    );
  }

  Widget _buildCancelledOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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

  Widget _buildDateBadge(BuildContext context) {
    final date = meetup.schedule.startTime;

    // 自定义格式，比如 "Apr 12"
    final monthStr = DateFormat('MMM').format(date);
    final dayStr = DateFormat('dd').format(date);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            monthStr.toUpperCase(),
            style: TextStyle(
              color: const Color(0xFFFF4458),
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            dayStr,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Meetup 卡片悬浮类型标签
class _MeetupFloatTypeChip extends StatelessWidget {
  final String type;

  const _MeetupFloatTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(type);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            type,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    final typeLower = type.toLowerCase();
    if (typeLower.contains('coffee') || typeLower.contains('咖啡')) return Colors.brown;
    if (typeLower.contains('coworking') ||
        typeLower.contains('business') ||
        typeLower.contains('共享办公') ||
        typeLower.contains('商务')) return Colors.blue;
    if (typeLower.contains('activity') ||
        typeLower.contains('outdoor') ||
        typeLower.contains('户外') ||
        typeLower.contains('徒步')) return Colors.green;
    if (typeLower.contains('language') || typeLower.contains('语言')) return Colors.purple;
    if (typeLower.contains('social') ||
        typeLower.contains('社交') ||
        typeLower.contains('networking') ||
        typeLower.contains('网络')) return Colors.orange;
    if (typeLower.contains('tech') ||
        typeLower.contains('workshop') ||
        typeLower.contains('技术') ||
        typeLower.contains('工作坊')) return Colors.indigo;
    if (typeLower.contains('food') ||
        typeLower.contains('dinner') ||
        typeLower.contains('美食') ||
        typeLower.contains('饮品')) return Colors.red;
    if (typeLower.contains('sports') ||
        typeLower.contains('fitness') ||
        typeLower.contains('运动') ||
        typeLower.contains('健身')) return Colors.teal;
    if (typeLower.contains('culture') ||
        typeLower.contains('art') ||
        typeLower.contains('文化') ||
        typeLower.contains('艺术')) return Colors.pink;
    if (typeLower.contains('yoga') ||
        typeLower.contains('meditation') ||
        typeLower.contains('瑜伽') ||
        typeLower.contains('冥想')) return const Color(0xFF4CAF50);
    return const Color(0xFF9C27B0);
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
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            meetup.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),

          // 时间和地点行
          _MeetupInfoGrid(meetup: meetup),
          SizedBox(height: 16.h),
          
          Divider(color: AppColors.borderLight, height: 1),
          SizedBox(height: 16.h),

          // 底部控制去：参与者状况, 组织者和操作按钮
          _MeetupCardFooter(
            meetup: meetup,
            currentTabIndex: currentTabIndex,
            isInCancelledContext: isInCancelledContext,
            isInPastContext: isInPastContext,
            isFull: _isFull,
            onToggleJoin: onToggleJoin,
            remainingSlots: _remainingSlots,
          ),
        ],
      ),
    );
  }
}

/// Meetup 信息网格（时间和地点）
class _MeetupInfoGrid extends StatelessWidget {
  final Meetup meetup;
  
  const _MeetupInfoGrid({required this.meetup});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfoItem(
          context,
          icon: FontAwesomeIcons.clock,
          text: _formatTime(context),
          color: meetup.isStartingSoon ? const Color(0xFFFF4458) : AppColors.textSecondary,
        ),
        SizedBox(height: 8.h),
        _buildInfoItem(
          context,
          icon: FontAwesomeIcons.locationDot,
          text: [
            if (meetup.venue.name.isNotEmpty) meetup.venue.name,
            meetup.location.fullDescription,
          ].where((s) => s.isNotEmpty).join(', '),
        ),
      ],
    );
  }
  
  Widget _buildInfoItem(BuildContext context, {required IconData icon, required String text, Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Icon(icon, size: 12.sp, color: color ?? AppColors.textSecondary),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: color ?? AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatTime(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateTime = meetup.schedule.startTime;
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return '${l10n.today} ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays == 1) {
      return '${l10n.tomorrow} ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('MMM dd, HH:mm').format(dateTime); // e.g. Apr 12, 14:00
    }
  }
}

/// Meetup 卡片底部（组织者、参与情况和操作按钮）
class _MeetupCardFooter extends StatelessWidget {
  final Meetup meetup;
  final int currentTabIndex;
  final bool isInCancelledContext;
  final bool isInPastContext;
  final bool isFull;
  final int remainingSlots;
  final VoidCallback? onToggleJoin;

  const _MeetupCardFooter({
    required this.meetup,
    required this.currentTabIndex,
    required this.isInCancelledContext,
    required this.isInPastContext,
    required this.isFull,
    required this.remainingSlots,
    this.onToggleJoin,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<MeetupListController>();

    return Row(
      children: [
        // 组织者头像带标签
        Stack(
          clipBehavior: Clip.none,
          children: [
            SafeCircleAvatar(
              imageUrl: meetup.organizer.avatarUrl,
              radius: 18.r,
            ),
            Positioned(
              bottom: -4.h,
              right: -4.w,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FontAwesomeIcons.crown,
                  size: 8.sp,
                  color: Colors.amber,
                ),
              ),
            )
          ],
        ),
        SizedBox(width: 10.w),
        // 参与人数据
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'By ${meetup.organizer.name}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                '${meetup.capacity.currentAttendees}/${meetup.capacity.maxAttendees} attendees',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isFull ? Colors.orange : (remainingSlots <= 3 ? Colors.red : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        
        // === 操作按钮区域 ===
        if (isInCancelledContext)
          _buildStatusBadge(l10n.statusCancelled)
        else if (isInPastContext)
          _buildStatusBadge(l10n.ended)
        else ...[
          if (meetup.isOrganizer)
            AppEditButton(
              onPressed: () async {
                await NavigationUtil.toWithCallback<bool>(
                  page: () => CreateMeetupPage(editingMeetup: meetup),
                  onResult: (result) {
                    if (result.needsRefresh) {
                      controller.refreshCurrentTab();
                    }
                  },
                );
              },
              size: 16.r,
              mini: true,
            ),
          if (meetup.isOrganizer) SizedBox(width: 8.w),
          
          if (meetup.isJoined || meetup.isOrganizer) _buildChatButton(context, l10n),
          if (meetup.isJoined || meetup.isOrganizer) SizedBox(width: 8.w),
          
          if (!meetup.isOrganizer) _buildJoinButton(l10n),
          
          if (meetup.isOrganizer) _buildCancelButton(context, l10n, controller),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildJoinButton(AppLocalizations l10n) {
    if (isFull && !meetup.isJoined) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          l10n.full,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onToggleJoin,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: meetup.isJoined ? Colors.grey.withOpacity(0.1) : const Color(0xFFFF4458),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              meetup.isJoined ? FontAwesomeIcons.check : FontAwesomeIcons.plus,
              size: 12.sp,
              color: meetup.isJoined ? AppColors.textSecondary : Colors.white,
            ),
            SizedBox(width: 6.w),
            Text(
              meetup.isJoined ? l10n.joined : l10n.join,
              style: TextStyle(
                color: meetup.isJoined ? AppColors.textSecondary : Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: FaIcon(
          FontAwesomeIcons.solidCommentDots,
          size: 14.sp,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, AppLocalizations l10n, MeetupListController controller) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: Text(l10n.confirmCancelMeetupTitle),
            content: Text(l10n.confirmCancelMeetupMessage),
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
                child: Text(l10n.confirm),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          final success = await controller.handleCancelMeetup(meetup);
          if (success) {
            AppToast.success(l10n.cancelMeetupSuccess, title: l10n.success);
          } else {
            AppToast.error(l10n.cancelMeetupFailed);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.all(10.w),
        margin: EdgeInsets.only(left: 8.w),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: FaIcon(
          FontAwesomeIcons.trashCan,
          size: 14.sp,
          color: Colors.red,
        ),
      ),
    );
  }
}
