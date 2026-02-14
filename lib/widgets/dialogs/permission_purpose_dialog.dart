import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';

/// 权限用途说明对话框
///
/// 在申请系统权限之前，先向用户清晰说明申请该权限的目的和用途，
/// 符合隐私合规要求（场景7）：在申请打开可收集个人信息权限时，
/// 通过显著方式同步告知用户其目的。
class PermissionPurposeDialog {
  /// 显示位置权限用途说明对话框
  ///
  /// 返回 true 表示用户同意继续（可以发起系统权限请求），false 表示用户拒绝
  static Future<bool> showLocationPermissionPurpose({
    BuildContext? context,
  }) async {
    log('📋 显示位置权限用途说明对话框');
    final result = await Get.dialog<bool>(
      const _LocationPermissionPurposeWidget(),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  /// 显示日历权限用途说明对话框
  static Future<bool> showCalendarPermissionPurpose({
    BuildContext? context,
  }) async {
    log('📋 显示日历权限用途说明对话框');
    final result = await Get.dialog<bool>(
      const _CalendarPermissionPurposeWidget(),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  /// 显示通知权限用途说明对话框
  static Future<bool> showNotificationPermissionPurpose({
    BuildContext? context,
  }) async {
    log('📋 显示通知权限用途说明对话框');
    final result = await Get.dialog<bool>(
      const _NotificationPermissionPurposeWidget(),
      barrierDismissible: false,
    );
    return result ?? false;
  }
}

// ==================== 位置权限用途对话框 ====================

class _LocationPermissionPurposeWidget extends StatelessWidget {
  const _LocationPermissionPurposeWidget();

  @override
  Widget build(BuildContext context) {
    return _PermissionPurposeBase(
      icon: Icons.location_on_outlined,
      iconColor: const Color(0xFF0891B2),
      title: '需要使用您的位置信息',
      description: '行途需要获取您的位置权限，用于以下功能：',
      purposes: const [
        _PurposeItem(
          icon: Icons.explore_outlined,
          text: '为您推荐附近的城市和目的地',
        ),
        _PurposeItem(
          icon: Icons.event_outlined,
          text: '查找您附近的活动和聚会',
        ),
        _PurposeItem(
          icon: Icons.work_outline,
          text: '发现附近的共享办公空间',
        ),
        _PurposeItem(
          icon: Icons.map_outlined,
          text: '提供地图导航和位置选择功能',
        ),
      ],
      note: '我们仅在您使用相关功能时获取位置信息，不会在后台持续追踪您的位置。您可以随时在系统设置中关闭位置权限。',
      confirmText: '允许使用位置',
      cancelText: '暂不允许',
    );
  }
}

// ==================== 日历权限用途对话框 ====================

class _CalendarPermissionPurposeWidget extends StatelessWidget {
  const _CalendarPermissionPurposeWidget();

  @override
  Widget build(BuildContext context) {
    return _PermissionPurposeBase(
      icon: Icons.calendar_today_outlined,
      iconColor: const Color(0xFF7C3AED),
      title: '需要访问您的日历',
      description: '行途需要获取日历权限，用于以下功能：',
      purposes: const [
        _PurposeItem(
          icon: Icons.event_available_outlined,
          text: '将活动和聚会添加到您的日历中',
        ),
        _PurposeItem(
          icon: Icons.notifications_active_outlined,
          text: '设置活动提醒，避免错过精彩活动',
        ),
      ],
      note: '我们仅在您主动点击"添加到日历"时访问日历，不会读取您的其他日历信息。',
      confirmText: '允许访问日历',
      cancelText: '暂不允许',
    );
  }
}

// ==================== 通知权限用途对话框 ====================

class _NotificationPermissionPurposeWidget extends StatelessWidget {
  const _NotificationPermissionPurposeWidget();

  @override
  Widget build(BuildContext context) {
    return _PermissionPurposeBase(
      icon: Icons.notifications_outlined,
      iconColor: const Color(0xFFF59E0B),
      title: '需要发送通知',
      description: '行途需要通知权限，用于以下功能：',
      purposes: const [
        _PurposeItem(
          icon: Icons.auto_stories_outlined,
          text: '旅行指南生成完成通知',
        ),
        _PurposeItem(
          icon: Icons.chat_bubble_outline,
          text: '新消息和互动提醒',
        ),
        _PurposeItem(
          icon: Icons.event_note_outlined,
          text: '活动开始前提醒',
        ),
      ],
      note: '您可以随时在应用设置或系统设置中关闭通知。',
      confirmText: '允许发送通知',
      cancelText: '暂不允许',
    );
  }
}

// ==================== 通用底层组件 ====================

class _PurposeItem {
  final IconData icon;
  final String text;

  const _PurposeItem({required this.icon, required this.text});
}

class _PermissionPurposeBase extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<_PurposeItem> purposes;
  final String note;
  final String confirmText;
  final String cancelText;

  const _PermissionPurposeBase({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.purposes,
    required this.note,
    required this.confirmText,
    required this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
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
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: iconColor),
              ),
              const SizedBox(height: 20),

              // 标题
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // 描述
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // 用途列表
              ...purposes.map((purpose) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(purpose.icon, size: 16, color: iconColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            purpose.text,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 12),

              // 隐私说明
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 按钮
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    confirmText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Get.back(result: false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    cancelText,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
