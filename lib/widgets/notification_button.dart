import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/notification/presentation/controllers/notification_state_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 通知入口按钮（顶部栏使用）
class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    // 确保 NotificationController 已注册
    if (!Get.isRegistered<NotificationStateController>()) {
      return const SizedBox.shrink();
    }

    final controller = Get.find<NotificationStateController>();

    return Obx(() {
      final unreadCount = controller.unreadCount.value;

      return Stack(
        children: [
          IconButton(
            icon: Icon(
              unreadCount > 0
                  ? FontAwesomeIcons.solidBell
                  : FontAwesomeIcons.bell,
              color: AppColors.icon,
            ),
            tooltip: '通知',
            onPressed: () {
              Get.toNamed('/notifications');
            },
          ),

          // 未读数量徽章
          if (unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: unreadCount > 99 ? 4 : 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
  }
}
