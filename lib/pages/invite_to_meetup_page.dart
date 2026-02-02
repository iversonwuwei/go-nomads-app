import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'create_meetup/create_meetup_page.dart';

class InviteToMeetupPage extends StatelessWidget {
  final User user;

  const InviteToMeetupPage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final meetupController = Get.find<MeetupStateController>();
    final myMeetups = meetupController.upcomingMeetups;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(color: Color(0xFF1a1a1a)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.invite} ${user.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a),
              ),
            ),
            Text(
              l10n.selectMeetup,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6b7280),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: myMeetups.isEmpty
          ? _buildEmptyMeetupState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myMeetups.length,
              itemBuilder: (context, index) {
                final meetup = myMeetups[index];
                return _buildMeetupInviteCard(context, meetup);
              },
            ),
    );
  }

  // 空状态
  Widget _buildEmptyMeetupState() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.calendarXmark,
                  size: 64,
                  color: const Color(0xFF6b7280).withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noData,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.createMeetup,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6b7280),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateMeetupPage(),
                      ),
                    );
                  },
                  icon: const Icon(FontAwesomeIcons.plus),
                  label: Text(l10n.createMeetup),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 检查被邀请用户是否可以被邀请到该 meetup
  /// 返回 null 表示可以邀请，否则返回不可邀请的原因
  String? _getCannotInviteReason(BuildContext context, Meetup meetup) {
    final l10n = AppLocalizations.of(context)!;

    // 检查被邀请用户是否是该 meetup 的创建者
    if (meetup.organizer.id == user.id) {
      return l10n.userIsOrganizer;
    }

    // 检查被邀请用户是否已经加入了该 meetup
    if (meetup.attendeeIds.contains(user.id)) {
      return l10n.userAlreadyJoined;
    }

    return null;
  }

  // Meetup 邀请卡片
  Widget _buildMeetupInviteCard(
    BuildContext context,
    Meetup meetup,
  ) {
    final cannotInviteReason = _getCannotInviteReason(context, meetup);
    final canInvite = cannotInviteReason == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: canInvite ? Colors.white : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canInvite ? const Color(0xFFE5E7EB) : const Color(0xFFD1D5DB),
        ),
        boxShadow: canInvite
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: canInvite ? () => _inviteToMeetup(context, meetup) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Meetup Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: canInvite
                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                        : const Color(0xFF9CA3AF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    FontAwesomeIcons.calendarDays,
                    color: canInvite ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),

                // Meetup Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meetup.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1a1a1a),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.clock,
                            size: 14,
                            color: Color(0xFF6b7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${meetup.schedule.startTime.month}/${meetup.schedule.startTime.day}/${meetup.schedule.startTime.year}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6b7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.locationDot,
                            size: 14,
                            color: Color(0xFF6b7280),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              meetup.location.city,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6b7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // 不可邀请原因提示
                      if (cannotInviteReason != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            cannotInviteReason,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow or disabled icon
                Icon(
                  canInvite ? FontAwesomeIcons.arrowRight : FontAwesomeIcons.ban,
                  size: 16,
                  color: canInvite ? const Color(0xFF9ca3af) : const Color(0xFFD1D5DB),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 邀请到 Meetup
  void _inviteToMeetup(BuildContext context, Meetup meetup) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  FontAwesomeIcons.calendarDays,
                  color: Color(0xFF10B981),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                l10n.confirm,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a1a),
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                '${l10n.invite} ${user.name}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6b7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meetup.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.clock,
                          size: 14,
                          color: Color(0xFF6b7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${meetup.schedule.startTime.month}/${meetup.schedule.startTime.day}/${meetup.schedule.startTime.year} at ${meetup.schedule.startTime.hour}:${meetup.schedule.startTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6b7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(
                          color: Color(0xFF6b7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // 先关闭对话框
                        Navigator.pop(context);

                        // 获取 MeetupController 并发送邀请
                        final meetupController = Get.find<MeetupStateController>();

                        final success = await meetupController.inviteToMeetup(
                          meetupId: meetup.id,
                          inviteeId: user.id,
                        );

                        if (success) {
                          // 返回上一页
                          if (Get.context != null) {
                            Navigator.pop(Get.context!);
                          }
                        }
                      },
                      icon: const Icon(FontAwesomeIcons.paperPlane, size: 18),
                      label: Text(l10n.sendInvitation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
