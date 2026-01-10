import 'package:df_admin_mobile/features/notification/domain/entities/app_notification.dart';
import 'package:df_admin_mobile/features/notification/presentation/controllers/notification_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 活动邀请响应对话框
class EventInvitationDialog extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onResponse;

  const EventInvitationDialog({
    super.key,
    required this.notification,
    this.onResponse,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final eventTitle = notification.metadata?['eventTitle'] ?? notification.title;
    final inviterName = notification.metadata?['inviterName'] ?? '某用户';
    final eventTime = notification.metadata?['eventTime'] ?? '';
    final invitationId = notification.metadata?['invitationId'] ?? notification.relatedId;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
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

            // 标题
            Text(
              l10n.eventInvitation,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a),
              ),
            ),
            const SizedBox(height: 12),

            // 消息
            Text(
              '$inviterName ${l10n.inviteYouToJoin}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6b7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // 活动信息
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                  if (eventTime.isNotEmpty) ...[
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
                          eventTime,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6b7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleResponse(context, invitationId, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      l10n.decline,
                      style: const TextStyle(
                        color: Color(0xFF6b7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleResponse(context, invitationId, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      l10n.accept,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleResponse(BuildContext context, String? invitationId, bool accepted) async {
    if (invitationId == null || invitationId.isEmpty) {
      AppToast.error('无法获取邀请ID');
      return;
    }

    final notificationController = Get.find<NotificationStateController>();

    // 显示加载指示器
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final success = await notificationController.respondToEventInvitation(
      notificationId: notification.id,
      invitationId: invitationId,
      accepted: accepted,
    );

    // 关闭加载指示器
    Get.back();

    if (success) {
      AppToast.success(accepted ? '已接受邀请' : '已拒绝邀请');
      Get.back(); // 关闭对话框
      onResponse?.call();
    } else {
      AppToast.error('操作失败，请重试');
    }
  }
}

/// 版主转让响应对话框
class ModeratorTransferDialog extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onResponse;

  const ModeratorTransferDialog({
    super.key,
    required this.notification,
    this.onResponse,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cityName = notification.metadata?['cityName'] ?? '';
    final currentModeratorName = notification.metadata?['currentModeratorName'] ?? '某用户';
    final transferId = notification.metadata?['transferId'] ?? notification.relatedId;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.userGear,
                color: Color(0xFF9C27B0),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // 标题
            Text(
              l10n.moderatorTransfer,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a),
              ),
            ),
            const SizedBox(height: 12),

            // 消息
            Text(
              notification.message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6b7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // 城市信息
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.city,
                        size: 14,
                        color: Color(0xFF6b7280),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cityName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.user,
                        size: 14,
                        color: Color(0xFF6b7280),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${l10n.from}: $currentModeratorName',
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

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleResponse(context, transferId, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      l10n.decline,
                      style: const TextStyle(
                        color: Color(0xFF6b7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleResponse(context, transferId, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      l10n.accept,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleResponse(BuildContext context, String? transferId, bool accepted) async {
    if (transferId == null || transferId.isEmpty) {
      AppToast.error('无法获取转让ID');
      return;
    }

    final notificationController = Get.find<NotificationStateController>();

    // 显示加载指示器
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final success = await notificationController.respondToModeratorTransfer(
      notificationId: notification.id,
      transferId: transferId,
      accepted: accepted,
    );

    // 关闭加载指示器
    Get.back();

    if (success) {
      AppToast.success(accepted ? '已接受版主转让' : '已拒绝版主转让');
      Get.back(); // 关闭对话框
      onResponse?.call();
    } else {
      AppToast.error('操作失败，请重试');
    }
  }
}
