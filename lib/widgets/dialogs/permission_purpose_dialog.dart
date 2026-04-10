import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_icons.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/services/app_config_service.dart';
import 'package:go_nomads_app/widgets/buttons/app_primary_button.dart';

/// 权限用途说明对话框
///
/// 在申请系统权限之前，先向用户清晰说明申请该权限的目的和用途，
/// 符合隐私合规要求（场景7）：在申请打开可收集个人信息权限时，
/// 通过显著方式同步告知用户其目的。
class PermissionPurposeDialog {
  /// 显示位置权限用途说明对话框
  ///
  /// Apple Review Guideline 5.1.1 合规：对话框只有"继续"按钮，
  /// 用户阅读后直接进入系统权限弹窗，不可跳过。
  static Future<void> showLocationPermissionPurpose({
    BuildContext? context,
  }) async {
    log('📋 显示位置权限用途说明对话框');
    await Get.dialog<void>(
      _PermissionPurposeConfigWidget(
        copyFuture: AppConfigService().getLocationPermissionPurposeCopy(),
        fallbackCopy: const PermissionPurposeCopy(
          title: '需要使用您的位置信息',
          description: '行途需要获取您的位置权限，用于以下功能：',
          purposes: [
            '为您推荐附近的城市和目的地',
            '查找您附近的活动和聚会',
            '发现附近的共享办公空间',
            '提供地图导航和位置选择功能',
          ],
          note: '我们仅在您使用相关功能时获取位置信息，不会在后台持续追踪您的位置。您可以随时在系统设置中关闭位置权限。',
          confirmText: '继续',
        ),
        itemIcons: const [
          Icons.explore_outlined,
          Icons.event_outlined,
          Icons.work_outline,
          Icons.map_outlined,
        ],
        icon: AppIcons.location,
        iconColor: Color(0xFF0891B2),
      ),
      barrierDismissible: false,
    );
  }

  /// 显示日历权限用途说明对话框
  ///
  /// Apple Review Guideline 5.1.1 合规：对话框只有"继续"按钮，不可跳过。
  static Future<void> showCalendarPermissionPurpose({
    BuildContext? context,
  }) async {
    log('📋 显示日历权限用途说明对话框');
    await Get.dialog<void>(
      _PermissionPurposeConfigWidget(
        copyFuture: AppConfigService().getCalendarPermissionPurposeCopy(),
        fallbackCopy: const PermissionPurposeCopy(
          title: '需要访问您的日历',
          description: '行途需要获取日历权限，用于以下功能：',
          purposes: [
            '将活动和聚会添加到您的日历中',
            '设置活动提醒，避免错过精彩活动',
          ],
          note: '我们仅在您主动点击"添加到日历"时访问日历，不会读取您的其他日历信息。',
          confirmText: '继续',
        ),
        itemIcons: const [
          Icons.event_available_outlined,
          Icons.notifications_active_outlined,
        ],
        icon: AppIcons.calendar,
        iconColor: Color(0xFF7C3AED),
      ),
      barrierDismissible: false,
    );
  }

  /// 显示通知权限用途说明对话框
  ///
  /// Apple Review Guideline 5.1.1 合规：对话框只有"继续"按钮，不可跳过。
  static Future<void> showNotificationPermissionPurpose({
    BuildContext? context,
  }) async {
    log('📋 显示通知权限用途说明对话框');
    await Get.dialog<void>(
      _PermissionPurposeConfigWidget(
        copyFuture: AppConfigService().getNotificationPermissionPurposeCopy(),
        fallbackCopy: const PermissionPurposeCopy(
          title: '需要发送通知',
          description: '行途需要通知权限，用于以下功能：',
          purposes: [
            '旅行指南生成完成通知',
            '新消息和互动提醒',
            '活动开始前提醒',
          ],
          note: '您可以随时在应用设置或系统设置中关闭通知。',
          confirmText: '继续',
        ),
        itemIcons: const [
          Icons.auto_stories_outlined,
          Icons.chat_bubble_outline,
          Icons.event_note_outlined,
        ],
        icon: AppIcons.notification,
        iconColor: Color(0xFFF59E0B),
      ),
      barrierDismissible: false,
    );
  }
}

class _PermissionPurposeConfigWidget extends StatelessWidget {
  final Future<PermissionPurposeCopy?> copyFuture;
  final PermissionPurposeCopy fallbackCopy;
  final List<IconData> itemIcons;
  final IconData icon;
  final Color iconColor;

  const _PermissionPurposeConfigWidget({
    required this.copyFuture,
    required this.fallbackCopy,
    required this.itemIcons,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PermissionPurposeCopy?>(
      future: copyFuture,
      builder: (context, snapshot) {
        final copy = snapshot.data ?? fallbackCopy;
        final purposes = copy.purposes.isNotEmpty ? copy.purposes : fallbackCopy.purposes;

        return _PermissionPurposeBase(
          icon: icon,
          iconColor: iconColor,
          title: copy.title ?? fallbackCopy.title ?? '',
          description: copy.description ?? fallbackCopy.description ?? '',
          purposes: List<_PurposeItem>.generate(
            purposes.length,
            (index) => _PurposeItem(
              icon: index < itemIcons.length ? itemIcons[index] : icon,
              text: purposes[index],
            ),
          ),
          note: copy.note ?? fallbackCopy.note ?? '',
          confirmText: copy.confirmText ?? fallbackCopy.confirmText ?? '',
        );
      },
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

  const _PermissionPurposeBase({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.purposes,
    required this.note,
    required this.confirmText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppUiTokens.radiusLg)),
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400.w),
        child: Padding(
          padding: AppUiTokens.cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32.r, color: iconColor),
              ),
              SizedBox(height: 20.h),

              // 标题
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // 描述
              Text(
                description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              // 用途列表
              ...purposes.map((purpose) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 2.h),
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(purpose.icon, size: 16.r, color: iconColor),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            purpose.text,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

              SizedBox(height: 12.h),

              // 隐私说明
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(AppIcons.shield, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        note,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // 按钮
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: confirmText,
                  onPressed: () => Get.back(),
                  backgroundColor: iconColor,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
