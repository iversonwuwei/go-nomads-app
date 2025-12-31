import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';
import 'package:df_admin_mobile/features/meetup/domain/repositories/i_meetup_repository.dart';
import 'package:df_admin_mobile/features/meetup/infrastructure/repositories/meetup_repository.dart';
import 'package:df_admin_mobile/features/meetup/presentation/controllers/meetup_state_controller_v2.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// Meetup 卡片组件 - Nomads.com 风格
class HomeMeetupCard extends StatelessWidget {
  final Meetup meetup;
  final bool isMobile;

  const HomeMeetupCard({
    super.key,
    required this.meetup,
    required this.isMobile,
  });

  MeetupStateControllerV2 get _meetupController => Get.find<MeetupStateControllerV2>();

  bool _isJoined(RxList<String> rsvpedIds) {
    return rsvpedIds.contains(meetup.id) || meetup.isJoined;
  }

  @override
  Widget build(BuildContext context) {
    final date = meetup.schedule.startTime;

    return Obx(() {
      final isJoined = _isJoined(_meetupController.rsvpedMeetupIds);
      final currentAttendees = meetup.capacity.currentAttendees;
      final maxAttendees = meetup.capacity.maxAttendees;
      final isFull = currentAttendees >= maxAttendees;
      final authController = Get.find<AuthStateController>();
      final isOrganizer =
          authController.isAuthenticated.value && meetup.organizer.id == authController.currentUser.value?.id;

      return Container(
        width: isMobile ? 280 : 320,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.borderLight, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图片区域
              _buildImageSection(context),
              // 内容区域
              _buildContentSection(context, date),
              // 操作按钮
              _buildActionButtons(context, isJoined, isFull, isOrganizer),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildImageSection(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.meetupDetail, arguments: meetup),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              meetup.images.isNotEmpty
                  ? meetup.images.first
                  : 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400',
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getTypeColor(meetup.eventType?.enName ?? meetup.type.value),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                meetup.eventType?.name ?? meetup.type.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, DateTime date) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.meetupDetail, arguments: meetup),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              meetup.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // 日期和地点
            _buildDateLocation(date),
            const SizedBox(height: 8),
            // 参与者信息
            _buildAttendeeInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateLocation(DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(FontAwesomeIcons.calendar, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(FontAwesomeIcons.locationDot, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                [
                  if (meetup.venue.name.isNotEmpty) meetup.venue.name,
                  meetup.location.fullDescription,
                ].where((s) => s.isNotEmpty).join(', '),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendeeInfo() {
    final currentAttendees = meetup.capacity.currentAttendees;
    final maxAttendees = meetup.capacity.maxAttendees;

    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FontAwesomeIcons.users, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              '$currentAttendees',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        if ((maxAttendees - currentAttendees) > 0)
          Text(
            '${maxAttendees - currentAttendees} left',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFFF4458),
              fontWeight: FontWeight.w600,
            ),
          ),
        const Spacer(),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FontAwesomeIcons.user, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  meetup.organizer.name,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isJoined, bool isFull, bool isOrganizer) {
    final l10n = AppLocalizations.of(context)!;
    final status = meetup.status;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: _buildButtonContent(context, l10n, status, isJoined, isFull, isOrganizer),
    );
  }

  Widget _buildButtonContent(
    BuildContext context,
    AppLocalizations l10n,
    MeetupStatus status,
    bool isJoined,
    bool isFull,
    bool isOrganizer,
  ) {
    // 已取消
    if (status == MeetupStatus.cancelled) {
      return _buildDisabledButton(FontAwesomeIcons.ban, isOrganizer ? '已取消' : '活动已取消');
    }

    // 已结束
    if (status == MeetupStatus.completed || meetup.isEnded) {
      return _buildDisabledButton(FontAwesomeIcons.circleCheck, isOrganizer ? '已结束' : '活动已结束');
    }

    // 组织者按钮
    if (isOrganizer) {
      return _buildOrganizerButtons(context);
    }

    // 普通用户按钮
    return _buildUserButtons(context, l10n, isJoined, isFull);
  }

  Widget _buildDisabledButton(IconData icon, String text) {
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.borderLight,
          foregroundColor: AppColors.textSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          disabledBackgroundColor: AppColors.borderLight,
          disabledForegroundColor: AppColors.textSecondary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 4),
            Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizerButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildChatButton(context, true)),
        const SizedBox(width: 6),
        Expanded(child: _buildCancelButton(context)),
      ],
    );
  }

  Widget _buildUserButtons(BuildContext context, AppLocalizations l10n, bool isJoined, bool isFull) {
    return Row(
      children: [
        Expanded(child: _buildChatButton(context, isJoined)),
        const SizedBox(width: 6),
        Expanded(child: _buildJoinButton(context, l10n, isJoined, isFull)),
      ],
    );
  }

  Widget _buildChatButton(BuildContext context, bool enabled) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 32,
      child: OutlinedButton(
        onPressed: enabled
            ? () {
                final authController = Get.find<AuthStateController>();
                if (!authController.isAuthenticated.value) {
                  AppToast.warning(l10n.pleaseLoginToCreateMeetup, title: l10n.loginRequired);
                  Get.toNamed(AppRoutes.login);
                  return;
                }
                Get.toNamed(AppRoutes.cityChat, arguments: {
                  'city': meetup.title,
                  'country': '${meetup.type} Meetup',
                  'meetupId': meetup.id,
                  'isMeetupChat': true,
                });
              }
            : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: enabled ? Colors.blue : Colors.grey,
          side: BorderSide(
            color: enabled ? Colors.blue : Colors.grey.shade300,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          backgroundColor: enabled ? null : Colors.grey.shade50,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.message, size: 14),
            SizedBox(width: 3),
            Flexible(
              child: Text('Chat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () => _handleCancelMeetup(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.ban, size: 14),
            SizedBox(width: 4),
            Flexible(
              child: Text('取消活动', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context, AppLocalizations l10n, bool isJoined, bool isFull) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: (isFull && !isJoined) ? null : () => _handleToggleJoin(context, isJoined),
        style: ElevatedButton.styleFrom(
          backgroundColor: isJoined ? AppColors.borderLight : const Color(0xFFFF4458),
          foregroundColor: isJoined ? AppColors.textSecondary : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          disabledBackgroundColor: AppColors.borderLight,
          disabledForegroundColor: AppColors.textSecondary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isJoined ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circlePlus, size: 14),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                isFull && !isJoined ? l10n.full : (isJoined ? 'Leave' : 'Join'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleToggleJoin(BuildContext context, bool isCurrentlyJoined) async {
    final l10n = AppLocalizations.of(context)!;
    final authController = Get.find<AuthStateController>();

    if (!authController.isAuthenticated.value) {
      AppToast.warning(l10n.pleaseLoginToCreateMeetup, title: l10n.loginRequired);
      Get.toNamed(AppRoutes.login);
      return;
    }

    final isJoining = !isCurrentlyJoined;

    try {
      final meetupRepository = MeetupRepository();

      if (isJoining) {
        await meetupRepository.rsvpToMeetup(meetup.id);
        if (!_meetupController.rsvpedMeetupIds.contains(meetup.id)) {
          _meetupController.rsvpedMeetupIds.add(meetup.id);
        }
        AppToast.success(l10n.youHaveJoined(meetup.title), title: l10n.joined);
      } else {
        await meetupRepository.cancelRsvp(meetup.id);
        _meetupController.rsvpedMeetupIds.remove(meetup.id);
        AppToast.info(l10n.youLeft(meetup.title), title: l10n.leftMeetup);
      }

      _meetupController.refreshMeetups();
    } catch (e) {
      log('❌ API 调用失败: $e');
      _handleJoinError(e.toString(), isCurrentlyJoined);
    }
  }

  void _handleJoinError(String errorMessage, bool isCurrentlyJoined) {
    if (errorMessage.contains('已经参加') || errorMessage.contains('already joined')) {
      if (!_meetupController.rsvpedMeetupIds.contains(meetup.id)) {
        _meetupController.rsvpedMeetupIds.add(meetup.id);
      }
      AppToast.info('您已经加入了这个活动');
      return;
    }

    if (errorMessage.contains('未参加') || errorMessage.contains('not joined')) {
      _meetupController.rsvpedMeetupIds.remove(meetup.id);
      AppToast.info('您尚未加入这个活动');
      return;
    }

    AppToast.error(isCurrentlyJoined ? '退出活动失败' : '加入活动失败', title: '操作失败');
  }

  Future<void> _handleCancelMeetup(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final meetupRepository = Get.find<IMeetupRepository>();

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('取消活动'),
        content: const Text('确定要取消这个活动吗？此操作无法撤销。'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await meetupRepository.cancelMeetup(meetup.id);
      AppToast.success('活动已取消', title: '成功');
      _meetupController.refreshMeetups();
    } catch (e) {
      log('❌ 取消活动失败: $e');
      AppToast.error('取消活动失败');
    }
  }

  Color _getTypeColor(String type) {
    final typeLower = type.toLowerCase();
    if (typeLower.contains('coffee') || typeLower.contains('咖啡')) return Colors.brown;
    if (typeLower.contains('coworking') || typeLower.contains('business')) return Colors.blue;
    if (typeLower.contains('activity') || typeLower.contains('outdoor')) return Colors.green;
    if (typeLower.contains('language')) return Colors.purple;
    if (typeLower.contains('social') || typeLower.contains('networking')) return Colors.orange;
    if (typeLower.contains('tech') || typeLower.contains('workshop')) return Colors.indigo;
    if (typeLower.contains('food') || typeLower.contains('dinner')) return Colors.red;
    if (typeLower.contains('sports') || typeLower.contains('fitness')) return Colors.teal;
    if (typeLower.contains('culture') || typeLower.contains('art')) return Colors.pink;
    if (typeLower.contains('yoga') || typeLower.contains('meditation')) return const Color(0xFF4CAF50);
    return const Color(0xFF9C27B0);
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}
